//
//  APILive.swift
//  bblocks
//
//  Created by Ethan John on 4/5/22.
//

import Foundation
import Combine
import Starscream

extension API {
    enum Env: String {
        case prod = "137.184.176.138"
        case local = "localhost:8080"
    }
    static let base = Env.prod
    static func live() -> Self {
        .init { game in
            var req = URLRequest(url: URL(string: "http://\(base.rawValue)/game/new?state=\(game.string)")!)
            req.httpMethod = "POST"
            return URLSession.shared.dataTaskPublisher(for: req)
                .tryMap { data, response in
                    guard let id = String(data: data, encoding: .utf8) else {
                        throw LocalError()
                    }
                    return id
                }
                .mapError { $0 as Error }
                .eraseToAnyPublisher()
        } gameSock: { id in
            var req = URLRequest(url: URL(string: "ws://\(base.rawValue)/gameSock?id=\(id)")!)
            req.timeoutInterval = 5
            let sock = WebSocket(request: req)
            sock.connect()
            let textPassthrough = PassthroughSubject<Game, Error>()
            let connection = PassthroughSubject<Bool, Never>()
            sock.onEvent = { event in
                switch event {
                case .text(let string):
                    if let game = Game(string) {
                        textPassthrough.send(game)
                    } else {
                        textPassthrough.send(completion: .failure(LocalError()))
                    }
                case .connected:
                    connection.send(true)
                case let .reconnectSuggested(suggestion):
                    if suggestion {
                        sock.disconnect()
                        sock.connect()
                    }
                case .disconnected(let reason, let code):
                    print("\(reason)", "\(code)")
                    connection.send(false)
                case .error(let error):
                    print("\(String(describing: error))")
                    connection.send(false)
                case .cancelled:
                    connection.send(false)
                case .binary,
                        .ping,
                        .pong,
                        .viabilityChanged:
                    break
                }
            }
            return GameSock { string in
                sock.write(string: string)
            } recieve: {
                textPassthrough.eraseToAnyPublisher()
            } connectionStatus: {
                connection.eraseToAnyPublisher()
            } close: {
                sock.disconnect()
            }
        }
    }
}
struct GameSock {
    let write: (String) -> ()
    let recieve: () -> AnyPublisher<Game, Error>
    let connectionStatus: () -> AnyPublisher<Bool, Never>
    let close: () -> Void
}

struct LocalError: Error {}
