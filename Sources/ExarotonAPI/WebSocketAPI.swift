//
//  WebSocketAPI.swift
//
//
//  Created by joker on 2024/5/15.
//

import Foundation
import Starscream
import HTTPTypes

struct WebSocketAPI {

    let token: String

    let serverId: String

    let delegate: WebSocketDelegate?

    let onEvent: ((WebSocketEvent) -> Void)?

    let timeout: Double

    init(token: String,
         serverId: String,
         delegate: WebSocketDelegate? = nil,
         onEvent: ((WebSocketEvent) -> Void)? = nil,
         timeout: Double = 5
    ) {
        self.token = token
        self.serverId = serverId
        self.delegate = delegate
        self.onEvent = onEvent
        self.timeout = timeout
    }

    lazy var client: WebSocket = {
        var request = URLRequest(url: URL(string: "https://api.exaroton.com/v1/servers/\(serverId)/websocket")!)
        request.setValue("Bearer \(token)", forHTTPHeaderField: HTTPField.Name.authorization.rawName)
        request.timeoutInterval = timeout
        let socket = WebSocket(request: request)
        socket.delegate = delegate
        socket.onEvent = onEvent
        return socket
    }()
}
