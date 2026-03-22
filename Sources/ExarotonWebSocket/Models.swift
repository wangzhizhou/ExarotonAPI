//
//  File.swift
//
//
//  Created by joker on 2024/5/15.
//

import Foundation

public enum ServerStatus: Int, CaseIterable, Codable, Sendable {
    case OFFLINE = 0
    case ONLINE = 1
    case STARTING = 2
    case STOPPING = 3
    case RESTARTING = 4
    case SAVING = 5
    case LOADING = 6
    case CRASHED = 7
    case PENDING = 8
    case PREPARING = 10
}

public struct Server: Codable, Identifiable, Sendable {
    public let id: String
    public let name: String
    public let address: String
    public let motd: String
    public let status: ServerStatus
    public let host: String?
    public let port: Int?
    public let players: Players
    public let software: Software?
    public let shared: Bool
}

public struct Players: Codable, Sendable {
    public let max: Int
    public let count: Int
    public let list: [String]
}

public struct Software: Codable, Identifiable, Sendable {
    public let id: String
    public let name: String
    public let version: String
}

public struct Tick: Codable, Sendable {
    public let averageTickTime: Double
}

public struct Stats: Codable, Sendable {
    public struct Memory: Codable, Sendable {
        public let percent: Double
        public let usage: Double
    }
    public let memory: Memory

    public struct CPU: Codable, Sendable {
        public let percent: Double
        public let usage: Double
        public let limit: Int
    }
    public let cpu: CPU
}

public struct Heap: Codable, Sendable {
    public let usage: Int64
}
