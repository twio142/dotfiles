import Foundation

let environment = ProcessInfo.processInfo.environment
let serviceMap: [String: String] = [
    "reminders": "'com.apple.reminders.sharingextension'",
    "notes": "'com.apple.Notes.SharingExtension'",
    "photos": "hs.sharing.builtinSharingServices.addToIPhoto",
    "airdrop": "hs.sharing.builtinSharingServices.sendViaAirDrop",
    "messages": "hs.sharing.builtinSharingServices.composeMessage",
    "mail": "hs.sharing.builtinSharingServices.composeEmail",
    "readingList": "hs.sharing.builtinSharingServices.addToSafariReadingList"
]

extension Collection {
    subscript(safe i: Index) -> Element? {
        return indices.contains(i) ? self[i] : nil
    }
}

var script = ["local items={}"]

var service: String?
var args: [String] = []
var recipients: [String] = []

var index = 1
while index < CommandLine.arguments.count {
    let arg = CommandLine.arguments[index]
    index += 1
    if (arg == "-s" || arg == "--service"), CommandLine.arguments[safe: index] != nil, service == nil {
        service = serviceMap[CommandLine.arguments[index]]
        index += 1
    } else if arg == "-r" || arg == "--recipient", CommandLine.arguments[safe: index] != nil {
        if !recipients.contains(CommandLine.arguments[index]) {
            recipients.append(CommandLine.arguments[index])
        }
        index += 1
    } else if FileManager.default.fileExists(atPath: arg) {
        script.append("table.insert(items, hs.sharing.URL(_cli._args[\(args.count+6)], true))")
        args.append(arg)
    } else if arg.range(of: "^[a-zA-Z0-9_-]+://[a-zA-Z0-9_-]+(\\.[a-zA-Z0-9_-]+)*(\\/\\S*)?$", options: .regularExpression) != nil {
        script.append("table.insert(items, hs.sharing.URL(_cli._args[\(args.count+6)]))")
        args.append(arg)
    } else {
        arg.trimmingCharacters(in: .whitespacesAndNewlines).split(separator: "\n").forEach { line in
            script.append("table.insert(items, hs.styledtext.new(_cli._args[\(args.count+6)]))")
            args.append(String(line))
        }
    }
}

if service == nil {
    print("No service specified")
    exit(1)
}

var command = "hs.sharing.newShare(\(service!))"
if recipients.count > 0 {
    if args.count == 0 {
        script.append("table.insert(items, hs.styledtext.new(''))")
    }
    command.append(":recipients({")
    command.append(recipients.map { "'\($0)'" }.joined(separator: ","))
    command.append("})")
}
script.append("\(command):shareItems(items)")
print(script.joined(separator: "\n"))

let task = Process()
task.environment = ProcessInfo.processInfo.environment
task.executableURL = URL(fileURLWithPath: "/usr/local/bin/hs")
task.arguments = ["-A", "-c", script.joined(separator: "\n"), "--"] + args

do {
    try task.run()
    task.waitUntilExit()
} catch {
    print("Failed to run task: \(error)")
}
