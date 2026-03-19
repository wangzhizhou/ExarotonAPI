import Foundation
import Testing
import ExarotonWebSocket

private func env(_ key: String) -> String {
    ProcessInfo.processInfo.environment[key] ?? ""
}

private func hasEnv(_ keys: [String]) -> Bool {
    keys.allSatisfy { !env($0).isEmpty }
}

final class ExarotonWebSocketTests {

    var socket = ExarotonWebSocketAPI(
        token: ProcessInfo.processInfo.environment["TOKEN"] ?? "",
        serverId: ProcessInfo.processInfo.environment["SERVER"] ?? "",
        delegate: ExarotonWebSocketEventDelegateHandler()
    )

    init() async throws {
        guard hasEnv(["TOKEN", "SERVER"]) else {
            return
        }
        socket.client.connect()
        try await wait(seconds: Int(socket.timeout))
    }
    
    deinit {
        socket.client.disconnect()
    }
    
    @Test(.enabled(if: hasEnv(["TOKEN", "SERVER"]), "Missing environment variable: TOKEN or SERVER"))
    func testStartConsoleStream() async throws {
        try socket.startStream(.console, tail: 5)
    }
    
    @Test(.enabled(if: hasEnv(["TOKEN", "SERVER"]), "Missing environment variable: TOKEN or SERVER"))
    func testStopConsoleStream() async throws {
        try socket.stopStream(.console)
    }
    
    @Test(.enabled(if: hasEnv(["TOKEN", "SERVER"]), "Missing environment variable: TOKEN or SERVER"))
    func testSendConsoleCommandStream() async throws {
        try socket.sendConsoleCommand("say Hello")
    }
    
    @Test(.enabled(if: hasEnv(["TOKEN", "SERVER"]), "Missing environment variable: TOKEN or SERVER"))
    func testStartTickStream() async throws {
        try socket.startStream(.tick)
    }
    
    @Test(.enabled(if: hasEnv(["TOKEN", "SERVER"]), "Missing environment variable: TOKEN or SERVER"))
    func testStopTickStream() async throws {
        try socket.stopStream(.tick)
    }
    
    @Test(.enabled(if: hasEnv(["TOKEN", "SERVER"]), "Missing environment variable: TOKEN or SERVER"))
    func testStartStatsStream() async throws {
        try socket.startStream(.stats)
    }
    
    @Test(.enabled(if: hasEnv(["TOKEN", "SERVER"]), "Missing environment variable: TOKEN or SERVER"))
    func testStopStatsStream() async throws {
        try socket.stopStream(.stats)
    }
    
    @Test(.enabled(if: hasEnv(["TOKEN", "SERVER"]), "Missing environment variable: TOKEN or SERVER"))
    func testStartHeapStream() async throws {
        try socket.startStream(.heap)
    }
    
    @Test(.enabled(if: hasEnv(["TOKEN", "SERVER"]), "Missing environment variable: TOKEN or SERVER"))
    func testStopHeapStream() async throws {
        try socket.stopStream(.heap)
    }
}

extension ExarotonWebSocketTests {
    
    func wait(minutes: Int) async throws {
        try await wait(seconds: minutes * 60)
    }

    func wait(seconds: Int) async throws {
        try await Task.sleep(for: .seconds(seconds))
    }
}
