//
//  File.swift
//
//
//  Created by joker on 5/12/24.
//

import Foundation
public struct Response<DataType: Codable>: Codable {
    public let success: Bool
    public var error: String?
    public var data: DataType?
}
enum MIMEType: String {
    case json = "application/json"
    case zip = "application/zip"
    case data = "application/octet-stream"
    case text = "text/plain"
}
