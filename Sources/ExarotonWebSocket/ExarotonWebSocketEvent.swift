import Foundation

public enum ExarotonWebSocketEvent {
    case ready(serverID: String?)
    case connected
    case disconnected(reason: String?)
    case keepAlive

    case statusChanged(Server?)
    case streamStarted(StreamCategory)
    case streamStopped(StreamCategory)
    case consoleLine(String?)
    case tick(Tick?)
    case stats(Stats?)
    case heap(Heap?)

    case error(Error)
}
