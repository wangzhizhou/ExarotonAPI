//
//  HttpUsageDemo.swift
//
//
//  Created by joker on 2024/5/16.
//

import Foundation
import ExarotonHTTP
import OpenAPIRuntime
import OpenAPIURLSession

@main
struct HttpUsageDemo {
    static func main() async throws {

        let yourAccountToken = ProcessInfo.processInfo.environment["TOKEN"] ?? ""

        let client = Client(
            serverURL: try! Servers.Server1.url(),
            transport: URLSessionTransport(),
            middlewares: [AuthenticationMiddleware(token: yourAccountToken)]
        )
        let response = try await client.getAccount()

        switch response {
        case .ok(let ok):
            if let data = try ok.body.json.data,
               let name = data.name {
                print("account: \(name)")
            }
        case .forbidden(let forbidden):
            let json = try forbidden.body.json
            print(json.error ?? "")
        case .undocumented(let statusCode, let unknownPayload):
            print("statusCode:\(statusCode), payload: \(unknownPayload)")
        }
    }
}
