//
//  Block.swift
//  bblocks
//
//  Created by Ethan John on 4/4/22.
//

import SwiftUI

struct Block: Identifiable, Hashable {
    init(blockType: BlockType) {
        self.blockType = blockType
    }
    
    let blockType: BlockType
    let id = UUID()
    
    static var empty: Self {
        Block(blockType: .empty)
    }
    var color: Color {
        switch blockType {
        case .land(let team, _):
            switch team.number {
            case 1:
                return .accent1
            case 2:
                return .accent2
            default:
                return .purple
            }
        case .base:
            return .accent4
        case .empty:
            return .alternate
        }
    }
}

indirect enum BlockType: Equatable, Hashable {
    case land(Team, Int)
    case base(Team)
    case empty
    var team: Team? {
        switch self {
        case .land(let team, _), .base(let team):
            return team
        case .empty:
            return nil
        }
    }
}
