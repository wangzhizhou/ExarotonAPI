import Foundation
import HTTPTypes
import OpenAPIRuntime

struct MockTransport: ClientTransport {
    let handler: @Sendable (HTTPRequest, HTTPBody?, URL, String) async throws -> (HTTPResponse, HTTPBody?)

    func send(_ request: HTTPRequest, body: HTTPBody?, baseURL: URL, operationID: String) async throws -> (
        HTTPResponse, HTTPBody?
    ) {
        try await handler(request, body, baseURL, operationID)
    }
}

actor TransportCapture {
    private(set) var request: HTTPRequest?
    private(set) var body: HTTPBody?
    private(set) var baseURL: URL?
    private(set) var operationID: String?

    func record(_ request: HTTPRequest, body: HTTPBody?, baseURL: URL, operationID: String) {
        self.request = request
        self.body = body
        self.baseURL = baseURL
        self.operationID = operationID
    }
}

func makeJSONBody(_ object: Any) throws -> HTTPBody {
    let data = try JSONSerialization.data(withJSONObject: object)
    return HTTPBody(data)
}

func makeResponse(status: HTTPResponse.Status, contentType: String? = nil) -> HTTPResponse {
    var response = HTTPResponse(status: status)
    if let contentType {
        response.headerFields[.contentType] = contentType
    }
    return response
}
