//
//  File.swift
//
//
//  Created by joker on 2024/5/15.
//

import Foundation
import XCTest
import ExarotonAPI

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
        let message = ExarotonMessage(
            stream: .console,
            type: StreamType.start,
            data: ["tail": 5]
        )
        let data = try message.toData
        socket.client.write(stringData: data, completion: nil)
    }

    func testStopConsoleStream() async throws {
        let message = ExarotonMessage(
            stream: .console,
            type: StreamType.stop,
            data: nil
        )
        let data = try message.toData
        socket.client.write(stringData: data, completion: nil)
    }

    func testSendConsoleCommandStream() async throws {
        let message = ExarotonMessage(
            stream: .console,
            type: StreamType.command,
            data: "say Hello"
        )
        let data = try message.toData
        socket.client.write(stringData: data, completion: nil)

    }

    func testStartTickStream() async throws {
        let message = ExarotonMessage(
            stream: .tick,
            type: StreamType.start,
            data: nil
        )
        let data = try message.toData
        socket.client.write(stringData: data, completion: nil)
    }

    func testStopTickStream() async throws {
        let message = ExarotonMessage(
            stream: .tick,
            type: StreamType.stop,
            data: nil
        )
        let data = try message.toData
        socket.client.write(stringData: data, completion: nil)
    }

    func testStartStatsStream() async throws {
        let message = ExarotonMessage(
            stream: .stats,
            type: StreamType.start,
            data: nil
        )
        let data = try message.toData
        socket.client.write(stringData: data, completion: nil)
    }

    func testStopStatsStream() async throws {
        let message = ExarotonMessage(
            stream: .stats,
            type: StreamType.stop,
            data: nil
        )
        let data = try message.toData
        socket.client.write(stringData: data, completion: nil)
    }

    func testStartHeapStream() async throws {
        let message = ExarotonMessage(
            stream: .heap,
            type: StreamType.start,
            data: nil
        )
        let data = try message.toData
        socket.client.write(stringData: data, completion: nil)
    }

    func testStopHeapStream() async throws {
        let message = ExarotonMessage(
            stream: .heap,
            type: StreamType.stop,
            data: nil
        )
        let data = try message.toData
        socket.client.write(stringData: data, completion: nil)
    }
}
