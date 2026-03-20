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

    public weak var delegate: (any ExarotonServerEventHandlerProtocol)?

    public let timeout: Double

    public let callbackQueue: DispatchQueue

    private var eventContinuation: AsyncStream<ExarotonWebSocketEvent>.Continuation?
    private var eventContinuationToken: UUID?
    private let eventLock = NSLock()

    public init(
        token: String,
        serverId: String,
        delegate: ExarotonServerEventHandlerProtocol? = nil,
        timeout: Double = 5,
        callbackQueue: DispatchQueue = .main
    ) {
        self.token = token
        self.serverId = serverId
        self.delegate = delegate
        self.timeout = timeout
        self.callbackQueue = callbackQueue
    }

    private lazy var client: WebSocket = {
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

        _deliver { $0.didReceive(event: event, client: client) }

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

    func events() -> AsyncStream<ExarotonWebSocketEvent> {
        AsyncStream { continuation in
            let token = UUID()
            eventLock.lock()
            eventContinuation?.finish()
            eventContinuation = continuation
            eventContinuationToken = token
            eventLock.unlock()

            continuation.onTermination = { @Sendable _ in
                self.eventLock.lock()
                if self.eventContinuationToken == token {
                    self.eventContinuation = nil
                    self.eventContinuationToken = nil
                }
                self.eventLock.unlock()
            }
        }
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

extension ExarotonWebSocketAPI {
    func _deliver(_ body: @escaping @Sendable (any ExarotonServerEventHandlerProtocol) -> Void) {
        guard let delegate else { return }
        callbackQueue.async { body(delegate) }
    }

    func _yield(_ event: ExarotonWebSocketEvent) {
        eventLock.lock()
        let continuation = eventContinuation
        eventLock.unlock()
        continuation?.yield(event)
    }
}
