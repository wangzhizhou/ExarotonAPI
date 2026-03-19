//
//  ExarotonWebSocketAPI.swift
//
//
//  Created by joker on 2024/5/15.
//

import Foundation
import Starscream
import Logging
import AnyCodable

public final class ExarotonWebSocketAPI {

    public let token: String

    public let serverId: String

    public let delegate: ExarotonServerEventHandlerProtocol?

    public let timeout: Double

    public init(
        token: String,
        serverId: String,
        delegate: ExarotonServerEventHandlerProtocol? = nil,
        timeout: Double = 5
    ) {
        self.token = token
        self.serverId = serverId
        self.delegate = delegate
        self.timeout = timeout
    }

    public lazy var client: WebSocket = {
        var request = URLRequest(url: URL(string: "https://api.exaroton.com/v1/servers/\(serverId)/websocket")!)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.timeoutInterval = timeout
        let socket = WebSocket(request: request)
        socket.delegate = self
        return socket
    }()

    let logger = Logger(label: "WebSocket")
}

extension ExarotonWebSocketAPI: WebSocketDelegate {

    public func didReceive(event: WebSocketEvent, client: any WebSocketClient) {

        self.delegate?.didReceive(event: event, client: client)

        self._handleEvent(event: event)

    }
}

public extension ExarotonWebSocketAPI {

    func connect() {
        client.connect()
    }

    func disconnect() {
        client.disconnect()
    }

    func send<T: Codable>(message: ExarotonMessage<T>) throws {
        let data = try message.toData
        client.write(stringData: data, completion: nil)
    }

    func send<T: Codable>(message: ExarotonMessage<T>, completion: (() -> Void)?) throws {
        let data = try message.toData
        client.write(stringData: data, completion: completion)
    }

    func startStream(_ stream: StreamCategory, tail: Int? = nil, completion: (() -> Void)? = nil) throws {
        if stream == .console {
            let payload: [String: Any] = ["tail": tail ?? 0]
            let message = ExarotonMessage(stream: stream, type: StreamType.start, data: .init(payload))
            try send(message: message, completion: completion)
        } else {
            let message = ExarotonMessage(stream: stream, type: StreamType.start, data: nil)
            try send(message: message, completion: completion)
        }
    }

    func stopStream(_ stream: StreamCategory, completion: (() -> Void)? = nil) throws {
        let message = ExarotonMessage(stream: stream, type: StreamType.stop, data: nil)
        try send(message: message, completion: completion)
    }

    func sendConsoleCommand(_ command: String, completion: (() -> Void)? = nil) throws {
        let message = ExarotonMessage(stream: .console, type: StreamType.command, data: .init(command))
        try send(message: message, completion: completion)
    }
}
