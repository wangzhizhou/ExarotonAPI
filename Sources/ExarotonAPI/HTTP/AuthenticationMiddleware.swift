//
//  AuthenticationMiddleware.swift
//
//
//  Created by joker on 2024/5/14.
//

import Foundation

// The Swift Programming Language
// https://docs.swift.org/swift-book
//
// openapi doc: https://developers.exaroton.com/openapi.yaml
//
// api website: https://developers.exaroton.com/

import OpenAPIRuntime
import OpenAPIURLSession
import HTTPTypes

/// A client middleware that injects a value into the `Authorization` header field of the request.
public struct AuthenticationMiddleware {

    /// The value for the `Authorization` header field.
    public let token: String

    /// Creates a new middleware.
    /// - Parameter value: The value for the `Authorization` header field.
    public init(token: String) { self.token = token }
}

extension AuthenticationMiddleware: ClientMiddleware {

    public func intercept(
        _ request: HTTPRequest,
        body: HTTPBody?,
        baseURL: URL,
        operationID: String,
        next: (HTTPRequest, HTTPBody?, URL) async throws -> (HTTPResponse, HTTPBody?)
    ) async throws -> (HTTPResponse, HTTPBody?) {
        var request = request
        // Adds the `Authorization` header field with the provided value.
        request.headerFields[.authorization] = "Bearer \(token)"
        return try await next(request, body, baseURL)
    }
}
