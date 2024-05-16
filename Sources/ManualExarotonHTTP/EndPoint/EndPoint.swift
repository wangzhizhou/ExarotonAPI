//
//  File.swift
//
//
//  Created by joker on 5/12/24.
//

import Foundation
public enum EndPoint {
    /// Get account Info
    case account

    /// List servers or Get a server with serverId
    public enum ServerOp {
        /// Get a server log of serverId
        case logs
        /// Upload a server log to mclo.gs
        case logsShare
        /// Get or Set server RAM
        case ram(_: ServerRAMData? = nil)
        /// Get or Set server MOTD
        case motd(_: ServerMOTDData? = nil)
        /// Start a server or Start a server with own credits
        case start(_: ServerStartData? = nil)
        /// Stop a server
        case stop
        /// Restart a server
        case restart
        /// Execute a server command
        case command(_: ServerCommandData? = nil)
        /// Get all or specified type of playlist
        public enum PlayListOp {
            case add(_: PlayerList)
            case delete(_: PlayerList)
        }
        /// Get player list
        case playlist(type:String? = nil, op: PlayListOp? = nil)
        /// Get file information
        case fileInfo(path: String)
        /// read\write\delete file data
        public enum FileDataOp {
            case write(data: Data)
            case delete
        }
        case fileData(path: String, op: FileDataOp? = nil)
        /// Get and set config options
        case fileConfig(path:String, kv: [String: String]? = nil)
    }
    case servers(serverId: String? = nil, op: ServerOp? = nil)


    /// Credits Pool
    public enum CreditPoolOp {
        case members
        case servers
    }
    case creditPool(poolId: String? = nil, op: CreditPoolOp? = nil)
}
