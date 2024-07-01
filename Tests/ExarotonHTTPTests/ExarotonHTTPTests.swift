import Testing
@testable import ExarotonHTTP
import OpenAPIRuntime
import OpenAPIURLSession
import Foundation

final class ExarotonHTTPTests {

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
    
    init() {
        
        let env = ProcessInfo.processInfo.environment

        yourServerToken = env["TOKEN"] ?? ""

        yourServerId = env["SERVER"] ?? ""

        yourCreditPoolId = env["POOL"] ?? ""

        yourTestPlayerName = env["PLAYER"] ?? "ExarotonAPITests_Player"

        yourTestFilePath = env["FILE"] ?? "ExarotonAPITests_Test_File"
    }
}

extension ExarotonHTTPTests {

    @Test
    func testGetAccountInfo() async throws {
        let response = try await client.getAccount()
        let data = try response.ok.body.json.data
        #expect(data != nil)
    }
    
    @Test
    func testListServers() async throws {
        let response = try await client.getServers()
        let data = try response.ok.body.json.data
        #expect(data != nil)
    }
    
    @Test
    func testGetAServer() async throws {
        let response = try await client.getServer(path: .init(serverId: yourServerId))
        let data = try response.ok.body.json.data
        #expect(data != nil)
    }

    @Test
    func testGetAServerLog() async throws {
        let response = try await client.getServerLog(path: .init(serverId: yourServerId))
        let data = try response.ok.body.json.data
        #expect(data != nil)
    }
    
    @Test
    func testUploadAServerLog() async throws {
        let response = try await client.shareServerLog(path: .init(serverId: yourServerId))
        switch response {
        case .ok(let actionResponse):
            let json = try actionResponse.body.json
            #expect(json != nil)
            #expect(json.data != nil)
            #expect(json.success == true)
        case .badRequest(let badRequestResponse):
            let json = try badRequestResponse.body.json
            #expect(json != nil)
            #expect(json.success == false)
            #expect(
                json.error == "Server is not offline" ||
                json.error == "File access is currently unavailable for this server" ||
                json.error == "Log file is empty or does not exist"
            )
        default:
            Issue.record("\(response)")
        }
    }
    
    @Test
    func testGetServerRAM() async throws {
        let response = try await client.getServerRam(path: .init(serverId: yourServerId))
        let data = try response.ok.body.json.data
        #expect(data != nil)
    }

    @Test
    func testChangeServerRAM() async throws {
        let dstRAM: Int32 = 2
        let response = try await client.postServerRam(.init(
            path: .init(serverId: yourServerId),
            body: .json(.init(ram: dstRAM))
        ))
        switch response {
        case .ok(let okResponse):
            let json = try okResponse.body.json
            #expect(json.success == true)
            #expect(json.data != nil)
            #expect(json.data?.ram == dstRAM)
        case .badRequest(let badRequestResponse):
            let json = try badRequestResponse.body.json
            #expect(json.success == false)
            #expect(json.error == "只有在服务器处于关闭状态时才能上传世界。")
        default:
            Issue.record("\(response)")
        }
    }

    @Test
    func testGetServerMOTD() async throws {
        let response = try await client.getServerMotd(path: .init(serverId: yourServerId))
        let data = try response.ok.body.json.data
        #expect(data != nil)
    }

    @Test
    func testChangeServerMOTD() async throws {
        let dstMOTD = "§b🗡 §7欢迎来到§ajokerhub§7的服务器！§b⛏"
        let response = try await client.postServerMotd(
            path: .init(serverId: yourServerId),
            body: .json(.init(motd: dstMOTD))
        )
        let data = try response.ok.body.json.data
        #expect(data != nil)
        #expect(data?.motd == dstMOTD)
    }

    @Test
    func testStartAServer() async throws {
        let response = try await client.getStartServer(path: .init(serverId: yourServerId))
        switch response {
        case .ok(let actionResponse):
            let json = try actionResponse.body.json
            #expect(json != nil)
            #expect(json.data == nil)
            #expect(json.success ?? false)
        case .badRequest(let badRequestResponse):
            let json = try badRequestResponse.body.json
            #expect(json != nil)
            #expect(json.success == false)
            #expect(json.error == "Server is not offline")
        case .internalServerError(let internalServerResponse):
            let json = try internalServerResponse.body.json
            #expect(json.success == false)
            #expect(json.error == "Server is already starting")
        case .code208(let alreadyStartResponse):
            let json = try alreadyStartResponse.body.json
            #expect(json.success == false)
            #expect(json.error == "Server is already starting")
            #expect(json.data != nil)
        default:
            Issue.record("\(response)")
        }
    }

    @Test
    func testStartAServerUseOwnCredits() async throws {
        let response = try await client.postStartServer(
            path: .init(serverId: yourServerId),
            body: .json(.init(useOwnCredits: false))
        )
        switch response {
        case .ok(let actionResponse):
            let json = try actionResponse.body.json
            #expect(json != nil)
            #expect(json.data == nil)
            #expect(json.success ?? false)
        case .badRequest(let badRequestResponse):
            let json = try badRequestResponse.body.json
            #expect(json != nil)
            #expect(json.success == false)
            #expect(json.error == "Server is not offline")
        case .code208(let alreadyStartResponse):
            let json = try alreadyStartResponse.body.json
            #expect(json.success == false)
            #expect(json.error == "Server is already starting")
            #expect(json.data == nil)
        default:
            Issue.record("\(response)")
        }
    }

    @Test
    func testStopAServer() async throws {
        let response = try await client.stopServer(path: .init(serverId: yourServerId))
        switch response {
        case .ok(let actionResponse):
            let json = try actionResponse.body.json
            #expect(json != nil)
            #expect(json.data == nil)
            #expect(json.success ?? false)
        case .badRequest(let badRequestResponse):
            let json = try badRequestResponse.body.json
            #expect(json != nil)
            #expect(json.success == false)
            #expect(json.error == "Server is not online")
        case .code208(let alreadyStopResponse):
            let json = try alreadyStopResponse.body.json
            #expect(json.success == false)
            #expect(json.error == "Server is already stopping")
            #expect(json.data == nil)
        default:
            Issue.record("\(response)")
        }
    }

    @Test
    func testRestartAServer() async throws {
        let response = try await client.restartServer(path: .init(serverId: yourServerId))
        switch response {
        case .ok(let actionResponse):
            let json = try actionResponse.body.json
            #expect(json != nil)
            #expect(json.data == nil)
            #expect(json.success ?? false)
        case .badRequest(let badRequestResponse):
            let json = try badRequestResponse.body.json
            #expect(json != nil)
            #expect(json.success == false)
            #expect(json.error == "Server is not online")
        default:
            Issue.record("\(response)")
        }
    }

    @Test
    func testExecuteAServerCommand() async throws {
        let command = "plugins"
        let response = try await client.postServerCommand(
            path: .init(serverId: yourServerId),
            body: .json(.init(command: command))
        )
        switch response {
        case .ok(let actionResponse):
            let json = try actionResponse.body.json
            #expect(json != nil)
            #expect(json.data == nil)
            #expect(json.success ?? false)
        case .badRequest(let badRequestResponse):
            let json = try badRequestResponse.body.json
            #expect(json != nil)
            #expect(json.success == false)
            #expect(json.error == "Server is not online")
        default:
            Issue.record("\(response)")
        }
    }

    @Test
    func testGetAvailablePlaylist() async throws {
        let response = try await client.getPlayerLists(path: .init(serverId: yourServerId))
        let data = try response.ok.body.json.data
        #expect(data != nil)
    }

    @Test
    func testGetPlaylistContentsOfWhitelist() async throws {
        let response = try await client.getPlayerList(
            path: .init(serverId: yourServerId,list: "whitelist")
        )
        let data = try response.ok.body.json.data
        #expect(data != nil)
    }

    @Test
    func testAddEntriesToPlayerListOfWhitelist() async throws {
        let response = try await client.putPlayerList(
            path: .init(serverId: yourServerId,list: "whitelist"),
            body: .json(.init(entries: [yourTestPlayerName]))
        )
        switch response {
        case .ok(let okResponse):
            let json = try okResponse.body.json
            #expect(json.success == true)
            #expect(json.data?.contains(yourTestPlayerName) == true)
        case .internalServerError(let internalServerResponse):
            let json = try internalServerResponse.body.json
            #expect(json.success == false)
            #expect(json.error == "Internal Server Error")
        default:
            Issue.record("\(response)")
        }

    }

    @Test
    func testRemoveEntriesFromPlayerListOfWhitelist() async throws {
        let response = try await client.deletePlayerList(
            path: .init(serverId: yourServerId,list: "whitelist"),
            body: .json(.init(entries: [yourTestPlayerName]))
        )
        switch response {
        case .ok(let okResponse):
            let json = try okResponse.body.json
            #expect(json.success == true)
            #expect(json.data?.contains(yourTestPlayerName) == false)
        case .internalServerError(let internalServerResponse):
            let json = try internalServerResponse.body.json
            #expect(json.success == false)
            #expect(json.error == "Internal Server Error")
        default:
            Issue.record("\(response)")
        }

    }

    @Test
    func testGetFileInformation() async throws {
        let dstPath = "server.properties"
        let response = try await client.getFileInfo(path: .init(serverId: yourServerId, path: dstPath))
        let data = try response.ok.body.json.data
        #expect(data != nil)
    }

    @Test
    func testGetFileData() async throws {
        let jsonFilePath = "ops.json"
        let zipFilePath = "config"
        let ymlFilePath = "bukkit.yml"
        for filePath in [jsonFilePath, zipFilePath, ymlFilePath] {
            do {
                let response = try await client.getFileContent(
                    path: .init(serverId: yourServerId, path: filePath),
                    headers: .init(accept: [.init(contentType: .binary)])
                )
                let binary = try #require(try response.ok.body.binary)
                #expect(binary != nil)
            } catch let error as OpenAPIRuntime.ClientError {
                Issue.record("\(filePath): \(error.causeDescription)")
            }
        }
    }

    @Test
    func testWriteFileData() async throws {
        let fileContent = "test_write_file_content"
        let response = try await client.putFileData(
            path: .init(serverId: yourServerId, path: yourTestFilePath),
            body: .binary(.init(stringLiteral: fileContent))
        )
        switch response {
        case .ok(let okResponse):
            let json = try okResponse.body.json
            #expect(json.success == true)
            #expect(json.data == nil)
        case .internalServerError(let internalServerResponse):
            let json = try internalServerResponse.body.json
            #expect(json.success == false)
            #expect(json.error == "Internal Server Error")
        case .badRequest(let badRequestResponse):
            let json = try badRequestResponse.body.json
            #expect(json != nil)
            #expect(json.success == false)
            #expect(json.error == "File access is currently unavailable for this server")
        default:
            Issue.record("\(response)")
        }
    }

    @Test
    func testDeleteFile() async throws {
        let response = try await client.deleteFile(
            path: .init(serverId: yourServerId, path: yourTestFilePath)
        )
        switch response {
        case .ok(let okResponse):
            let json = try okResponse.body.json
            #expect(json.data == nil)
            #expect(json.success == true)
        case .forbidden(let forbiddenResponse):
            let json = try forbiddenResponse.body.json
            #expect(json.success == false)
            #expect(json.error == "Access denied")
        default:
            Issue.record("\(response)")
        }
    }

    @Test
    func testGetConfigOptions() async throws {
        let configFilePath = "server.properties"
        let response = try await client.getConfigFileData(path: .init(serverId: yourServerId, path: configFilePath))
        let data = try response.ok.body.json.data
        #expect(data != nil)
    }

    @Test
    func testUpdateConfigOptions() async throws {
        let configFilePath = "server.properties"
        let key = "gamemode"
        let value = "survival"
        let kv = [key: value]
        let response = try await client.postConfigFileData(
            path: .init(serverId: yourServerId, path: configFilePath),
            body: .json(.init(additionalProperties: .init(unvalidatedValue: kv)))
        )
        switch response {
        case .ok(let okResponse):
            let data = try okResponse.body.json.data
            #expect(data != nil)
            let gameModeOptionValue = data?.filter { $0.key == key }.first?.value
            switch gameModeOptionValue {
            case .case1(let stringValue):
                #expect(stringValue == value)
            default:
                Issue.record("\(response)")
            }
        case .notFound(let notFoundResponse):
            let json = try notFoundResponse.body.json
            #expect(json.success == false)
            #expect(json.error == "File not found")
        case .internalServerError(let internalServerResponse):
            let json = try internalServerResponse.body.json
            #expect(json.success == false)
            #expect(json.error == "Internal Server Error")
        case .badRequest(let badRequestResponse):
            let json = try badRequestResponse.body.json
            #expect(json != nil)
            #expect(json.success == false)
            #expect(json.error == "File access is currently unavailable for this server")
        default:
            Issue.record("\(response)")
        }
    }

    @Test
    func testListCreditPools() async throws {
        let response = try await client.getCreditPools()
        let data = try response.ok.body.json.data
        #expect(data != nil)
        if let data, !data.isEmpty {
            #expect(data.first?.id?.isEmpty == false)
        }
    }

    @Test
    func testGetACreditPool() async throws {
        let response = try await client.getCreditPool(path: .init(poolId: yourCreditPoolId))
        let data = try response.ok.body.json.data
        #expect(data != nil)
        #expect(data?.id == yourCreditPoolId)
    }

    @Test
    func testListCreditPoolMembers() async throws {
        let response = try await client.getCreditPoolMembers(path: .init(poolId: yourCreditPoolId))
        let data = try response.ok.body.json.data
        #expect(data != nil)
    }

    @Test
    func testListCreditPoolServers() async throws {
        let response = try await client.getCreditPoolServers(path: .init(poolId: yourCreditPoolId))
        let data = try response.ok.body.json.data
        #expect(data != nil)
    }
}
