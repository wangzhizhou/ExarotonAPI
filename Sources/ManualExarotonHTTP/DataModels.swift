//
//  File.swift
//
//
//  Created by joker on 5/12/24.
//

import Foundation
import AnyCodable

// MARK: Account
public struct AccountData: Codable {
    public let name: String
    public let email: String
    public let verified: Bool
    public let credits: Int
}

// MARK: Servers
public struct ServerData: Codable, Identifiable {
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
public struct ServerLogData: Codable {
    let content: String?
}
public struct ServerLogShareData: Codable, Identifiable {
    public let id: String
    public let url: String
    public let raw: String
}
public struct ServerRAMData: Codable {
    public let ram: Int     // 单位：GB, 最小值为2
    public init(ram: Int) {
        self.ram = ram
    }
}
public struct ServerMOTDData: Codable {
    public let motd: String
    public init(motd: String) {
        self.motd = motd
    }
}
public struct ServerStartData: Codable {
    public let useOwnCredits: Bool
    public init(useOwnCredits: Bool) {
        self.useOwnCredits = useOwnCredits
    }
}
public struct ServerCommandData: Codable {
    public let command: String
    public init(command: String) {
        self.command = command
    }
}
public struct PlayerList: Codable {
    public let entries: [String]
    public init(entries: [String]) {
        self.entries = entries
    }
}
// MARK: File Information
public struct ServerFileInfo: Codable {
    public let path: String
    public let name: String
    public let isTextFile: Bool
    public let isConfigFile: Bool
    public let isDirectory: Bool
    public let isLog: Bool
    public let isReadable: Bool
    public let isWritable: Bool
    public let size: Int
    public let children: [ServerFileInfo]?
}

// MARK: File Config Options
public struct ServerFileConfig: Codable {
    public let key: String
    public let value: AnyCodable
    public let label: String
    public enum OptionType: String, Codable {
        case string
        case integer
        case float
        case boolean
        case multiselect
        case select
    }
    public let type: OptionType
    public let options: [String]?
}

// MARK: Credit Pool
public struct CreditPool: Codable, Identifiable {
    public let id: String
    public let name: String
    public let credits: Decimal
    public let servers: Double
    public let owner: String
    public let isOwner: Bool
    public let members: Int
    public let ownShare: Int
    public let ownCredits: Decimal
}
public struct CreditPoolMember: Codable {
    public let account: String
    public let name: String
    public let share: Int
    public let credits: Decimal
    public let isOwner: Bool
}
