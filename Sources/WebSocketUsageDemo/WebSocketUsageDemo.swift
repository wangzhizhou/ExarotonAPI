import Foundation
import ExarotonWebSocket
import Starscream

@main
struct WebSocketUsageDemo {

    static func main() async throws {
        let token = ProcessInfo.processInfo.environment["TOKEN"] ?? ""
        let serverId = ProcessInfo.processInfo.environment["SERVER"] ?? ""
        guard !token.isEmpty, !serverId.isEmpty else {
            print("Missing env TOKEN or SERVER. Example: TOKEN=... SERVER=... swift run WebSocketUsageDemo")
            return
        }

        let ready = ReadySignal()
        let handler = ServerEventHandler(ready: ready)
        let socket = ExarotonWebSocketAPI(token: token, serverId: serverId, delegate: handler)

        socket.connect()

        let didBecomeReady = await ready.wait(seconds: socket.timeout)
        guard didBecomeReady else {
            print("Timed out waiting for ready")
            socket.disconnect()
            return
        }

        try socket.startStream(.console, tail: 10) {
            print("console stream start sent")
        }

        try socket.sendConsoleCommand("say Hello from WebSocketUsageDemo") {
            print("console command sent")
        }

        try await sleep(seconds: 3)
        try socket.stopStream(.console) {
            print("console stream stop sent")
        }

        try await sleep(seconds: 1)
        socket.disconnect()
    }

    static func sleep(seconds: Double) async throws {
        let ns = UInt64(max(0, seconds) * 1_000_000_000)
        try await Task.sleep(nanoseconds: ns)
    }
}

actor ReadySignal {
    private var continuation: CheckedContinuation<Void, Never>?
    private var isSignaled = false

    func signal() {
        isSignaled = true
        continuation?.resume()
        continuation = nil
    }

    func wait(seconds: Double) async -> Bool {
        if isSignaled { return true }
        return await withTaskGroup(of: Bool.self) { group in
            group.addTask {
                await withCheckedContinuation { continuation in
                    Task { await self._install(continuation) }
                }
                return true
            }
            group.addTask {
                let ns = UInt64(max(0, seconds) * 1_000_000_000)
                try? await Task.sleep(nanoseconds: ns)
                return false
            }
            let result = await group.next() ?? false
            group.cancelAll()
            return result
        }
    }

    private func _install(_ continuation: CheckedContinuation<Void, Never>) {
        if isSignaled {
            continuation.resume()
            return
        }
        self.continuation = continuation
    }
}

final class ServerEventHandler: ExarotonServerEventHandlerProtocol {
    let ready: ReadySignal

    init(ready: ReadySignal) {
        self.ready = ready
    }

    func onReady(serverID: String?) {
        print("server ready: \(serverID ?? "")")
        Task { await ready.signal() }
    }

    func onConnected() {
        print("server connected")
    }

    func onDisconnected(reason: String?) {
        print("server disconnected: \(reason ?? "")")
    }

    func onKeepAlive() {
        print("server keep alive")
    }

    func onStatusChanged(_ info: ExarotonWebSocket.Server?) {
        if let info {
            print("status: \(info)")
        }
    }

    func onStreamStarted(_ stream: ExarotonWebSocket.StreamCategory?) {
        if let stream {
            print("stream started: \(stream)")
        }
    }

    func onStreamStopped(_ stream: StreamCategory?) {
        if let stream {
            print("stream stopped: \(stream)")
        }
    }

    func onConsoleLine(_ line: String?) {
        if let line {
            print("console line: \(line)")
        }
    }

    func onTick(_ tick: ExarotonWebSocket.Tick?) {
        if let tick {
            print("tick: \(tick)")
        }
    }

    func onStats(_ stats: ExarotonWebSocket.Stats?) {
        if let stats {
            print("stats: \(stats)")
        }
    }

    func onHeap(_ heap: ExarotonWebSocket.Heap?) {
        if let heap {
            print("heap: \(heap)")
        }
    }

    func onError(_ error: Error) {
        print("error: \(error.localizedDescription)")
    }

    func didReceive(event: Starscream.WebSocketEvent, client: any Starscream.WebSocketClient) {
    }
}
