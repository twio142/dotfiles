#!/usr/bin/swift

// Show an arrow pointing up or down in the middle of the frontmost window.
// Usage: ./HUD [-i|--icon] [ICON] [-p|--point] [POINT] [-d|--duration] [DURATION]

import SwiftUI

struct HUDView: View {
  @State private var isShowing: Bool = false
  let dismissAfter: TimeInterval = CommandLine.duration ?? 1.0
  let fade: Double = 0.1

  var body: some View {
    ZStack {
      if isShowing {
        Background()
        HStack {
          DisplayText()
        }
      }
    }
    .frame(width: 55, height: 55, alignment: .center)
    .transition(.opacity)
    .task {
      withAnimation(.easeIn(duration: fade)) {
        isShowing = true
      }
      DispatchQueue.main.asyncAfter(deadline: .now() + (dismissAfter - fade)) {
        withAnimation(.easeOut(duration: fade)) {
          self.isShowing = false
        }
      }
      DispatchQueue.main.asyncAfter(deadline: .now() + dismissAfter) {
        NSApplication.shared.terminate(nil)
      }
    }
  }

  @ViewBuilder
  func Background() -> some View {
    Color(nsColor: NSColor.black.withAlphaComponent(0.6))
      .cornerRadius(15.0)
      .overlay(content: {
        RoundedRectangle(cornerRadius: 20.0)
          .stroke(.primary.opacity(0.1), lineWidth: 1)
      })
  }

  @ViewBuilder
  func DisplayText() -> some View {
    Text(CommandLine.icon ?? "􁾩")
      .font(.system(size: 25).bold())
      .foregroundColor(.white)
      .padding([.leading, .trailing, .top, .bottom], 5)
      .frame(alignment: .center)
  }
}

class HUDAppDelegate: NSObject, NSApplicationDelegate {
  var window: NSWindow!
  func applicationDidFinishLaunching(_ aNotification: Notification) {
    let dialogView = HUDView()
    window = NSWindow(
      contentRect: NSRect(x: 0, y: 0, width: 60, height: 60),
      styleMask: [.borderless],
      backing: .buffered,
      defer: false
    )
    window.isOpaque = false
    window.hasShadow = false
    window.backgroundColor = NSColor.clear
    window.setFrameAutosaveName("Main Window")
    window.contentView = NSHostingView(rootView: dialogView)
    window.makeKeyAndOrderFront(nil)
    window.level = NSWindow.Level(rawValue: Int(CGWindowLevelForKey(.floatingWindow)))
    if var point = CommandLine.point {
      point.x -= 30
      point.y -= 30
      window.setFrameOrigin(point)
    } else {
      window.center()
    }

    NSApplication.shared.activate(ignoringOtherApps: false)
  }
}

extension Collection {
  subscript(safe i: Index) -> Element? {
    return indices.contains(i) ? self[i] : nil
  }
}

extension CommandLine {
  private static let parsedArgs = parseArguments()
  static var icon: String? {
    return parsedArgs.icon
  }
  static var point: NSPoint? {
    return parsedArgs.point
  }
  static var duration: TimeInterval? {
    return parsedArgs.duration
  }
}

func parseArguments() -> (icon: String?, point: NSPoint?, duration: TimeInterval?) {
  var icon: String?
  var point: NSPoint?
  var duration: TimeInterval?

  var index = 1
  while index < CommandLine.arguments.count {
    let argument = CommandLine.arguments[index]

    switch argument {
    case "-i", "--icon":
      if let i = CommandLine.arguments[safe: index + 1] {
        icon = i
      }
      index += 2
    case "-p", "--point":
      if let a = CommandLine.arguments[safe: index + 1], a.split(separator: ",").count == 2, a.split(separator: ",").allSatisfy({ Double($0) != nil }) {
        let parts = a.split(separator: ",")
        point = NSPoint(x: CGFloat(Double(parts[0]) ?? 0), y: CGFloat(Double(parts[1]) ?? 0))
      }
      index += 2
    case "-d", "--duration":
      if let d = TimeInterval(CommandLine.arguments[safe: index + 1] ?? "") {
        duration = d
      }
      index += 2
    default:
      index += 1
    }
  }
  return (icon, point, duration)
}

let app = NSApplication.shared
let delegate = HUDAppDelegate()
app.delegate = delegate
app.setActivationPolicy(.accessory)
app.run()
