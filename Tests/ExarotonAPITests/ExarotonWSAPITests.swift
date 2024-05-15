//
//  File.swift
//
//
//  Created by joker on 2024/5/15.
//

import Foundation
import XCTest
@testable import ExarotonAPI

final class ExarotonWSAPITests: XCTestCase {

    static let handler = WebSocketEventDelegateHandler()

    var socket = WebSocketAPI(
        token: ProcessInfo.processInfo.environment["TOKEN"] ?? "",
        serverId: ProcessInfo.processInfo.environment["SERVER"] ?? "",
        delegate: handler
    )

    override func setUp() async throws {
        socket.client.connect()
        try await wait(seconds: Int(socket.timeout))
    }

    override func tearDown() async throws {
        try await wait(seconds: Int(socket.timeout))
        socket.client.disconnect()
    }

    func testStartConsoleStream() async throws {
        let message = WebSocketAPIMessage(
            stream: .console,
            type: StreamType.start,
            data: ["tail": 10]
        )
        let data = try data(for: message)
        socket.client.write(stringData: data, completion: nil)
    }

    func testStopConsoleStream() async throws {
        let message = WebSocketAPIMessage(
            stream: .console,
            type: StreamType.stop,
            data: nil
        )
        let data = try data(for: message)
        socket.client.write(stringData: data, completion: nil)
    }

    func testSendConsoleCommandStream() async throws {
        let message = WebSocketAPIMessage(
            stream: .console,
            type: StreamType.command,
            data: "say Hello, ExarotonWSAPITests"
        )
        let data = try data(for: message)
        socket.client.write(stringData: data, completion: nil)

    }

    func testStartTickStream() async throws {
        let message = WebSocketAPIMessage(
            stream: .tick,
            type: StreamType.start,
            data: nil
        )
        let data = try data(for: message)
        socket.client.write(stringData: data, completion: nil)
    }

    func testStopTickStream() async throws {
        let message = WebSocketAPIMessage(
            stream: .tick,
            type: StreamType.stop,
            data: nil
        )
        let data = try data(for: message)
        socket.client.write(stringData: data, completion: nil)
    }

    func testStartStatsStream() async throws {
        let message = WebSocketAPIMessage(
            stream: .stats,
            type: StreamType.start,
            data: nil
        )
        let data = try data(for: message)
        socket.client.write(stringData: data, completion: nil)
    }

    func testStopStatsStream() async throws {
        let message = WebSocketAPIMessage(
            stream: .stats,
            type: StreamType.stop,
            data: nil
        )
        let data = try data(for: message)
        socket.client.write(stringData: data, completion: nil)
    }

    func testStartHeapStream() async throws {
        let message = WebSocketAPIMessage(
            stream: .heap,
            type: StreamType.start,
            data: nil
        )
        let data = try data(for: message)
        socket.client.write(stringData: data, completion: nil)
    }

    func testStopHeapStream() async throws {
        let message = WebSocketAPIMessage(
            stream: .heap,
            type: StreamType.stop,
            data: nil
        )
        let data = try data(for: message)
        socket.client.write(stringData: data, completion: nil)
    }
}

extension ExarotonWSAPITests {

    func wait(minutes: Int) async throws {
        try await wait(seconds: minutes * 60)
    }

    func wait(seconds: Int) async throws {
        let delayExpectation = XCTestExpectation()
        delayExpectation.isInverted = true
        await fulfillment(of: [delayExpectation], timeout: Double(seconds))
    }

    func data<T: Codable>(for message: WebSocketAPIMessage<T>) throws -> Data {
        return try JSONEncoder().encode(message)
    }
}

import Starscream
final class WebSocketEventDelegateHandler: WebSocketDelegate {

    var isConnected: Bool = false

    let jsonDecoder = JSONDecoder()

    func didReceive(event: WebSocketEvent, client: any WebSocketClient) {

        do {
            switch event {
            case .connected(let headers):
                isConnected = true
                print("websocket is connected: \(headers)")
            case .disconnected(let reason, let code):
                isConnected = false
                print("websocket is disconnected: \(reason) with code: \(code)")
            case .text(let text):
                print("Received text: \(text)")
                try handleTextMessage(text)
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
        } catch let error {
            handleError(error)
        }
    }

    func handleError(_ error: Error?) {

        guard let error else { return }

        print(error.localizedDescription)
    }

    func handleTextMessage(_ text: String) throws {
        guard let message = try text.wsMessage(with: String.self)
        else {
            return
        }
        if message.stream == nil, let basicMessage = try text.wsMessage(with: BasicType.self) {
            switch basicMessage.type {
            case .ready:
                if let serverID = message.data {
                    print("serverID: \(serverID)")
                }
            case .connected:
                print("connected")
            case .disconnected:
                let reason = message.data
                print("disconnected: \(reason ?? "")")
            case .keepAlive:
                print(message.data ?? "")
            }
        } else if let streamMessage = try text.wsMessage(with: StreamType.self)  {
            switch streamMessage.type {

            case .status:
                print(streamMessage.data)
            case .start, .stop, .command:
                break
            case .started:
                print(streamMessage)
            case .line:
                print(streamMessage.data)
            case .tick:
                print(streamMessage.data)
            case .stats:
                print(streamMessage.data)
            case .heap:
                print(streamMessage.data)
            }
        }
    }
}
