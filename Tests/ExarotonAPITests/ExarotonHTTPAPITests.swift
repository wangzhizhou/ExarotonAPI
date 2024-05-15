import XCTest

@testable import ExarotonAPI
import OpenAPIRuntime
import OpenAPIURLSession

final class ExarotonHTTPAPITests: XCTestCase {

    var yourServerToken: String = ""

    var yourServerId: String = ""

    var yourCreditPoolId: String = ""

    var yourTestPlayerName = ""

    var yourTestFilePath = ""

    lazy var client: Client = {
        let ret = Client(
            serverURL: try! Servers.server1(),
            transport: URLSessionTransport(),
            middlewares: [AuthenticationMiddleware(token: yourServerToken)]
        )
        return ret
    }()

    override func setUp() async throws {

        let env = ProcessInfo.processInfo.environment

        yourServerToken = env["TOKEN"] ?? ""

        yourServerId = env["SERVER"] ?? ""

        yourCreditPoolId = env["POOL"] ?? ""

        yourTestPlayerName = env["PLAYER"] ?? "ExarotonAPITests_Player"

        yourTestFilePath = env["FILE"] ?? "ExarotonAPITests_Test_File"
    }

    func testGetAccountInfo() async throws {
        let response = try await client.getAccount()
        let data = try response.ok.body.json.data
        XCTAssertNotNil(data)
    }

    func testListServers() async throws {
        let response = try await client.getServers()
        let data = try response.ok.body.json.data
        XCTAssertNotNil(data)
    }

    func testGetAServer() async throws {
        let response = try await client.getServer(path: .init(serverId: yourServerId))
        let data = try response.ok.body.json.data
        XCTAssertNotNil(data)
    }

    func testGetAServerLog() async throws {
        let response = try await client.getServerLog(path: .init(serverId: yourServerId))
        let data = try response.ok.body.json.data
        XCTAssertNotNil(data)
    }

    func testUploadAServerLog() async throws {
        let response = try await client.shareServerLog(path: .init(serverId: yourServerId))
        switch response {
        case .ok(let actionResponse):
            let json = try actionResponse.body.json
            XCTAssertNotNil(json)
            XCTAssertNotNil(json.data)
            XCTAssertTrue(json.success ?? false)
        case .badRequest(let badRequestResponse):
            let json = try badRequestResponse.body.json
            XCTAssertNotNil(json)
            XCTAssertFalse(json.success ?? false)
            XCTAssertTrue(
                json.error == "Server is not offline" ||
                json.error == "File access is currently unavailable for this server" ||
                json.error == "Log file is empty or does not exist"
            )
        default:
            XCTAssertTrue(false)
        }
    }

    func testGetServerRAM() async throws {
        let response = try await client.getServerRam(path: .init(serverId: yourServerId))
        let data = try response.ok.body.json.data
        XCTAssertNotNil(data)
    }

    func testChangeServerRAM() async throws {
        let dstRAM: Int32 = 2
        let response = try await client.postServerRam(.init(
            path: .init(serverId: yourServerId),
            body: .json(.init(ram: dstRAM))
        ))
        switch response {
        case .ok(let okResponse):
            let json = try okResponse.body.json
            XCTAssertTrue(json.success == true)
            XCTAssertNotNil(json.data)
            XCTAssertTrue(json.data?.ram == dstRAM)
        case .badRequest(let badRequestResponse):
            let json = try badRequestResponse.body.json
            XCTAssertTrue(json.success == false)
            XCTAssertTrue(json.error == "只有在服务器处于关闭状态时才能上传世界。")
        default:
            XCTAssertTrue(false)
        }
    }

    func testGetServerMOTD() async throws {
        let response = try await client.getServerMotd(path: .init(serverId: yourServerId))
        let data = try response.ok.body.json.data
        XCTAssertNotNil(data)
    }

    func testChangeServerMOTD() async throws {
        let dstMOTD = "§b🗡 §7欢迎来到§ajokerhub§7的服务器！§b⛏"
        let response = try await client.postServerMotd(
            path: .init(serverId: yourServerId),
            body: .json(.init(motd: dstMOTD))
        )
        let data = try response.ok.body.json.data
        XCTAssertNotNil(data)
        XCTAssertTrue(data?.motd == dstMOTD)
    }

    func testStartAServer() async throws {
        let response = try await client.getStartServer(path: .init(serverId: yourServerId))
        switch response {
        case .ok(let actionResponse):
            let json = try actionResponse.body.json
            XCTAssertNotNil(json)
            XCTAssertNil(json.data)
            XCTAssertTrue(json.success ?? false)
        case .badRequest(let badRequestResponse):
            let json = try badRequestResponse.body.json
            XCTAssertNotNil(json)
            XCTAssertFalse(json.success ?? false)
            XCTAssertTrue(json.error == "Server is not offline")
        case .internalServerError(let internalServerResponse):
            let json = try internalServerResponse.body.json
            XCTAssertTrue(json.success == false)
            XCTAssertTrue(json.error == "Server is already starting")
        default:
            XCTAssertTrue(false)
        }
    }

    func testStartAServerUseOwnCredits() async throws {
        let response = try await client.postStartServer(
            path: .init(serverId: yourServerId),
            body: .json(.init(useOwnCredits: false))
        )
        switch response {
        case .ok(let actionResponse):
            let json = try actionResponse.body.json
            XCTAssertNotNil(json)
            XCTAssertNil(json.data)
            XCTAssertTrue(json.success ?? false)
        case .badRequest(let badRequestResponse):
            let json = try badRequestResponse.body.json
            XCTAssertNotNil(json)
            XCTAssertFalse(json.success ?? false)
            XCTAssertTrue(json.error == "Server is not offline")
        default:
            XCTAssertTrue(false)
        }
    }

    func testStopAServer() async throws {
        let response = try await client.stopServer(path: .init(serverId: yourServerId))
        switch response {
        case .ok(let actionResponse):
            let json = try actionResponse.body.json
            XCTAssertNotNil(json)
            XCTAssertNil(json.data)
            XCTAssertTrue(json.success ?? false)
        case .badRequest(let badRequestResponse):
            let json = try badRequestResponse.body.json
            XCTAssertNotNil(json)
            XCTAssertFalse(json.success ?? false)
            XCTAssertTrue(json.error == "Server is not online")
        default:
            XCTAssertTrue(false)
        }
    }

    func testRestartAServer() async throws {
        let response = try await client.restartServer(path: .init(serverId: yourServerId))
        switch response {
        case .ok(let actionResponse):
            let json = try actionResponse.body.json
            XCTAssertNotNil(json)
            XCTAssertNil(json.data)
            XCTAssertTrue(json.success ?? false)
        case .badRequest(let badRequestResponse):
            let json = try badRequestResponse.body.json
            XCTAssertNotNil(json)
            XCTAssertFalse(json.success ?? false)
            XCTAssertTrue(json.error == "Server is not online")
        default:
            XCTAssertTrue(false)
        }
    }

    func testExecuteAServerCommand() async throws {
        let command = "plugins"
        let response = try await client.postServerCommand(
            path: .init(serverId: yourServerId),
            body: .json(.init(command: command))
        )
        switch response {
        case .ok(let actionResponse):
            let json = try actionResponse.body.json
            XCTAssertNotNil(json)
            XCTAssertNil(json.data)
            XCTAssertTrue(json.success ?? false)
        case .badRequest(let badRequestResponse):
            let json = try badRequestResponse.body.json
            XCTAssertNotNil(json)
            XCTAssertFalse(json.success ?? false)
            XCTAssertTrue(json.error == "Server is not online")
        default:
            XCTAssertTrue(false)
        }
    }

    func testGetAvailablePlaylist() async throws {
        let response = try await client.getPlayerLists(path: .init(serverId: yourServerId))
        let data = try response.ok.body.json.data
        XCTAssertNotNil(data)
    }

    func testGetPlaylistContentsOfWhitelist() async throws {
        let response = try await client.getPlayerList(
            path: .init(serverId: yourServerId,list: "whitelist")
        )
        let data = try response.ok.body.json.data
        XCTAssertNotNil(data)
    }

    func testAddEntriesToPlayerListOfWhitelist() async throws {
        let response = try await client.putPlayerList(
            path: .init(serverId: yourServerId,list: "whitelist"),
            body: .json(.init(entries: [yourTestPlayerName]))
        )
        XCTAssertTrue(try response.ok.body.json.data?.contains(yourTestPlayerName) == true)
    }

    func testRemoveEntriesFromPlayerListOfWhitelist() async throws {
        let response = try await client.deletePlayerList(
            path: .init(serverId: yourServerId,list: "whitelist"),
            body: .json(.init(entries: [yourTestPlayerName]))
        )
        XCTAssertTrue(try response.ok.body.json.data?.contains(yourTestPlayerName) == false)
    }

    func testGetFileInformation() async throws {
        let dstPath = "server.properties"
        let response = try await client.getFileInfo(path: .init(serverId: yourServerId, path: dstPath))
        let data = try response.ok.body.json.data
        XCTAssertNotNil(data)
    }

    func testGetFileData() async throws {
        let jsonFilePath = "ops.json"
        let zipFilePath = "config"
        let ymlFilePath = "bukkit.yml"
        for filePath in [jsonFilePath, zipFilePath, ymlFilePath] {
            do {
                let response = try await client.getFileContent(
                    path: .init(serverId: yourServerId, path: filePath)
                )
                XCTAssertNotNil(try response.ok.body.binary)
            } catch let error as OpenAPIRuntime.ClientError {
                XCTAssertTrue(false, "\(filePath): \(error.causeDescription)")
            }
        }
    }

    func testWriteFileData() async throws {
        let fileContent = "test_write_file_content"
        let response = try await client.putFileData(
            path: .init(serverId: yourServerId, path: yourTestFilePath),
            body: .binary(.init(stringLiteral: fileContent))
        )
        let json = try response.ok.body.json
        XCTAssertNotNil(json.success == true)
        XCTAssertNil(json.data)
    }

    func testDeleteFile() async throws {
        let response = try await client.deleteFile(
            path: .init(serverId: yourServerId, path: yourTestFilePath)
        )
        switch response {
        case .ok(let okResponse):
            let json = try okResponse.body.json
            XCTAssertNil(json.data)
            XCTAssertTrue(json.success == true)
        case .forbidden(let forbiddenResponse):
            let json = try forbiddenResponse.body.json
            XCTAssertTrue(json.success == false)
            XCTAssertTrue(json.error == "Access denied")
        default:
            XCTAssertTrue(false)
        }
    }

    func testGetConfigOptions() async throws {
        let configFilePath = "server.properties"
        let response = try await client.getConfigFileData(path: .init(serverId: yourServerId, path: configFilePath))
        let data = try response.ok.body.json.data
        XCTAssertNotNil(data)
    }

    func testUpdateConfigOptions() async throws {
        let configFilePath = "server.properties"
        let key = "gamemode"
        let value = "survival"
        let kv = [key: value]
        let response = try await client.postConfigFileData(
            path: .init(serverId: yourServerId, path: configFilePath),
            body: .json(.init(additionalProperties: kv))
        )
        switch response {
        case .ok(let okResponse):
            let data = try okResponse.body.json.data
            XCTAssertNotNil(data)
            let gameModeOptionValue = data?.filter { $0.key == key }.first?.value
            switch gameModeOptionValue {
            case .case1(let stringValue):
                XCTAssertTrue(stringValue == value)
            default:
                XCTAssertTrue(false)
            }
        case .notFound(let notFoundResponse):
            let json = try notFoundResponse.body.json
            XCTAssertTrue(json.success == false)
            XCTAssertTrue(json.error == "File not found")
        default:
            XCTAssertTrue(false)
        }
    }

    func testListCreditPools() async throws {
        let response = try await client.getCreditPools()
        let data = try response.ok.body.json.data
        XCTAssertNotNil(data)
        if let data, !data.isEmpty {
            XCTAssertTrue(data.first?.id?.isEmpty == false)
        }
    }

    func testGetACreditPool() async throws {
        let response = try await client.getCreditPool(path: .init(poolId: yourCreditPoolId))
        let data = try response.ok.body.json.data
        XCTAssertNotNil(data)
        XCTAssertTrue(data?.id == yourCreditPoolId)
    }

    func testListCreditPoolMembers() async throws {
        let response = try await client.getCreditPoolMembers(path: .init(poolId: yourCreditPoolId))
        let data = try response.ok.body.json.data
        XCTAssertNotNil(data)
    }

    func testListCreditPoolServers() async throws {
        let response = try await client.getCreditPoolServers(path: .init(poolId: yourCreditPoolId))
        let data = try response.ok.body.json.data
        XCTAssertNotNil(data)
    }
}
