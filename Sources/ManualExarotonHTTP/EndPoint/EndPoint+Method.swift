//
//  EndPoint+Method.swift
//
//
//  Created by joker on 2024/5/13.
//

import Foundation

extension EndPoint {

    enum HttpMethod: String {
        case GET
        case POST
        case PUT
        case DELETE
    }

    var httpMethod: HttpMethod {
        switch self {
        case .account:
            return .GET
        case .servers(_, let op):
            guard let op
            else {
                return .GET
            }
            switch op {
            case .logs, .logsShare:
                return .GET
            case .ram(let ram):
                return postIfExist(ram)
            case .motd(let motd):
                return postIfExist(motd)
            case .start(let ownCredits):
                return postIfExist(ownCredits)
            case .command:
                return .POST
            case .playlist(_, let op):
                guard let op
                else {
                    return .GET
                }
                switch op {
                case .add:
                    return .PUT
                case .delete:
                    return .DELETE
                }
            case .fileData(_, let op):
                guard let op
                else {
                    return.GET
                }
                switch op {
                case .write:
                    return .PUT
                case .delete:
                    return .DELETE
                }
            case .fileConfig(_, let kv):
                return postIfExist(kv)
            default:
                return .GET
            }
        default:
            return .GET
        }

        func postIfExist(_ postBody: Codable?) -> HttpMethod { postBody != nil ? .POST : .GET }
    }
}
