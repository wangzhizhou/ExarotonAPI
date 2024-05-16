import Foundation
import ExarotonWebSocket
import Starscream
import Logging

class ExarotonWebSocketEventDelegateHandler: ExarotonServerEventHandlerProtocol {

    let logger = Logger(label: "WebSocketEventDelegateHandler")

    func onReady(serverID: String?) {
        logger.notice("on ready: \(serverID ?? "")")
    }

    func onConnected() {
        logger.notice("on server connected")
    }

    func onDisconnected(reason: String?) {

        logger.notice("on server disconnected: \(reason ?? "")")
    }

    func onKeepAlive() {

        logger.notice("on keep alive")
    }

    func onStatusChanged(_ server: ExarotonWebSocket.Server?) {
        if let server {
            logger.notice("on status: \(server)")
        }
    }

    func onStreamStarted(_ stream: StreamCategory?) {
        if let stream {
            logger.notice("on stream started: \(stream)")
        }
    }

    func onConsoleLine(_ line: String?) {

        if let line {
            logger.notice("on console line: \(line)")
        }
    }

    func onTick(_ tick: ExarotonWebSocket.Tick?) {
        if let tick {
            logger.notice("on tick: \(tick)")
        }
    }

    func onStats(_ stats: ExarotonWebSocket.Stats?) {
        if let stats {
            logger.notice("on stats: \(stats)")
        }
    }

    func onHeap(_ heap: ExarotonWebSocket.Heap?) {
        if let heap {
            logger.notice("on heap: \(heap)")
        }
    }

    func didReceive(event: WebSocketEvent, client: any WebSocketClient) {

        // process the origin starscream events if you need.
    }
}
