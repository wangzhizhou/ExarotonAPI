import Testing
import ExarotonWebSocket
import Starscream
import Foundation

@Suite(Tag.List.tags(.unit, .websocket, .dispatch))
final class ExarotonWebSocketDispatchTests {
    final class FakeClient: WebSocketClient {
        func connect() {}
        func disconnect(closeCode: UInt16) {}
        func write(string: String, completion: (() -> ())?) { completion?() }
        func write(stringData: Data, completion: (() -> ())?) { completion?() }
        func write(data: Data, completion: (() -> ())?) { completion?() }
        func write(ping: Data, completion: (() -> ())?) { completion?() }
        func write(pong: Data, completion: (() -> ())?) { completion?() }
    }

    final class Handler: ExarotonServerEventHandlerProtocol {
        var readyServerID: String?
        var connectedCount = 0
        var disconnectedReason: String?
        var keepAliveCount = 0
        var statusServerID: String?
        var streamStarted: StreamCategory?
        var streamStopped: StreamCategory?
        var consoleLine: String?
        var tickAverage: Double?
        var statsMemoryPercent: Double?
        var heapUsage: Int64?
        var errorCount = 0

        func onReady(serverID: String?) { readyServerID = serverID }
        func onConnected() { connectedCount += 1 }
        func onDisconnected(reason: String?) { disconnectedReason = reason }
        func onKeepAlive() { keepAliveCount += 1 }
        func onStatusChanged(_ info: ExarotonWebSocket.Server?) { statusServerID = info?.id }
        func onStreamStarted(_ stream: StreamCategory?) { streamStarted = stream }
        func onStreamStopped(_ stream: StreamCategory?) { streamStopped = stream }
        func onConsoleLine(_ line: String?) { consoleLine = line }
        func onTick(_ tick: Tick?) { tickAverage = tick?.averageTickTime }
        func onStats(_ stats: Stats?) { statsMemoryPercent = stats?.memory.percent }
        func onHeap(_ heap: Heap?) { heapUsage = heap?.usage }
        func onError(_ error: Error) { errorCount += 1 }

        func didReceive(event: WebSocketEvent, client: any WebSocketClient) {}
    }

    @Test
    func testDispatchReady() {
        let handler = Handler()
        let api = ExarotonWebSocketAPI(token: "t", serverId: "s", delegate: handler)
        api.didReceive(event: .text(#"{"type":"ready","data":"server-id"}"#), client: FakeClient())
        #expect(handler.readyServerID == "server-id")
    }

    @Test
    func testDispatchKeepAlive() {
        let handler = Handler()
        let api = ExarotonWebSocketAPI(token: "t", serverId: "s", delegate: handler)
        api.didReceive(event: .text(#"{"type":"keep-alive"}"#), client: FakeClient())
        #expect(handler.keepAliveCount == 1)
    }

    @Test
    func testDispatchStatus() {
        let handler = Handler()
        let api = ExarotonWebSocketAPI(token: "t", serverId: "s", delegate: handler)
        api.didReceive(event: .text(#"{"stream":"status","type":"status","data":{"id":"EwYiY9IAMtQBTb6U","name":"example","address":"example.exaroton.me","motd":"hi","status":1,"players":{"max":20,"count":0,"list":[]},"host":null,"port":null,"software":null,"shared":false}}"#), client: FakeClient())
        #expect(handler.statusServerID == "EwYiY9IAMtQBTb6U")
    }

    @Test
    func testDispatchStreamLifecycleAndLine() {
        let handler = Handler()
        let api = ExarotonWebSocketAPI(token: "t", serverId: "s", delegate: handler)
        api.didReceive(event: .text(#"{"stream":"console","type":"started"}"#), client: FakeClient())
        api.didReceive(event: .text(#"{"stream":"console","type":"line","data":"hello"}"#), client: FakeClient())
        api.didReceive(event: .text(#"{"stream":"console","type":"stopped"}"#), client: FakeClient())
        #expect(handler.streamStarted == .console)
        #expect(handler.consoleLine == "hello")
        #expect(handler.streamStopped == .console)
    }

    @Test
    func testDispatchTickStatsHeap() {
        let handler = Handler()
        let api = ExarotonWebSocketAPI(token: "t", serverId: "s", delegate: handler)
        api.didReceive(event: .text(#"{"stream":"tick","type":"tick","data":{"averageTickTime":8.72}}"#), client: FakeClient())
        api.didReceive(event: .text(#"{"stream":"stats","type":"stats","data":{"memory":{"percent":38.49,"usage":1983},"cpu":{"percent":10.0,"usage":1.0,"limit":100}}}"#), client: FakeClient())
        api.didReceive(event: .text(#"{"stream":"heap","type":"heap","data":{"usage":2}}"#), client: FakeClient())
        #expect(handler.tickAverage == 8.72)
        #expect(handler.statsMemoryPercent == 38.49)
        #expect(handler.heapUsage == 2)
    }

    @Test
    func testInvalidJsonDoesNotCrashAndCallsOnError() {
        let handler = Handler()
        let api = ExarotonWebSocketAPI(token: "t", serverId: "s", delegate: handler)
        api.didReceive(event: .text("not-json"), client: FakeClient())
        #expect(handler.errorCount == 1)
    }
}
