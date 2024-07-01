import Foundation
import Testing
import ExarotonWebSocket

final class ExarotonWebSocketTests {

    static let handler = ExarotonWebSocketEventDelegateHandler()

    var socket = ExarotonWebSocketAPI(
        token: ProcessInfo.processInfo.environment["TOKEN"] ?? "",
        serverId: ProcessInfo.processInfo.environment["SERVER"] ?? "",
        delegate: handler
    )

    init() async throws {
        socket.client.connect()
        try await wait(seconds: Int(socket.timeout))
    }
    
    deinit {
        socket.client.disconnect()
    }
    
    @Test
    func testStartConsoleStream() async throws {
        let message = ExarotonMessage(
            stream: .console,
            type: StreamType.start,
            data: ["tail": 5]
        )
        let data = try message.toData
        socket.client.write(stringData: data, completion: nil)
    }
    
    @Test
    func testStopConsoleStream() async throws {
        let message = ExarotonMessage(
            stream: .console,
            type: StreamType.stop,
            data: nil
        )
        let data = try message.toData
        socket.client.write(stringData: data, completion: nil)
    }
    
    @Test
    func testSendConsoleCommandStream() async throws {
        let message = ExarotonMessage(
            stream: .console,
            type: StreamType.command,
            data: "say Hello"
        )
        let data = try message.toData
        socket.client.write(stringData: data, completion: nil)
    }
    
    @Test
    func testStartTickStream() async throws {
        let message = ExarotonMessage(
            stream: .tick,
            type: StreamType.start,
            data: nil
        )
        let data = try message.toData
        socket.client.write(stringData: data, completion: nil)
    }
    
    @Test
    func testStopTickStream() async throws {
        let message = ExarotonMessage(
            stream: .tick,
            type: StreamType.stop,
            data: nil
        )
        let data = try message.toData
        socket.client.write(stringData: data, completion: nil)
    }
    
    @Test
    func testStartStatsStream() async throws {
        let message = ExarotonMessage(
            stream: .stats,
            type: StreamType.start,
            data: nil
        )
        let data = try message.toData
        socket.client.write(stringData: data, completion: nil)
    }
    
    @Test
    func testStopStatsStream() async throws {
        let message = ExarotonMessage(
            stream: .stats,
            type: StreamType.stop,
            data: nil
        )
        let data = try message.toData
        socket.client.write(stringData: data, completion: nil)
    }
    
    @Test
    func testStartHeapStream() async throws {
        let message = ExarotonMessage(
            stream: .heap,
            type: StreamType.start,
            data: nil
        )
        let data = try message.toData
        socket.client.write(stringData: data, completion: nil)
    }
    
    @Test
    func testStopHeapStream() async throws {
        let message = ExarotonMessage(
            stream: .heap,
            type: StreamType.stop,
            data: nil
        )
        let data = try message.toData
        socket.client.write(stringData: data, completion: nil)
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
