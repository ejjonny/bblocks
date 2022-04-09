//
//  API.swift
//  bblocks
//
//  Created by Ethan John on 4/5/22.
//

import Combine

struct API {
    let saveGame: (Game) -> AnyPublisher<String, Error>
    let gameSock: (String, Game.Settings) -> GameSock
    let gameSettings: () -> AnyPublisher<Game.Settings, Error>
}

extension Publisher {
    func sin(_ fail: @escaping (Error) -> Void = { _ in }, succ: @escaping (Self.Output) -> Void) -> AnyCancellable {
        sink { result in
            guard case let .failure(error) = result else {
                return
            }
            fail(error)
        } receiveValue: { value in
            succ(value)
        }
    }
}
