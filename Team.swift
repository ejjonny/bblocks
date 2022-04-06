//
//  Team.swift
//  bblocks
//
//  Created by Ethan John on 4/4/22.
//

import SwiftUI

struct Team: Equatable, Hashable {
    let number: Int
    var color: Color {
        switch number {
        case 1:
            return .accent1
        case 2:
            return .accent2
        default:
            return .purple
        }
    }
    var name: String {
        "P\(number)"
    }
}
