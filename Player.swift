//
//  PLayer.swift
//  bblocks
//
//  Created by Ethan John on 4/4/22.
//

import Foundation

struct Player: Equatable {
    let team: Team
    var land = 0.0
    var placed = 0
    var bases = 1
    var dead = false
    var id: String
    init(team: Team, land: Double = 0, bases: Int = 1, dead: Bool = false, id: String) {
        self.team = team
        self.land = land
        self.bases = bases
        self.dead = dead
        self.id = id
    }
}
