//
//  Utils.swift
//
//
//  Created by joker on 2024/5/15.
//

import Foundation
import AnyCodable

extension String {

    func wsMessage<T: Codable>(with type: T.Type) throws -> ExarotonMessage<T>? {
        guard let data = self.data(using: .utf8)
        else {
            return nil
        }
        let message = try JSONDecoder.shared.decode(ExarotonMessage<T>.self, from: data)
        return message
    }
}

struct ExarotonRawMessage: Decodable {
    let stream: StreamCategory?
    let type: String
    let data: AnyCodable?
}

extension String {
    func wsRawMessage() throws -> ExarotonRawMessage? {
        guard let data = self.data(using: .utf8) else { return nil }
        return try JSONDecoder.shared.decode(ExarotonRawMessage.self, from: data)
    }
}

extension JSONDecoder {

    static let shared = JSONDecoder()
}

extension JSONEncoder {
    static let shared = JSONEncoder()
}

extension AnyCodable {
    func convert<T: Decodable>(to type: T.Type) throws -> T {
        let data = try JSONEncoder.shared.encode(self)
        let target = try JSONDecoder.shared.decode(type, from: data)
        return target
    }
}
