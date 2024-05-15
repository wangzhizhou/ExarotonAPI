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

    let socket = WebSocketAPI(
        token: ProcessInfo.processInfo.environment["TOKEN"] ?? "",
        serverId: ProcessInfo.processInfo.environment["SERVER"] ?? ""
    )

    override func setUp() async throws {
        socket.client.connect()
    }

    override func tearDown() async throws {
        socket.client.disconnect()
    }

    func testWebSocketConnectForOneMinutes() async throws {
        let delayExpectation = XCTestExpectation()
        delayExpectation.isInverted = true
        await fulfillment(of: [delayExpectation], timeout: 10)
    }

}
