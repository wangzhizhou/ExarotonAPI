//
//  EndPoint+Path.swift
//
//
//  Created by joker on 2024/5/13.
//

import Foundation

extension EndPoint {

    var path: String {
        switch self {
        case .account:
            return "/account"
        case .servers(let serverId, let op):
            var component = "/servers"
            if let serverId {
                component += "/\(serverId)"
            }
            guard let op
            else {
                return component
            }
            switch op {
            case .logs:
                component += "/logs"
            case .logsShare:
                component += "/logs/share"
            case .ram:
                component += "/options/ram"
            case .motd:
                component += "/options/motd"
            case .start:
                component += "/start"
            case .stop:
                component += "/stop"
            case .restart:
                component += "/restart"
            case .command:
                component += "/command"
            case .playlist(let type, _):
                component += "/playerlists"
                if let type {
                    component += "/\(type)"
                }
            case .fileInfo(let path):
                component += "/files/info/\(path)"
            case .fileData(let path, _):
                component += "/files/data/\(path)"
            case .fileConfig(let path, _):
                component += "/files/config/\(path)"
            }
            return component
        case .creditPool(let pollId, let op):
            var component = "/billing/pools"
            if let pollId {
                component += "/\(pollId)"
            }
            guard let op
            else {
                return component
            }
            switch op {
            case .members:
                component += "/members"
            case .servers:
                component += "/servers"
            }
            return component
        }
    }
}
