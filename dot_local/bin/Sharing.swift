#!/usr/bin/swift
import AppKit

// MARK: - App Delegate & Lifecycle Management

class SharingDelegate: NSObject, NSApplicationDelegate, NSSharingServiceDelegate {
  var items: [Any] = []
  var serviceName: NSSharingService.Name?
  var recipients: [String]?

  func applicationDidFinishLaunching(_ notification: Notification) {
    guard let serviceName = self.serviceName else {
      print("Error: Service name was not resolved.")
      NSApp.terminate(nil)
      return
    }

    guard let service = NSSharingService(named: serviceName) else {
      print("Error: Could not create sharing service for '\(serviceName.rawValue)'.")
      NSApp.terminate(nil)
      return
    }

    service.delegate = self
    if let recipients = self.recipients, !recipients.isEmpty {
      service.recipients = recipients
    }

    if items.isEmpty {
      // An empty item is required to show compose windows for services like Mail/Messages
      items.append("")
    }

    service.perform(withItems: items)
  }

  func sharingService(_ sharingService: NSSharingService, didShareItems items: [Any]) {
    // Uncomment for verbose output
    // print("Successfully shared items.")
    NSApp.terminate(nil)
  }

  func sharingService(_ sharingService: NSSharingService, didFailToShareItems items: [Any], error: Error) {
    print("Error: \(error.localizedDescription)")
    NSApp.terminate(nil)
  }

  // Fallback to ensure the script exits if the sharing window is just closed.
  func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
    return true
  }
}

// MARK: - Argument Parsing & Setup

let serviceNameMap: [String: NSSharingService.Name] = [
  "airdrop": .sendViaAirDrop,
  "messages": .composeMessage,
  "mail": .composeEmail,
  "photos": .addToIPhoto,
  "readingList": .addToSafariReadingList,
  // These use the internal identifiers for share sheet extensions
  "notes": NSSharingService.Name("com.apple.Notes.SharingExtension"),
  "reminders": NSSharingService.Name("com.apple.reminders.sharingextension")
]

if CommandLine.arguments.contains("-h") || CommandLine.arguments.contains("--help") {
  print("""
  Usage: Sharing.swift -s <service> [options] [items...]\n
  Shares items (text, files, URLs) using macOS sharing services.\n
  Options:
    -s, --service <service>      (Required) The sharing service to use.
    -r, --recipient <recipient>  A recipient for the share (e.g., for Messages or Mail).
                                 Can be used multiple times.
    -h, --help                   Display this help message.\n
  Available Services:
  """)
  serviceNameMap.keys.sorted().forEach { print("  - \($0)") }
  exit(0)
}

var itemsToShare: [Any] = []
var service: NSSharingService.Name?
var recipients: [String]?

var index = 1
while index < CommandLine.arguments.count {
  let arg = CommandLine.arguments[index]
  switch arg {
  case "-s", "--service":
    if let nextArg = CommandLine.arguments[safe: index + 1] {
      service = serviceNameMap[nextArg]
      index += 2
    } else {
      index += 1
    }
  case "-r", "--recipient":
    if let nextArg = CommandLine.arguments[safe: index + 1] {
      if recipients == nil { recipients = [] }
      recipients?.append(nextArg)
      index += 2
    } else {
      index += 1
    }
  default:
    if FileManager.default.fileExists(atPath: arg) {
      itemsToShare.append(URL(fileURLWithPath: arg))
    } else if let url = URL(string: arg), arg.contains("://") {
      itemsToShare.append(url)
    } else {
      itemsToShare.append(arg)
    }
    index += 1
  }
}

guard let service = service else {
  print("Error: A service must be specified with -s. Use --help to see available services.")
  exit(1)
}

// MARK: - Main Execution

let delegate = SharingDelegate()
delegate.items = itemsToShare
delegate.serviceName = service
delegate.recipients = recipients

// An NSApplication is required to host the sharing service
let app = NSApplication.shared
app.setActivationPolicy(.accessory)
app.delegate = delegate
app.run()

// MARK: - Helpers

extension Collection {
  subscript(safe i: Index) -> Element? {
  return indices.contains(i) ? self[i] : nil
  }
}

