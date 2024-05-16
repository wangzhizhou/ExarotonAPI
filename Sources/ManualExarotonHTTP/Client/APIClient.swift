//
//  ExarotonAPI.swift
//
//
//  Created by joker on 5/11/24.
//
//
//  exaroton API Doc: https://developers.exaroton.com/

import Foundation
public struct APIClient {
    public let baseUrl: String
    public let token: String
    public init(baseUrl: String, token: String) {
        self.baseUrl = baseUrl
        self.token = token
    }
}
extension APIClient {
    static let jsonEncoder = {
        let jsonEncoder = JSONEncoder()
        return jsonEncoder
    }()
    static let jsonDecoder = {
        let jsonDecoder = JSONDecoder()
        return jsonDecoder
    }()
    static let session = {
        let configuration = URLSessionConfiguration.default
        return URLSession(configuration: configuration)
    }()
    public func request<DataType: Codable>(_ endpoint: EndPoint, dataType: DataType.Type) async throws -> Response<DataType>? {
        guard let URL = URL(string: "\(baseUrl)\(endpoint.path)")
        else {
            throw APIError.badUrlOrPath
        }
        var req = URLRequest(url: URL)
        req.httpMethod = endpoint.httpMethod.rawValue
        req.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        if let postBody = endpoint.httpBodyModel {
            req.setValue(endpoint.contentType, forHTTPHeaderField: "Content-Type")
            req.httpBody = try APIClient.jsonEncoder.encode(postBody)
        }
        let (data, response) = try await APIClient.session.data(for: req)
        var responseModel = Response<DataType>(success: (response as? HTTPURLResponse)?.statusCode == 200)
        guard let mime = response.mimeType, let mimeType = MIMEType(rawValue: mime)
        else {
            throw APIError.unknownMIME
        }
        switch mimeType {
        case .json:
            print(String(data:data, encoding: .utf8)!)
            let jsonModel = try APIClient.jsonDecoder.decode(Response<DataType>.self, from: data)
            return jsonModel
        default:
            guard let data = data as? DataType
            else {
                throw APIError.convertDataFailed
            }
            responseModel.data = data
        }
        return responseModel
    }
}

enum APIError: Error {
    case unknownMIME
    case convertDataFailed
    case badUrlOrPath
}
