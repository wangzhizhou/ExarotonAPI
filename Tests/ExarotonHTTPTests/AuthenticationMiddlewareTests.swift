import Testing
import ExarotonHTTP
import HTTPTypes
import OpenAPIRuntime
import Foundation

final class AuthenticationMiddlewareTests {
    @Test
    func testAuthenticationMiddlewareAddsAuthorizationHeader() async throws {
        let middleware = AuthenticationMiddleware(token: "test-token")
        let request = HTTPRequest(
            method: .get,
            scheme: "https",
            authority: "api.exaroton.com",
            path: "/test"
        )
        var receivedAuthorization: String?
        _ = try await middleware.intercept(
            request,
            body: nil,
            baseURL: URL(string: "https://api.exaroton.com")!,
            operationID: "test"
        ) { req, _, _ in
            receivedAuthorization = req.headerFields[.authorization]
            return (HTTPResponse(status: .ok), nil)
        }
        #expect(receivedAuthorization == "Bearer test-token")
    }
}
