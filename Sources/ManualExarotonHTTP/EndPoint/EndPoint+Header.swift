//
//  EndPoint+Header.swift
//
//
//  Created by joker on 2024/5/14.
//

import Foundation

extension EndPoint {

    var contentType: String? {
        switch self {
        case .servers(_, let op):
            guard let op
            else {
                return MIMEType.json.rawValue
            }
            switch op {
            case .fileData(_, let op):
                guard let op
                else {
                    return MIMEType.json.rawValue
                }
                switch op {
                case .write:
                    return MIMEType.data.rawValue
                default:
                    return nil
                }
            default:
                return MIMEType.json.rawValue
            }
        default:
            return MIMEType.json.rawValue
        }
    }
}
