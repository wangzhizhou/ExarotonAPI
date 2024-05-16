import XCTest
import ManualExarotonHTTP

final class ManualExarotonHTTPTests: XCTestCase {

    var yourServerToken: String = ""

    var yourServerId: String = ""

    var yourCreditPoolId: String = ""

    var yourTestPlayerName = ""

    var yourTestFilePath = ""

    lazy var client: APIClient = {
        let client = APIClient(
            baseUrl: "https://api.exaroton.com/v1",
            token: yourServerToken
        )
        return client
    }()

    override func setUp() async throws {

        let env = ProcessInfo.processInfo.environment

        yourServerToken = env["TOKEN"] ?? ""

        yourServerId = env["SERVER"] ?? ""

        yourCreditPoolId = env["POOL"] ?? ""

        yourTestPlayerName = env["PLAYER"] ?? "ExarotonAPITests_Player"

        yourTestFilePath = env["FILE"] ?? "ExarotonAPITests_Test_File"
    }
}

extension ManualExarotonHTTPTests {

    func testAccount() async throws {
        let response = try await client.request(.account, dataType: AccountData.self)
        guard let account = checkResponse(response)
        else { return }
        XCTAssertNotNil(account.name)
        XCTAssertNotNil(account.email)
        XCTAssertTrue(account.verified)
        XCTAssertGreaterThanOrEqual(account.credits, 0)
    }

    func testServers() async throws {
        let response = try await client.request(.servers(), dataType: [ServerData].self)
        guard let servers = checkResponse(response)
        else { return }
        XCTAssertFalse(servers.isEmpty)
    }

    func testServer() async throws {
        let response = try await client.request(.servers(serverId: yourServerId), dataType: ServerData.self)
        checkResponse(response)
    }

    func testGetServerLog() async throws {
        let response = try await client.request(.servers(serverId: yourServerId, op: .logs), dataType: ServerLogData.self)
        checkResponse(response)
    }

    func testUploadServerLog() async throws {
        let response = try await client.request(.servers(serverId: yourServerId, op: .logsShare), dataType: ServerLogShareData.self)
        XCTAssertNotNil(response)
    }

    func testGetServerRAM() async throws {
        let response = try await client.request(.servers(serverId: yourServerId, op: .ram()), dataType: ServerRAMData.self)
        guard let data = checkResponse(response)
        else { return }
        XCTAssertTrue(data.ram > 0)
    }

    func testChangeServerRAM() async throws {
        let dstRAM = 2
        let response = try await client.request(.servers(serverId: yourServerId, op: .ram(.init(ram: dstRAM))), dataType: ServerRAMData.self)
        guard let data = checkResponse(response)
        else { return }
        XCTAssertTrue(data.ram == dstRAM)
    }

    func testGetServerMOTD() async throws {
        let response = try await client.request(.servers(serverId: yourServerId, op: .motd()), dataType: ServerMOTDData.self)
        guard let data = checkResponse(response)
        else { return }
        XCTAssertFalse(data.motd.isEmpty)
    }

    func testChangeServerMOTD() async throws {
        let dstMOTD = "§b🗡 §7欢迎来到§ajokerhub§7的服务器！§b⛏"
        let response = try await client.request(.servers(serverId: yourServerId, op: .motd(.init(motd: dstMOTD))), dataType: ServerMOTDData.self)
        guard let data = checkResponse(response)
        else { return }
        XCTAssertTrue(data.motd == dstMOTD)
    }

    func testStartServer() async throws {
        let response = try await client.request(.servers(serverId: yourServerId, op: .start()), dataType: String.self)
        XCTAssertNotNil(response)
    }

    func testStartServerWithOwnCredits() async throws {
        let response = try await client.request(.servers(serverId: yourServerId, op: .start(.init(useOwnCredits: true))), dataType: String.self)
        XCTAssertNotNil(response)
    }

    func testStopServer() async throws {
        let response = try await client.request(.servers(serverId: yourServerId, op: .stop), dataType: String.self)
        XCTAssertNotNil(response)
    }

    func testRestartServer() async throws {
        let response = try await client.request(.servers(serverId: yourServerId, op: .restart), dataType: String.self)
        XCTAssertNotNil(response)
    }

    func testRunServerCommand() async throws {
        let response = try await client.request(.servers(serverId: yourServerId, op: .command(.init(command: "plugins"))), dataType: String.self)
        XCTAssertNotNil(response)
    }

    func testGetPlaylistTypes() async throws {
        let response = try await client.request(.servers(serverId: yourServerId, op: .playlist()), dataType: [String].self)
        guard let data = checkResponse(response)
        else { return }
        XCTAssertFalse(data.isEmpty)
    }

    func testGetPlaylistOfWhitelist() async throws {
        let response = try await client.request(.servers(serverId: yourServerId, op: .playlist(type: "whitelist")), dataType: [String].self)
        guard let data = checkResponse(response)
        else { return }
        XCTAssertFalse(data.isEmpty)
    }

    func testAddPlayerIntoWhitelist() async throws {
        let response = try await client.request(.servers(serverId: yourServerId, op: .playlist(type: "whitelist", op: .add(.init(entries: [yourTestPlayerName])))), dataType: [String].self)
        guard let data = checkResponse(response)
        else { return }
        XCTAssertTrue(data.contains(yourTestPlayerName))
    }

    func testDeletePlayerIntoWhitelist() async throws {
        let response = try await client.request(.servers(serverId: yourServerId, op: .playlist(type: "whitelist", op: .delete(.init(entries: [yourTestPlayerName])))), dataType: [String].self)
        guard let data = checkResponse(response)
        else { return }
        XCTAssertFalse(data.contains(yourTestPlayerName))
    }

    func testGetFileInfo() async throws {
        let dstPath = "/server.properties"
        let response = try await client.request(.servers(serverId: yourServerId, op: .fileInfo(path: dstPath)), dataType: ServerFileInfo.self)
        guard let data = checkResponse(response)
        else { return }
        XCTAssertTrue(data.path == dstPath)
        XCTAssertNil(data.children)
    }

    func testGetDirInfo() async throws {
        let dstPath = "/plugins"
        let response = try await client.request(.servers(serverId: yourServerId, op: .fileInfo(path: dstPath)), dataType: ServerFileInfo.self)
        guard let data = checkResponse(response)
        else { return }
        XCTAssertTrue(data.path == dstPath)
        XCTAssertNotNil(data.children)
    }

    func testGetFileData() async throws {
        let dstPath = "/bukkit.yml"
        let response = try await client.request(.servers(serverId: yourServerId, op: .fileData(path: dstPath)), dataType: Data.self)
        guard let data = checkResponse(response)
        else { return }
        XCTAssertNotNil(data)
        XCTAssertTrue(data.count > 0)
    }

    func testWriteFileData() async throws {
        let filePath = "new_test_file"
        let fileContentData = "test_write_file_content".data(using: .utf8)!
        let response = try await client.request(.servers(serverId: yourServerId, op: .fileData(path: filePath, op: .write(data: fileContentData))), dataType: String.self)
        XCTAssertNotNil(response)
        if let response {
            XCTAssertTrue(response.success)
            XCTAssertNil(response.data)
        }
    }

    func testDeleteFile() async throws {
        let filePath = "new_test_file"
        let response = try await client.request(.servers(serverId: yourServerId, op: .fileData(path: filePath, op: .delete)), dataType: String.self)
        XCTAssertNotNil(response)
        if let response {
            XCTAssertTrue(response.success || response.error == "Access denied")
            XCTAssertNil(response.data)
        }
    }

    func testGetFileConfigOptions() async throws {
        let configFilePath = "/server.properties"
        let response = try await client.request(.servers(serverId: yourServerId, op: .fileConfig(path: configFilePath)), dataType: [ServerFileConfig].self)
        guard let data = checkResponse(response)
        else { return }
        XCTAssertFalse(data.isEmpty)
    }

    func testUpdateFileConfigOptions() async throws {
        let configFilePath = "/server.properties"
        let key = "gamemode"
        let value = "survival"
        let kv = [key: value]
        let response = try await client.request(.servers(serverId: yourServerId, op: .fileConfig(path: configFilePath, kv: kv)), dataType: [ServerFileConfig].self)
        guard let data = checkResponse(response)
        else { return }
        let gameModeOption = data.filter { $0.key == key }.first
        XCTAssertNotNil(gameModeOption)
        if let gameMode = gameModeOption?.value.value as? String {
            XCTAssertTrue(gameMode == value)
        }
    }

    func testListCreditPools() async throws {
        let response = try await client.request(.creditPool(), dataType: [CreditPool].self)
        XCTAssertNotNil(response)
    }

    func testGetACreditPool() async throws {
        let response = try await client.request(.creditPool(poolId: yourCreditPoolId), dataType: CreditPool.self)
        guard let data = checkResponse(response)
        else { return }
        XCTAssertNotNil(data.id)
    }

    func testListCreditPoolMembers() async throws {
        let response = try await client.request(.creditPool(poolId: yourCreditPoolId, op: .members), dataType: [CreditPoolMember].self)
        XCTAssertNotNil(response)
    }

    func testListCreditPoolServers() async throws {
        let response = try await client.request(.creditPool(poolId: yourCreditPoolId, op: .servers), dataType: [ServerData].self)
        XCTAssertNotNil(response)
    }
}

extension ManualExarotonHTTPTests {
    
    @discardableResult
    func checkResponse<DataType: Codable>(_ response: Response<DataType>?) -> DataType? {
        guard let ret = response
        else {
            XCTAssertNotNil(nil)
            return nil
        }
        XCTAssertTrue(ret.success)
        XCTAssertNil(ret.error)
        return checkResponseData(ret.data)
    }

    @discardableResult
    func checkResponseData<DataType: Codable>(_ data: DataType?) -> DataType? {
        guard let data
        else {
            XCTAssertNotNil(nil)
            return nil
        }
        return data
    }
}
