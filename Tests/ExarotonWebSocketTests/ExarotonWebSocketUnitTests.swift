import Testing
import ExarotonWebSocket
import AnyCodable
import Foundation

private func decodeAnyCodable<T: Decodable>(_ value: AnyCodable?, as type: T.Type) throws -> T? {
    guard let value else { return nil }
    let data = try JSONEncoder().encode(value)
    return try JSONDecoder().decode(type, from: data)
}

final class ExarotonWebSocketUnitTests {
    @Test
    func testDecodeReadyMessage() throws {
        let text = #"{"type":"ready","data":"server-id"}"#
        let data = Data(text.utf8)
        let message = try JSONDecoder().decode(ExarotonMessage<BasicType>.self, from: data)
        #expect(message.type == .ready)
        #expect(message.stream == nil)
        #expect(message.data?.value as? String == "server-id")
    }

    @Test
    func testDecodeConsoleLineMessage() throws {
        let text = #"{"stream":"console","type":"line","data":"hello"}"#
        let data = Data(text.utf8)
        let message = try JSONDecoder().decode(ExarotonMessage<StreamType>.self, from: data)
        #expect(message.stream == .console)
        #expect(message.type == .line)
        let line = try decodeAnyCodable(message.data, as: String.self)
        #expect(line == "hello")
    }

    @Test
    func testEncodeDecodeMessageRoundTrip() throws {
        let message = ExarotonMessage(
            stream: .console,
            type: StreamType.start,
            data: AnyCodable(["tail": 2])
        )
        let data = try message.toData
        let decoded = try JSONDecoder().decode(ExarotonMessage<StreamType>.self, from: data)
        #expect(decoded.stream == .console)
        #expect(decoded.type == .start)
        let dict = try decodeAnyCodable(decoded.data, as: [String: Int].self)
        #expect(dict?["tail"] == 2)
    }

    @Test
    func testWsMessageInvalidJsonThrows() {
        #expect(throws: (any Error).self) {
            _ = try JSONDecoder().decode(
                ExarotonMessage<BasicType>.self,
                from: Data("not-json".utf8)
            )
        }
    }
}
