//
//  ExarotonWebSocketAPI+Internal.swift
//
//
//  Created by joker on 2024/5/15.
//

import Foundation
import Starscream

extension ExarotonWebSocketAPI {

    func _handleEvent(event: WebSocketEvent) {
        do {
            switch event {
            case .connected(let headers):
                logger.debug("[websocket connected]: \(headers)")
            case .disconnected(let reason, let code):
                logger.debug("[websocket disconnected]: \(reason) with code: \(code)")
            case .text(let text):
                logger.debug("[Received text]: \(text)")
                try _handleTextMessage(text)
            case .binary(let data):
                logger.debug("[Received binary]: \(data.count)")
            case .ping(_):
                break
            case .pong(_):
                break
            case .viabilityChanged(_):
                break
            case .reconnectSuggested(_):
                break
            case .cancelled:
                break
            case .error(let error):
                _handleError(error)
            case .peerClosed:
                break
            }
        } catch {
            logger.error(.init(stringLiteral: error.localizedDescription))
            _deliver { $0.onError(error) }
            _yield(.error(error))
        }
    }

    func _handleTextMessage(_ text: String) throws {
        guard let raw = try text.wsRawMessage() else { return }
        if raw.stream == nil {
            guard let type = BasicType(rawValue: raw.type) else { return }
            switch type {
            case .ready:
                let serverId = raw.data?.value as? String
                _deliver { $0.onReady(serverID: serverId) }
                _yield(.ready(serverID: serverId))
            case .connected:
                _deliver { $0.onConnected() }
                _yield(.connected)
            case .disconnected:
                let reason = raw.data?.value as? String
                _deliver { $0.onDisconnected(reason: reason) }
                _yield(.disconnected(reason: reason))
            case .keepAlive:
                _deliver { $0.onKeepAlive() }
                _yield(.keepAlive)
            }
        } else {
            guard let stream = raw.stream else { return }
            guard let type = StreamType(rawValue: raw.type) else { return }
            switch type {
            case .status:
                let info = try raw.data?.convert(to: Server.self)
                _deliver { $0.onStatusChanged(info) }
                _yield(.statusChanged(info))
            case .start, .stop, .command:
                logger.debug("[Received stream control]: \(stream.rawValue) \(type.rawValue)")
            case .started:
                _deliver { $0.onStreamStarted(stream) }
                _yield(.streamStarted(stream))
            case .stopped:
                _deliver { $0.onStreamStopped(stream) }
                _yield(.streamStopped(stream))
            case .line:
                let line = try raw.data?.convert(to: String.self)
                _deliver { $0.onConsoleLine(line) }
                _yield(.consoleLine(line))
            case .tick:
                let tick = try raw.data?.convert(to: Tick.self)
                _deliver { $0.onTick(tick) }
                _yield(.tick(tick))
            case .stats:
                let stats = try raw.data?.convert(to: Stats.self)
                _deliver { $0.onStats(stats) }
                _yield(.stats(stats))
            case .heap:
                let heap = try raw.data?.convert(to: Heap.self)
                _deliver { $0.onHeap(heap) }
                _yield(.heap(heap))
            }
        }
    }

    
    func _handleError(_ error: Error?) {
        guard let error else { return }
        logger.error(.init(stringLiteral: error.localizedDescription))
        _deliver { $0.onError(error) }
        _yield(.error(error))
    }
}
