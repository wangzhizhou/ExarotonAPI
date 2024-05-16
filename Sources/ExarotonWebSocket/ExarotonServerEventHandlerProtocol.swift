//
//  ExarotonServerEventHandlerProtocol.swift
//
//
//  Created by joker on 2024/5/15.
//

import Starscream

public protocol ExarotonServerEventHandlerProtocol: WebSocketDelegate {

    func onReady(serverID: String?)

    func onConnected()

    func onDisconnected(reason: String?)

    func onKeepAlive()

    func onStatusChanged(_ info: Server?)

    func onStreamStarted(_ stream: StreamCategory?)

    func onConsoleLine(_ line: String?)

    func onTick(_ tick: Tick?)

    func onStats(_ stats: Stats?)

    func onHeap(_ heap: Heap?)

}
