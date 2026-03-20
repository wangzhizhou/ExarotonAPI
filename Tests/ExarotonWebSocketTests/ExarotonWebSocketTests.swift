import Foundation
import Testing
import ExarotonWebSocket

private func env(_ key: String) -> String {
    ProcessInfo.processInfo.environment[key] ?? ""
}

private func hasEnv(_ keys: [String]) -> Bool {
    keys.allSatisfy { !env($0).isEmpty }
}

@Suite(Tag.List.tags(.integration, .websocket))
final class ExarotonWebSocketTests {
    @Test(.enabled(if: hasEnv(["TOKEN", "SERVER"]), "Missing environment variable: TOKEN or SERVER"))
    func testConnectDisconnectIntegration() async throws {
        let socket = ExarotonWebSocketAPI(
            token: env("TOKEN"),
            serverId: env("SERVER"),
            delegate: ExarotonWebSocketEventDelegateHandler()
        )
        socket.connect()
        try await Task.sleep(for: .seconds(socket.timeout))
        socket.disconnect()
    }
}
