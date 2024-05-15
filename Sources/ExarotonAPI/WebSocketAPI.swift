//
//  WebSocketAPI.swift
//
//
//  Created by joker on 2024/5/15.
//

import Foundation
import Starscream
import HTTPTypes

final class WebSocketAPI: WebSocketDelegate {

    let token: String

    let serverId: String

    init(token: String, serverId: String) {
        self.token = token
        self.serverId = serverId
    }

    lazy var client: WebSocket = {
        var request = URLRequest(url: URL(string: "https://api.exaroton.com/v1/servers/\(serverId)/websocket")!)
        request.setValue("Bearer \(token)", forHTTPHeaderField: HTTPField.Name.authorization.rawName)
        request.timeoutInterval = 5
        let socket = WebSocket(request: request)
        socket.delegate = self
        return socket
    }()


    var isConnected: Bool = false

    func didReceive(event: WebSocketEvent, client: any WebSocketClient) {
        switch event {
        case .connected(let headers):
            isConnected = true
            print("websocket is connected: \(headers)")
        case .disconnected(let reason, let code):
            isConnected = false
            print("websocket is disconnected: \(reason) with code: \(code)")
        case .text(let string):
            print("Received text: \(string)")
        case .binary(let data):
            print("Received data: \(data.count)")
        case .ping(_):
            break
        case .pong(_):
            break
        case .viabilityChanged(_):
            break
        case .reconnectSuggested(_):
            break
        case .cancelled:
            isConnected = false
        case .error(let error):
            isConnected = false
            handleError(error)
            case .peerClosed:
                   break
        }
    }

    func handleError(_ error: Error?) {

        guard let error else { return }

        print(error.localizedDescription)
    }
}
