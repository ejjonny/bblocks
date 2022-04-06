//
//  APILive.swift
//  bblocks
//
//  Created by Ethan John on 4/5/22.
//

import Foundation

extension API {
    static func live() -> Self {
        .init { game in
            var req = URLRequest(url: URL(string: "http://localhost:8080/game/new?state=\(game.string)")!)
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
        } updateGame: { id, game in
            var req = URLRequest(url: URL(string: "http://localhost:8080/game/update?id=\(id)&state=\(game.string)")!)
            req.httpMethod = "PATCH"
            return URLSession.shared.dataTaskPublisher(for: req)
                .map { data, response in
                    String(data: data, encoding: .utf8) ?? "oof"
                }
                .mapError { $0 as Error }
                .eraseToAnyPublisher()
        } loadGame: { id in
            URLSession.shared.dataTaskPublisher(for: URL(string: "http://localhost:8080/game?id=\(id)")!)
                .tryMap { data, response in
                    guard let state = String(data: data, encoding: .utf8),
                    let game = Game(state) else {
                        throw LocalError()
                    }
                    print(state)
                    return game
                }
                .eraseToAnyPublisher()
        }
    }
}

struct LocalError: Error {}
