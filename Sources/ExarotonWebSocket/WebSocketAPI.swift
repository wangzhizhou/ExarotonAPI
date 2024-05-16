//
//  WebSocketAPI.swift
//
//
//  Created by joker on 2024/5/15.
//

import Foundation
import Starscream
import Logging

public final class WebSocketAPI {

    public let token: String

    public let serverId: String

    public let delegate: ServerEventHandlerProtocol?

    public let timeout: Double

    public init(
        token: String,
        serverId: String,
        delegate: ServerEventHandlerProtocol? = nil,
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

extension WebSocketAPI: WebSocketDelegate {

    public func didReceive(event: WebSocketEvent, client: any WebSocketClient) {

        self.delegate?.didReceive(event: event, client: client)

        self._handleEvent(event: event)

    }
}
