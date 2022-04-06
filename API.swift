//
//  API.swift
//  bblocks
//
//  Created by Ethan John on 4/5/22.
//

import Combine

struct API {
    let saveGame: (Game) -> AnyPublisher<String, Error>
    let updateGame: (String, Game) -> AnyPublisher<String, Error>
    let loadGame: (String) -> AnyPublisher<Game, Error>
}
