//
//  File.swift
//
//
//  Created by joker on 2024/5/16.
//

import Foundation
import ExarotonWebSocket
import Starscream

@main
struct WebSocketUsageDemo {

    static func main() async throws {
        
        let socket = ExarotonWebSocketAPI(
            token: ProcessInfo.processInfo.environment["TOKEN"] ?? "your_account_token",
            serverId: ProcessInfo.processInfo.environment["SERVER"] ?? "your_server_id",
            delegate: ServerEventHandler()
        )
        
        socket.client.connect()
        try await wait(for: socket.timeout)

        let consoleStreamMessage = ExarotonMessage(
            stream: .console,
            type: StreamType.start,
            data: ["tail": 2]
        )
        socket.client.write(stringData: try consoleStreamMessage.toData) {
            print("console stream start completed!")
        }

        try await wait(for: socket.timeout)
        socket.client.disconnect()
    }

    static func wait(for minutes: Double) async throws {
        try await Task.sleep(nanoseconds: UInt64(1_000_000_000 * minutes))
    }
}

final class ServerEventHandler: ExarotonServerEventHandlerProtocol {

    func onReady(serverID: String?) {
        print("server ready: \(serverID ?? "")")
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

    // MARK: WebSocketDelegate
    func didReceive(event: Starscream.WebSocketEvent, client: any Starscream.WebSocketClient) {
        // all events, if you need process them your self
    }
}
