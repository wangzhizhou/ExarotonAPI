import Testing
import ExarotonHTTP
import OpenAPIRuntime
import HTTPTypes
import Foundation

@Suite(Tag.List.tags(.unit, .http, .transport))
final class ExarotonHTTPUnitTests: Sendable {
    let token = "test-token"
    let serverId = "EwYiY9IAMtQBTb6U"
    let poolId = "X4iJREgqBGFSBtn0"
    let player = "ExarotonAPITests_Player"
    let filePath = "ExarotonAPITests_Test_File"

    func makeClient(transport: some ClientTransport) -> Client {
        Client(
            serverURL: try! Servers.Server1.url(),
            transport: transport,
            middlewares: [AuthenticationMiddleware(token: token)]
        )
    }

    func requireAuth(_ request: HTTPRequest) {
        #expect(request.headerFields[.authorization] == "Bearer \(token)")
    }
}

extension ExarotonHTTPUnitTests {
    @Test
    func testGetAccountInfo() async throws {
        let capture = TransportCapture()
        let transport = MockTransport { request, body, baseURL, operationID in
            await capture.record(request, body: body, baseURL: baseURL, operationID: operationID)
            let response = makeResponse(status: .ok)
            let responseBody = try makeJSONBody([
                "success": true,
                "error": NSNull(),
                "data": [
                    "name": "example",
                    "email": "example@exaroton.com",
                    "verified": true,
                    "credits": 42.05
                ]
            ])
            return (response, responseBody)
        }
        let client = makeClient(transport: transport)
        let response = try await client.getAccount()
        let data = try response.ok.body.json.data
        #expect(data?.name == "example")

        let request = await capture.request
        #expect(await capture.operationID == "getAccount")
        #expect(request?.method == .get)
        #expect(request?.path == "/account/")
        if let request { requireAuth(request) }
    }

    @Test
    func testListServers() async throws {
        let capture = TransportCapture()
        let transport = MockTransport { request, body, baseURL, operationID in
            await capture.record(request, body: body, baseURL: baseURL, operationID: operationID)
            let response = makeResponse(status: .ok)
            let responseBody = try makeJSONBody([
                "success": true,
                "error": NSNull(),
                "data": [
                    [
                        "id": self.serverId,
                        "name": "example",
                        "status": 1
                    ]
                ]
            ])
            return (response, responseBody)
        }
        let client = makeClient(transport: transport)
        let response = try await client.getServers()
        let data = try response.ok.body.json.data
        #expect(data?.first?.id == serverId)

        let request = await capture.request
        #expect(await capture.operationID == "getServers")
        #expect(request?.method == .get)
        #expect(request?.path == "/servers/")
        if let request { requireAuth(request) }
    }

    @Test
    func testGetAServer() async throws {
        let capture = TransportCapture()
        let transport = MockTransport { request, body, baseURL, operationID in
            await capture.record(request, body: body, baseURL: baseURL, operationID: operationID)
            let response = makeResponse(status: .ok)
            let responseBody = try makeJSONBody([
                "success": true,
                "error": NSNull(),
                "data": [
                    "id": self.serverId,
                    "name": "example",
                    "status": 1
                ]
            ])
            return (response, responseBody)
        }
        let client = makeClient(transport: transport)
        let response = try await client.getServer(path: .init(serverId: serverId))
        let data = try response.ok.body.json.data
        #expect(data?.id == serverId)

        let request = await capture.request
        #expect(await capture.operationID == "getServer")
        #expect(request?.method == .get)
        #expect(request?.path == "/servers/\(serverId)/")
        if let request { requireAuth(request) }
    }

    @Test
    func testGetAServerLog() async throws {
        let capture = TransportCapture()
        let transport = MockTransport { request, body, baseURL, operationID in
            await capture.record(request, body: body, baseURL: baseURL, operationID: operationID)
            let response = makeResponse(status: .ok)
            let responseBody = try makeJSONBody([
                "success": true,
                "error": NSNull(),
                "data": [
                    "content": "[16:14:36] [main/INFO]: test"
                ]
            ])
            return (response, responseBody)
        }
        let client = makeClient(transport: transport)
        let response = try await client.getServerLog(path: .init(serverId: serverId))
        let data = try response.ok.body.json.data
        #expect(data?.content?.isEmpty == false)

        let request = await capture.request
        #expect(await capture.operationID == "getServerLog")
        #expect(request?.method == .get)
        #expect(request?.path == "/servers/\(serverId)/logs/")
        if let request { requireAuth(request) }
    }

    @Test
    func testUploadAServerLog() async throws {
        let capture = TransportCapture()
        let transport = MockTransport { request, body, baseURL, operationID in
            await capture.record(request, body: body, baseURL: baseURL, operationID: operationID)
            let response = makeResponse(status: .ok)
            let responseBody = try makeJSONBody([
                "success": true,
                "error": NSNull(),
                "data": [
                    "id": "zCcf8T5",
                    "url": "https://mclo.gs/zCcf8T5",
                    "raw": "https://api.mclo.gs/1/raw/zCcf8T5"
                ]
            ])
            return (response, responseBody)
        }
        let client = makeClient(transport: transport)
        let response = try await client.shareServerLog(path: .init(serverId: serverId))
        let json = try response.ok.body.json
        #expect(json.success == true)
        #expect(json.data?.url?.isEmpty == false)

        let request = await capture.request
        #expect(await capture.operationID == "shareServerLog")
        #expect(request?.method == .get)
        #expect(request?.path == "/servers/\(serverId)/logs/share/")
        if let request { requireAuth(request) }
    }

    @Test
    func testGetServerRAM() async throws {
        let capture = TransportCapture()
        let transport = MockTransport { request, body, baseURL, operationID in
            await capture.record(request, body: body, baseURL: baseURL, operationID: operationID)
            let response = makeResponse(status: .ok)
            let responseBody = try makeJSONBody([
                "success": true,
                "error": NSNull(),
                "data": [
                    "ram": 5
                ]
            ])
            return (response, responseBody)
        }
        let client = makeClient(transport: transport)
        let response = try await client.getServerRam(path: .init(serverId: serverId))
        let data = try response.ok.body.json.data
        #expect(data?.ram == 5)

        let request = await capture.request
        #expect(await capture.operationID == "getServerRam")
        #expect(request?.method == .get)
        #expect(request?.path == "/servers/\(serverId)/options/ram/")
        if let request { requireAuth(request) }
    }

    @Test
    func testChangeServerRAM() async throws {
        let capture = TransportCapture()
        let transport = MockTransport { request, body, baseURL, operationID in
            await capture.record(request, body: body, baseURL: baseURL, operationID: operationID)
            #expect(request.headerFields[.contentType]?.contains("application/json") == true)
            let requestData = try await Data(collecting: #require(body), upTo: .max)
            let requestJSON = try JSONSerialization.jsonObject(with: requestData) as? [String: Any]
            #expect(requestJSON?["ram"] as? Int == 2)

            let response = makeResponse(status: .ok)
            let responseBody = try makeJSONBody([
                "success": true,
                "error": NSNull(),
                "data": [
                    "ram": 2
                ]
            ])
            return (response, responseBody)
        }
        let client = makeClient(transport: transport)
        let response = try await client.postServerRam(.init(
            path: .init(serverId: serverId),
            body: .json(.init(ram: 2))
        ))
        let json = try response.ok.body.json
        #expect(json.data?.ram == 2)

        let request = await capture.request
        #expect(await capture.operationID == "postServerRam")
        #expect(request?.method == .post)
        #expect(request?.path == "/servers/\(serverId)/options/ram/")
        if let request { requireAuth(request) }
    }

    @Test
    func testGetServerMOTD() async throws {
        let capture = TransportCapture()
        let transport = MockTransport { request, body, baseURL, operationID in
            await capture.record(request, body: body, baseURL: baseURL, operationID: operationID)
            let response = makeResponse(status: .ok)
            let responseBody = try makeJSONBody([
                "success": true,
                "error": NSNull(),
                "data": [
                    "motd": "Hello"
                ]
            ])
            return (response, responseBody)
        }
        let client = makeClient(transport: transport)
        let response = try await client.getServerMotd(path: .init(serverId: serverId))
        let data = try response.ok.body.json.data
        #expect(data?.motd == "Hello")

        let request = await capture.request
        #expect(await capture.operationID == "getServerMotd")
        #expect(request?.method == .get)
        #expect(request?.path == "/servers/\(serverId)/options/motd/")
        if let request { requireAuth(request) }
    }

    @Test
    func testChangeServerMOTD() async throws {
        let dstMOTD = "§7Welcome"
        let capture = TransportCapture()
        let transport = MockTransport { request, body, baseURL, operationID in
            await capture.record(request, body: body, baseURL: baseURL, operationID: operationID)
            #expect(request.headerFields[.contentType]?.contains("application/json") == true)
            let requestData = try await Data(collecting: #require(body), upTo: .max)
            let requestJSON = try JSONSerialization.jsonObject(with: requestData) as? [String: Any]
            #expect(requestJSON?["motd"] as? String == dstMOTD)

            let response = makeResponse(status: .ok)
            let responseBody = try makeJSONBody([
                "success": true,
                "error": NSNull(),
                "data": [
                    "motd": dstMOTD
                ]
            ])
            return (response, responseBody)
        }
        let client = makeClient(transport: transport)
        let response = try await client.postServerMotd(
            path: .init(serverId: serverId),
            body: .json(.init(motd: dstMOTD))
        )
        let data = try response.ok.body.json.data
        #expect(data?.motd == dstMOTD)

        let request = await capture.request
        #expect(await capture.operationID == "postServerMotd")
        #expect(request?.method == .post)
        #expect(request?.path == "/servers/\(serverId)/options/motd/")
        if let request { requireAuth(request) }
    }

    @Test
    func testStartAServerAlreadyStarting208() async throws {
        let capture = TransportCapture()
        let transport = MockTransport { request, body, baseURL, operationID in
            await capture.record(request, body: body, baseURL: baseURL, operationID: operationID)
            let response = makeResponse(status: .init(code: 208))
            let responseBody = try makeJSONBody([
                "success": false,
                "error": "Server is already starting",
                "data": NSNull()
            ])
            return (response, responseBody)
        }
        let client = makeClient(transport: transport)
        let response = try await client.getStartServer(path: .init(serverId: serverId))
        switch response {
        case .code208(let alreadyStartResponse):
            let json = try alreadyStartResponse.body.json
            #expect(json.success == false)
            #expect(json.error == "Server is already starting")
        default:
            Issue.record("unexpected response: \(response)")
        }

        let request = await capture.request
        #expect(await capture.operationID == "getStartServer")
        #expect(request?.method == .get)
        #expect(request?.path == "/servers/\(serverId)/start/")
        if let request { requireAuth(request) }
    }

    @Test
    func testStartAServerUseOwnCredits() async throws {
        let capture = TransportCapture()
        let transport = MockTransport { request, body, baseURL, operationID in
            await capture.record(request, body: body, baseURL: baseURL, operationID: operationID)
            #expect(request.headerFields[.contentType]?.contains("application/json") == true)
            let requestData = try await Data(collecting: #require(body), upTo: .max)
            let requestJSON = try JSONSerialization.jsonObject(with: requestData) as? [String: Any]
            #expect(requestJSON?["useOwnCredits"] as? Bool == false)

            let response = makeResponse(status: .ok)
            let responseBody = try makeJSONBody([
                "success": true,
                "error": NSNull(),
                "data": NSNull()
            ])
            return (response, responseBody)
        }
        let client = makeClient(transport: transport)
        let response = try await client.postStartServer(
            path: .init(serverId: serverId),
            body: .json(.init(useOwnCredits: false))
        )
        let json = try response.ok.body.json
        #expect(json.success == true)

        let request = await capture.request
        #expect(await capture.operationID == "postStartServer")
        #expect(request?.method == .post)
        #expect(request?.path == "/servers/\(serverId)/start/")
        if let request { requireAuth(request) }
    }

    @Test
    func testStopAServer() async throws {
        let capture = TransportCapture()
        let transport = MockTransport { request, body, baseURL, operationID in
            await capture.record(request, body: body, baseURL: baseURL, operationID: operationID)
            let response = makeResponse(status: .ok)
            let responseBody = try makeJSONBody([
                "success": true,
                "error": NSNull(),
                "data": NSNull()
            ])
            return (response, responseBody)
        }
        let client = makeClient(transport: transport)
        let response = try await client.stopServer(path: .init(serverId: serverId))
        let json = try response.ok.body.json
        #expect(json.success == true)

        let request = await capture.request
        #expect(await capture.operationID == "stopServer")
        #expect(request?.method == .get)
        #expect(request?.path == "/servers/\(serverId)/stop/")
        if let request { requireAuth(request) }
    }

    @Test
    func testRestartAServer() async throws {
        let capture = TransportCapture()
        let transport = MockTransport { request, body, baseURL, operationID in
            await capture.record(request, body: body, baseURL: baseURL, operationID: operationID)
            let response = makeResponse(status: .ok)
            let responseBody = try makeJSONBody([
                "success": true,
                "error": NSNull(),
                "data": NSNull()
            ])
            return (response, responseBody)
        }
        let client = makeClient(transport: transport)
        let response = try await client.restartServer(path: .init(serverId: serverId))
        let json = try response.ok.body.json
        #expect(json.success == true)

        let request = await capture.request
        #expect(await capture.operationID == "restartServer")
        #expect(request?.method == .get)
        #expect(request?.path == "/servers/\(serverId)/restart/")
        if let request { requireAuth(request) }
    }

    @Test
    func testExecuteAServerCommand() async throws {
        let capture = TransportCapture()
        let transport = MockTransport { request, body, baseURL, operationID in
            await capture.record(request, body: body, baseURL: baseURL, operationID: operationID)
            #expect(request.headerFields[.contentType]?.contains("application/json") == true)
            let requestData = try await Data(collecting: #require(body), upTo: .max)
            let requestJSON = try JSONSerialization.jsonObject(with: requestData) as? [String: Any]
            #expect(requestJSON?["command"] as? String == "plugins")

            let response = makeResponse(status: .ok)
            let responseBody = try makeJSONBody([
                "success": true,
                "error": NSNull(),
                "data": NSNull()
            ])
            return (response, responseBody)
        }
        let client = makeClient(transport: transport)
        let response = try await client.postServerCommand(
            path: .init(serverId: serverId),
            body: .json(.init(command: "plugins"))
        )
        let json = try response.ok.body.json
        #expect(json.success == true)

        let request = await capture.request
        #expect(await capture.operationID == "postServerCommand")
        #expect(request?.method == .post)
        #expect(request?.path == "/servers/\(serverId)/command/")
        if let request { requireAuth(request) }
    }

    @Test
    func testExtendServerStopTime() async throws {
        let capture = TransportCapture()
        let transport = MockTransport { request, body, baseURL, operationID in
            await capture.record(request, body: body, baseURL: baseURL, operationID: operationID)
            #expect(request.headerFields[.contentType]?.contains("application/json") == true)
            let requestData = try await Data(collecting: #require(body), upTo: .max)
            let requestJSON = try JSONSerialization.jsonObject(with: requestData) as? [String: Any]
            #expect(requestJSON?["time"] as? Int == 60)

            let response = makeResponse(status: .ok)
            let responseBody = try makeJSONBody([
                "success": true,
                "error": NSNull(),
                "data": NSNull()
            ])
            return (response, responseBody)
        }
        let client = makeClient(transport: transport)
        let response = try await client.extendServerStopTime(
            path: .init(serverId: serverId),
            body: .json(.init(time: 60))
        )
        let json = try response.ok.body.json
        #expect(json.success == true)

        let request = await capture.request
        #expect(await capture.operationID == "extendServerStopTime")
        #expect(request?.method == .post)
        #expect(request?.path == "/servers/\(serverId)/extend-time/")
        if let request { requireAuth(request) }
    }

    @Test
    func testGetAvailablePlaylist() async throws {
        let capture = TransportCapture()
        let transport = MockTransport { request, body, baseURL, operationID in
            await capture.record(request, body: body, baseURL: baseURL, operationID: operationID)
            let response = makeResponse(status: .ok)
            let responseBody = try makeJSONBody([
                "success": true,
                "error": NSNull(),
                "data": ["whitelist", "ops"]
            ])
            return (response, responseBody)
        }
        let client = makeClient(transport: transport)
        let response = try await client.getPlayerLists(path: .init(serverId: serverId))
        let data = try response.ok.body.json.data
        #expect(data?.contains("whitelist") == true)

        let request = await capture.request
        #expect(await capture.operationID == "getPlayerLists")
        #expect(request?.method == .get)
        #expect(request?.path == "/servers/\(serverId)/playerlists/")
        if let request { requireAuth(request) }
    }

    @Test
    func testGetPlaylistContentsOfWhitelist() async throws {
        let capture = TransportCapture()
        let transport = MockTransport { request, body, baseURL, operationID in
            await capture.record(request, body: body, baseURL: baseURL, operationID: operationID)
            let response = makeResponse(status: .ok)
            let responseBody = try makeJSONBody([
                "success": true,
                "error": NSNull(),
                "data": [self.player]
            ])
            return (response, responseBody)
        }
        let client = makeClient(transport: transport)
        let response = try await client.getPlayerList(path: .init(serverId: serverId, list: "whitelist"))
        let data = try response.ok.body.json.data
        #expect(data?.contains(player) == true)

        let request = await capture.request
        #expect(await capture.operationID == "getPlayerList")
        #expect(request?.method == .get)
        #expect(request?.path == "/servers/\(serverId)/playerlists/whitelist/")
        if let request { requireAuth(request) }
    }

    @Test
    func testAddEntriesToPlayerListOfWhitelist() async throws {
        let capture = TransportCapture()
        let transport = MockTransport { request, body, baseURL, operationID in
            await capture.record(request, body: body, baseURL: baseURL, operationID: operationID)
            #expect(request.headerFields[.contentType]?.contains("application/json") == true)
            let requestData = try await Data(collecting: #require(body), upTo: .max)
            let requestJSON = try JSONSerialization.jsonObject(with: requestData) as? [String: Any]
            let entries = requestJSON?["entries"] as? [String]
            #expect(entries == [self.player])

            let response = makeResponse(status: .ok)
            let responseBody = try makeJSONBody([
                "success": true,
                "error": NSNull(),
                "data": [self.player]
            ])
            return (response, responseBody)
        }
        let client = makeClient(transport: transport)
        let response = try await client.putPlayerList(
            path: .init(serverId: serverId, list: "whitelist"),
            body: .json(.init(entries: [player]))
        )
        let json = try response.ok.body.json
        #expect(json.data?.contains(player) == true)

        let request = await capture.request
        #expect(await capture.operationID == "putPlayerList")
        #expect(request?.method == .put)
        #expect(request?.path == "/servers/\(serverId)/playerlists/whitelist/")
        if let request { requireAuth(request) }
    }

    @Test
    func testRemoveEntriesFromPlayerListOfWhitelist() async throws {
        let capture = TransportCapture()
        let transport = MockTransport { request, body, baseURL, operationID in
            await capture.record(request, body: body, baseURL: baseURL, operationID: operationID)
            #expect(request.headerFields[.contentType]?.contains("application/json") == true)
            let requestData = try await Data(collecting: #require(body), upTo: .max)
            let requestJSON = try JSONSerialization.jsonObject(with: requestData) as? [String: Any]
            let entries = requestJSON?["entries"] as? [String]
            #expect(entries == [self.player])

            let response = makeResponse(status: .ok)
            let responseBody = try makeJSONBody([
                "success": true,
                "error": NSNull(),
                "data": []
            ])
            return (response, responseBody)
        }
        let client = makeClient(transport: transport)
        let response = try await client.deletePlayerList(
            path: .init(serverId: serverId, list: "whitelist"),
            body: .json(.init(entries: [player]))
        )
        let json = try response.ok.body.json
        #expect(json.data?.contains(player) == false)

        let request = await capture.request
        #expect(await capture.operationID == "deletePlayerList")
        #expect(request?.method == .delete)
        #expect(request?.path == "/servers/\(serverId)/playerlists/whitelist/")
        if let request { requireAuth(request) }
    }

    @Test
    func testGetFileInformation() async throws {
        let capture = TransportCapture()
        let transport = MockTransport { request, body, baseURL, operationID in
            await capture.record(request, body: body, baseURL: baseURL, operationID: operationID)
            let response = makeResponse(status: .ok)
            let responseBody = try makeJSONBody([
                "success": true,
                "error": NSNull(),
                "data": [
                    "path": "server.properties",
                    "name": "server.properties",
                    "isTextFile": true,
                    "isConfigFile": true,
                    "isDirectory": false,
                    "isLog": false,
                    "isReadable": true,
                    "isWritable": true,
                    "size": 10,
                    "children": NSNull()
                ]
            ])
            return (response, responseBody)
        }
        let client = makeClient(transport: transport)
        let response = try await client.getFileInfo(path: .init(serverId: serverId, path: "server.properties"))
        let data = try response.ok.body.json.data
        #expect(data?.name == "server.properties")

        let request = await capture.request
        #expect(await capture.operationID == "getFileInfo")
        #expect(request?.method == .get)
        #expect(request?.path == "/servers/\(serverId)/files/info/server.properties/")
        if let request { requireAuth(request) }
    }

    @Test
    func testGetFileData() async throws {
        let capture = TransportCapture()
        let transport = MockTransport { request, body, baseURL, operationID in
            await capture.record(request, body: body, baseURL: baseURL, operationID: operationID)
            let response = makeResponse(status: .ok, contentType: "application/octet-stream")
            let responseBody = HTTPBody(Data([0x01, 0x02, 0x03]))
            return (response, responseBody)
        }
        let client = makeClient(transport: transport)
        let response = try await client.getFileContent(
            path: .init(serverId: serverId, path: "ops.json"),
            headers: .init(accept: [.init(contentType: .binary)])
        )
        let length = try response.ok.body.binary.length
        switch length {
        case .known(let count):
            #expect(count == 3)
        default:
            Issue.record("unexpected length: \(length)")
        }

        let request = await capture.request
        #expect(await capture.operationID == "getFileContent")
        #expect(request?.method == .get)
        #expect(request?.path == "/servers/\(serverId)/files/data/ops.json/")
        #expect(request?.headerFields[.accept]?.contains("application/octet-stream") == true)
        if let request { requireAuth(request) }
    }

    @Test
    func testWriteFileData() async throws {
        let capture = TransportCapture()
        let transport = MockTransport { request, body, baseURL, operationID in
            await capture.record(request, body: body, baseURL: baseURL, operationID: operationID)
            #expect(request.headerFields[.contentType]?.contains("application/octet-stream") == true)
            let requestData = try await Data(collecting: #require(body), upTo: .max)
            let requestString = String(data: requestData, encoding: .utf8)
            #expect(requestString == "test_write_file_content")

            let response = makeResponse(status: .ok)
            let responseBody = try makeJSONBody([
                "success": true,
                "error": NSNull(),
                "data": NSNull()
            ])
            return (response, responseBody)
        }
        let client = makeClient(transport: transport)
        let response = try await client.putFileData(
            path: .init(serverId: serverId, path: filePath),
            body: .binary(.init(stringLiteral: "test_write_file_content"))
        )
        let json = try response.ok.body.json
        #expect(json.success == true)

        let request = await capture.request
        #expect(await capture.operationID == "putFileData")
        #expect(request?.method == .put)
        #expect(request?.path == "/servers/\(serverId)/files/data/\(filePath)/")
        if let request { requireAuth(request) }
    }

    @Test
    func testDeleteFile() async throws {
        let capture = TransportCapture()
        let transport = MockTransport { request, body, baseURL, operationID in
            await capture.record(request, body: body, baseURL: baseURL, operationID: operationID)
            let response = makeResponse(status: .ok)
            let responseBody = try makeJSONBody([
                "success": true,
                "error": NSNull(),
                "data": NSNull()
            ])
            return (response, responseBody)
        }
        let client = makeClient(transport: transport)
        let response = try await client.deleteFile(path: .init(serverId: serverId, path: filePath))
        let json = try response.ok.body.json
        #expect(json.success == true)

        let request = await capture.request
        #expect(await capture.operationID == "deleteFile")
        #expect(request?.method == .delete)
        #expect(request?.path == "/servers/\(serverId)/files/data/\(filePath)/")
        if let request { requireAuth(request) }
    }

    @Test
    func testGetConfigOptions() async throws {
        let capture = TransportCapture()
        let transport = MockTransport { request, body, baseURL, operationID in
            await capture.record(request, body: body, baseURL: baseURL, operationID: operationID)
            let response = makeResponse(status: .ok)
            let responseBody = try makeJSONBody([
                "success": true,
                "error": NSNull(),
                "data": [
                    [
                        "key": "gamemode",
                        "label": "Game Mode",
                        "type": "string",
                        "value": "survival",
                        "options": NSNull()
                    ]
                ]
            ])
            return (response, responseBody)
        }
        let client = makeClient(transport: transport)
        let response = try await client.getConfigFileData(path: .init(serverId: serverId, path: "server.properties"))
        let data = try response.ok.body.json.data
        #expect(data?.first?.key == "gamemode")

        let request = await capture.request
        #expect(await capture.operationID == "getConfigFileData")
        #expect(request?.method == .get)
        #expect(request?.path == "/servers/\(serverId)/files/config/server.properties/")
        if let request { requireAuth(request) }
    }

    @Test
    func testUpdateConfigOptions() async throws {
        let capture = TransportCapture()
        let transport = MockTransport { request, body, baseURL, operationID in
            await capture.record(request, body: body, baseURL: baseURL, operationID: operationID)
            #expect(request.headerFields[.contentType]?.contains("application/json") == true)
            let requestData = try await Data(collecting: #require(body), upTo: .max)
            let requestJSON = try JSONSerialization.jsonObject(with: requestData) as? [String: Any]
            #expect(requestJSON?["gamemode"] as? String == "survival")

            let response = makeResponse(status: .ok)
            let responseBody = try makeJSONBody([
                "success": true,
                "error": NSNull(),
                "data": [
                    [
                        "key": "gamemode",
                        "label": "Game Mode",
                        "type": "string",
                        "value": "survival",
                        "options": NSNull()
                    ]
                ]
            ])
            return (response, responseBody)
        }
        let client = makeClient(transport: transport)
        let response = try await client.postConfigFileData(
            path: .init(serverId: serverId, path: "server.properties"),
            body: .json(.init(additionalProperties: .init(unvalidatedValue: ["gamemode": "survival"])))
        )
        let data = try response.ok.body.json.data
        #expect(data?.first?.key == "gamemode")

        let request = await capture.request
        #expect(await capture.operationID == "postConfigFileData")
        #expect(request?.method == .post)
        #expect(request?.path == "/servers/\(serverId)/files/config/server.properties/")
        if let request { requireAuth(request) }
    }

    @Test
    func testListCreditPools() async throws {
        let capture = TransportCapture()
        let transport = MockTransport { request, body, baseURL, operationID in
            await capture.record(request, body: body, baseURL: baseURL, operationID: operationID)
            let response = makeResponse(status: .ok)
            let responseBody = try makeJSONBody([
                "success": true,
                "error": NSNull(),
                "data": [
                    [
                        "id": self.poolId,
                        "name": "example",
                        "credits": 100.05,
                        "servers": 1,
                        "owner": "EwYiY9IAMtQBTb6s",
                        "isOwner": false,
                        "members": 2,
                        "ownShare": 0.5,
                        "ownCredits": 21.0
                    ]
                ]
            ])
            return (response, responseBody)
        }
        let client = makeClient(transport: transport)
        let response = try await client.getCreditPools()
        let data = try response.ok.body.json.data
        #expect(data?.first?.id == poolId)

        let request = await capture.request
        #expect(await capture.operationID == "getCreditPools")
        #expect(request?.method == .get)
        #expect(request?.path == "/billing/pools/")
        if let request { requireAuth(request) }
    }

    @Test
    func testGetACreditPool() async throws {
        let capture = TransportCapture()
        let transport = MockTransport { request, body, baseURL, operationID in
            await capture.record(request, body: body, baseURL: baseURL, operationID: operationID)
            let response = makeResponse(status: .ok)
            let responseBody = try makeJSONBody([
                "success": true,
                "error": NSNull(),
                "data": [
                    "id": self.poolId,
                    "name": "example",
                    "credits": 100.05,
                    "servers": 1,
                    "owner": "EwYiY9IAMtQBTb6s",
                    "isOwner": false,
                    "members": 2,
                    "ownShare": 0.5,
                    "ownCredits": 21.0
                ]
            ])
            return (response, responseBody)
        }
        let client = makeClient(transport: transport)
        let response = try await client.getCreditPool(path: .init(poolId: poolId))
        let data = try response.ok.body.json.data
        #expect(data?.id == poolId)

        let request = await capture.request
        #expect(await capture.operationID == "getCreditPool")
        #expect(request?.method == .get)
        #expect(request?.path == "/billing/pools/\(poolId)/")
        if let request { requireAuth(request) }
    }

    @Test
    func testListCreditPoolMembers() async throws {
        let capture = TransportCapture()
        let transport = MockTransport { request, body, baseURL, operationID in
            await capture.record(request, body: body, baseURL: baseURL, operationID: operationID)
            let response = makeResponse(status: .ok)
            let responseBody = try makeJSONBody([
                "success": true,
                "error": NSNull(),
                "data": [
                    [
                        "account": "EwYiY9IAMtQBTb6s",
                        "name": "example",
                        "share": 0.5,
                        "credits": 21.0,
                        "isOwner": false
                    ]
                ]
            ])
            return (response, responseBody)
        }
        let client = makeClient(transport: transport)
        let response = try await client.getCreditPoolMembers(path: .init(poolId: poolId))
        let data = try response.ok.body.json.data
        #expect(data?.first?.name == "example")

        let request = await capture.request
        #expect(await capture.operationID == "getCreditPoolMembers")
        #expect(request?.method == .get)
        #expect(request?.path == "/billing/pools/\(poolId)/members/")
        if let request { requireAuth(request) }
    }

    @Test
    func testListCreditPoolServers() async throws {
        let capture = TransportCapture()
        let transport = MockTransport { request, body, baseURL, operationID in
            await capture.record(request, body: body, baseURL: baseURL, operationID: operationID)
            let response = makeResponse(status: .ok)
            let responseBody = try makeJSONBody([
                "success": true,
                "error": NSNull(),
                "data": [
                    [
                        "id": self.serverId,
                        "name": "example",
                        "status": 1
                    ]
                ]
            ])
            return (response, responseBody)
        }
        let client = makeClient(transport: transport)
        let response = try await client.getCreditPoolServers(path: .init(poolId: poolId))
        let data = try response.ok.body.json.data
        #expect(data?.first?.id == serverId)

        let request = await capture.request
        #expect(await capture.operationID == "getCreditPoolServers")
        #expect(request?.method == .get)
        #expect(request?.path == "/billing/pools/\(poolId)/servers/")
        if let request { requireAuth(request) }
    }
}
