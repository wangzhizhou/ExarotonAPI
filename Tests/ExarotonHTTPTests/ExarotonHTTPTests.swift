import Testing
import ExarotonHTTP
import OpenAPIRuntime
import OpenAPIURLSession
import Foundation

private func env(_ key: String) -> String {
    ProcessInfo.processInfo.environment[key] ?? ""
}

private func hasEnv(_ key: String) -> Bool {
    !env(key).isEmpty
}

private func hasEnv(_ keys: [String]) -> Bool {
    keys.allSatisfy(hasEnv)
}

@Suite(Tag.List.tags(.integration, .http))
final class ExarotonHTTPTests {
    func makeClient() -> Client {
        Client(
            serverURL: try! Servers.Server1.url(),
            transport: URLSessionTransport(),
            middlewares: [AuthenticationMiddleware(token: env("TOKEN"))]
        )
    }

    @Test(.enabled(if: hasEnv("TOKEN"), "Missing environment variable: TOKEN"))
    func testGetAccountInfoIntegration() async throws {
        let client = makeClient()
        let response = try await client.getAccount()
        let data = try response.ok.body.json.data
        #expect(data != nil)
    }

    @Test(.enabled(if: hasEnv("TOKEN"), "Missing environment variable: TOKEN"))
    func testListServersIntegration() async throws {
        let client = makeClient()
        let response = try await client.getServers()
        let data = try response.ok.body.json.data
        #expect(data != nil)
    }

    @Test(.enabled(if: hasEnv(["TOKEN", "SERVER"]), "Missing environment variable: TOKEN or SERVER"))
    func testGetAServerIntegration() async throws {
        let client = makeClient()
        let response = try await client.getServer(path: .init(serverId: env("SERVER")))
        let data = try response.ok.body.json.data
        #expect(data != nil)
    }
}
