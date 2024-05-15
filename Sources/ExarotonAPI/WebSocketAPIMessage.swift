//
//  WebSocketAPIMessage.swift
//  
//
//  Created by joker on 2024/5/15.
//

import AnyCodable

/// All messages received from or sent to the websocket are JSON strings.
/// Every JSON object has a type property, and may additionally have a data and a stream property.
///
/// https://developers.exaroton.com/#header-basic-messages
struct WebSocketAPIMessage<T: Codable>: Codable {

    /// Messages that include a stream property are a part of a specific data stream.
    /// There are 5 different data streams available in the WebSocket API
    enum Stream: String, Codable {

        /// By default, you are always subscribed to server status changes.
        /// The only message type in this stream is status
        /// The data field of this message is a regular API server object.
        case status

        /// The console stream can be used to receive a live feed of the server’s console output.
        /// Note that this is the server’s raw console output, so it might contain both ANSI escape codes and control characters.
        case console
        case tick
        case stats
        case heap
    }
    let stream: Stream?

    let type: T

    let data: AnyCodable?
}

enum BasicType: String, Codable {

    /// Sent after opening a websocket connection. data is the ID of the server you connected to.
    /// Before this message is received, no messages should be sent to the websocket.
    case ready

    /// Sent when a connection to a running game server is established.
    case connected

    /// Sent when a connection to a game server failed or was lost. data includes the reason for the disconnect.
    case disconnected

    /// Sent when if no other messages were sent for a longer period of time. This message can be ignored.
    case keepAlive = "keep-alive"
}

enum StreamType: String, Codable {

    /// By default, you are always subscribed to server status changes.
    /// The only message type in this stream is status
    case status

    /// You can subscribe to the console stream by sending a start message while the server is running
    case start

    /// You can unsubscribe by sending a stop message
    case stop

    /// Additional to receiving console output, this stream can also be used as a faster way of sending commands to the server
    case command

    /// A started messages is sent when the stream was started successfully.
    case started

    /// Console line messages include a line of console output.
    case line

    /// tick messages include the current average tick time (in ms).
    case tick

    /// stats messages include the current memory usage.
    case stats

    /// heap messages include the current memory usage.
    case heap
}


import Foundation

extension String {

    static let jsonDecoder = JSONDecoder()

    func wsMessage<T: Codable>(with type: T.Type) throws -> WebSocketAPIMessage<T>? {
        guard let data = self.data(using: .utf8)
        else {
            return nil
        }
        let message = try Self.jsonDecoder.decode(WebSocketAPIMessage<T>.self, from: data)
        return message
    }
}
