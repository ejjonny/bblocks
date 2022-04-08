//
//  API.swift
//  bblocks
//
//  Created by Ethan John on 4/5/22.
//

import Combine

struct API {
    let saveGame: (Game) -> AnyPublisher<String, Error>
    let gameSock: (String) -> GameSock
}
