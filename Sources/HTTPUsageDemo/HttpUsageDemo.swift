import Foundation
import ExarotonHTTP
import OpenAPIRuntime
import OpenAPIURLSession

@main
struct HttpUsageDemo {
    static func main() async throws {
        let token = ProcessInfo.processInfo.environment["TOKEN"] ?? ""
        let serverId = ProcessInfo.processInfo.environment["SERVER"] ?? ""
        guard !token.isEmpty else {
            print("Missing env TOKEN. Example: TOKEN=... swift run HTTPUsageDemo")
            return
        }

        let client = Client(
            serverURL: try! Servers.Server1.url(),
            transport: URLSessionTransport(),
            middlewares: [AuthenticationMiddleware(token: token)]
        )

        let accountResponse = try await client.getAccount()
        switch accountResponse {
        case .ok(let ok):
            let account = try ok.body.json.data
            print("Account: \(account?.name ?? "-")")
        case .forbidden(let forbidden):
            let json = try forbidden.body.json
            print("Forbidden: \(json.error ?? "-")")
        case .undocumented(let statusCode, let unknownPayload):
            print("Unexpected status: \(statusCode), payload: \(unknownPayload)")
        }

        let serversResponse = try await client.getServers()
        switch serversResponse {
        case .ok(let ok):
            let servers = try ok.body.json.data ?? []
            print("Servers: \(servers.count)")
            if let first = servers.first {
                print("First server: \(first.id ?? "-") \(first.name ?? "-") status=\(first.status?.rawValue ?? -1)")
            }
        case .badRequest(let badRequest):
            let json = try badRequest.body.json
            print("Bad request: \(json.error ?? "-")")
        case .forbidden(let forbidden):
            let json = try forbidden.body.json
            print("Forbidden: \(json.error ?? "-")")
        case .notFound(let notFound):
            let json = try notFound.body.json
            print("Not found: \(json.error ?? "-")")
        case .internalServerError(let internalServerError):
            let json = try internalServerError.body.json
            print("Internal error: \(json.error ?? "-")")
        case .undocumented(let statusCode, let unknownPayload):
            print("Unexpected status: \(statusCode), payload: \(unknownPayload)")
        }

        if !serverId.isEmpty {
            let serverResponse = try await client.getServer(path: .init(serverId: serverId))
            switch serverResponse {
            case .ok(let ok):
                let server = try ok.body.json.data
                print("Server: \(server?.id ?? "-") \(server?.name ?? "-")")
            case .badRequest(let badRequest):
                let json = try badRequest.body.json
                print("Bad request: \(json.error ?? "-")")
            case .notFound(let notFound):
                let json = try notFound.body.json
                print("Not found: \(json.error ?? "-")")
            case .forbidden(let forbidden):
                let json = try forbidden.body.json
                print("Forbidden: \(json.error ?? "-")")
            case .internalServerError(let internalServerError):
                let json = try internalServerError.body.json
                print("Internal error: \(json.error ?? "-")")
            case .undocumented(let statusCode, let unknownPayload):
                print("Unexpected status: \(statusCode), payload: \(unknownPayload)")
            }
        } else {
            print("Tip: set env SERVER=... to query a specific server.")
        }
    }
}
