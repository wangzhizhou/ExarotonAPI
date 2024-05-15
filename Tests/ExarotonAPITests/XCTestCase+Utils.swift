//
//  XCTestCase+Utils.swift
//
//
//  Created by joker on 2024/5/15.
//

import XCTest

extension XCTestCase {

    func wait(minutes: Int) async throws {
        try await wait(seconds: minutes * 60)
    }

    func wait(seconds: Int) async throws {
        let delayExpectation = XCTestExpectation()
        delayExpectation.isInverted = true
        await fulfillment(of: [delayExpectation], timeout: Double(seconds))
    }
}
