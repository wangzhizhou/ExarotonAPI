//
//  File.swift
//
//
//  Created by joker on 2024/5/15.
//

import Foundation

public struct Server: Codable, Identifiable {
    public let id: String
    public let name: String
    public let address: String
    public let motd: String
    public let status: Int
    public let host: String?
    public let port: Int?
    public let players: Players
    public let software: Software?
    public let shared: Bool
}

public struct Players: Codable {
    public let max: Int
    public let count: Int
    public let list: [String]
}

public struct Software: Codable, Identifiable {
    public let id: String
    public let name: String
    public let version: String
}

public struct Tick: Codable {
    public let averageTickTime: Double
}

public struct Stats: Codable {
    public struct Memory: Codable {
        public let percent: Double
        public let usage: Double
    }
    public let memory: Memory

    public struct CPU: Codable {
        public let percent: Double
        public let usage: Double
        public let limit: Int
    }
    public let cpu: CPU
}

public struct Heap: Codable {
    public let usage: Int64
}
