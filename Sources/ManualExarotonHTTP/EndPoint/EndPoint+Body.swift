//
//  EndPoint+Body.swift
//
//
//  Created by joker on 2024/5/13.
//

import Foundation

extension EndPoint {

    var httpBodyModel: Encodable? {
        switch self {
        case .servers(_, let op):
            switch op {
            case .ram(let ram):
                return ram
            case .motd(let motd):
                return motd
            case .start(let ownCredits):
                return ownCredits
            case .command(let command):
                return command
            case .playlist(_, let op):
                guard let op
                else {
                    return nil
                }
                switch op {
                case .add(let addPlayers):
                    return addPlayers
                case .delete(let delPlayers):
                    return delPlayers
                }
            case .fileConfig(_, let kv):
                return kv
            default:
                return nil
            }
        default:
            return nil
        }
    }
}
