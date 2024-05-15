//
//  File.swift
//
//
//  Created by joker on 2024/5/15.
//

import Foundation
import Starscream

extension WebSocketAPI {

    func _handleEvent(event: WebSocketEvent) {
        do {
            switch event {
            case .connected(let headers):
                logger.info("[websocket connected]: \(headers)")
            case .disconnected(let reason, let code):
                logger.info("[websocket disconnected]: \(reason) with code: \(code)")
            case .text(let text):
                logger.info("[Received text]: \(text)")
                try _handleTextMessage(text)
            case .binary(let data):
                logger.info("[Received binary]: \(data.count)")
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
        } catch let error {
            fatalError(error.localizedDescription)
        }
    }

    func _handleTextMessage(_ text: String) throws {
        guard let message = try text.wsMessage(with: String.self)
        else {
            return
        }
        if message.stream == nil, let basicMessage = try text.wsMessage(with: BasicType.self) {
            switch basicMessage.type {
            case .ready:
                let serverId = message.data?.value as? String
                self.delegate?.onReady(serverID: serverId)
            case .connected:
                self.delegate?.onConnected()
            case .disconnected:
                let reason = message.data?.value as? String
                self.delegate?.onDisconnected(reason: reason)
            case .keepAlive:
                self.delegate?.onKeepAlive()
            }
        } else if let streamMessage = try text.wsMessage(with: StreamType.self)  {
            switch streamMessage.type {
            case .status:
                try self.delegate?.onStatusChanged(streamMessage.data?.convert(to: Server.self))
            case .start, .stop, .command:
                break
            case .started:
                self.delegate?.onStreamStarted(streamMessage.stream)
            case .line:
                try self.delegate?.onConsoleLine(streamMessage.data?.convert(to: String.self))
            case .tick:
                try self.delegate?.onTick(streamMessage.data?.convert(to: Tick.self))
            case .stats:
                try self.delegate?.onStats(streamMessage.data?.convert(to: Stats.self))
            case .heap:
                try self.delegate?.onHeap(streamMessage.data?.convert(to: Heap.self))
            }
        }
    }

    
    func _handleError(_ error: Error?) {
        guard let error else { return }
        logger.error(.init(stringLiteral: error.localizedDescription))
    }
}
