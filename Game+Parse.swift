//
//  Game+Parse.swift
//  bblocks
//
//  Created by Ethan John on 4/5/22.
//

import Parsing

extension Game {
    convenience init?(_ input: String) {
        let block = Parse {
            OneOf {
                Parse {
                    "e"
                }
                .map { BlockType.empty }
                Parse {
                    "t"
                    Int.parser().map(Team.init(number:))
                    "s"
                    Int.parser()
                }
                .map { BlockType.land($0, $1) }
                Parse {
                    "b"
                    Int.parser().map(Team.init(number:))
                }
                .map { BlockType.base($0) }
            }
        }
            .map { Block(blockType: $0) }
        let grid = Parse {
            "gr"
            Many {
                "r"
                Many {
                    block
                }
            }
            .map(Array<Array<Block>>.init)
        }
            .map(Grid<Block>.init(rows:))
        let players = Parse {
            "p"
            Many {
                Parse {
                    Parse {
                        "t"
                        Int.parser().map(Team.init(number:))
                    }
                    Parse {
                        "l"
                        Int.parser()
                    }
                    Parse {
                        "b"
                        Int.parser()
                    }
                    Parse {
                        "d"
                        OneOf {
                            "d".map { true }
                            "a".map { false }
                        }
                    }
                    Parse {
                        "u"
                        PrefixUpTo("u").map(String.init)
                        "u"
                    }
                }
                .map(Player.init(team:land:bases:dead:id:))
            }
        }
        let modes = OneOf {
            "b".map { Game.Mode.base }
            "p".map { Game.Mode.prep }
            "c".map { Game.Mode.combat }
        }
        let main = Parse {
            grid
            players
            "cpx"
            Int.parser()
            "m"
            modes
            
        }
            .map(Game.init(grid:players:currentPlayerIndex:mode:))
        
        guard let parsed = try? main.parse(input) else {
            return nil
        }
        self.init(grid: parsed.grid, players: parsed.players, currentPlayerIndex: parsed.currentPlayerIndex, mode: parsed.mode)
    }
}


extension Game {
    var string: String {
        """
        \(grid.string)p\(players.map(\.string).joined())cpx\(currentPlayerIndex)m\(mode.string)
        """
    }
}
extension Game.Mode {
    var string: String {
        switch self {
        case .base: return "b"
        case .prep: return "p"
        case .combat: return "c"
        }
    }
}
extension Player {
    var string: String {
        """
        t\(team.string)l\(land)b\(bases)d\(dead ? "d" : "a")u\(id)u
        """
    }
}
extension Grid where T == Block {
    var string: String {
        """
        gr\(rows.string)
        """
    }
}
extension Array where Element == [Block] {
    var string: String {
        map { "r\($0.string)" }.joined()
    }
}
extension Array where Element == Block {
    var string: String {
        map(\.string).joined()
    }
}

extension Block {
    var string: String {
        """
        \(blockType.string)
        """
    }
}
extension BlockType {
    var string: String {
        switch self {
        case .empty:
            return "e"
        case let .land(t, stack):
            return "t\(t.string)s\(stack)"
        case let .base(t):
            return "b\(t.string)"
        }
    }
}
extension Team {
    var string: String {
        "\(number)"
    }
}
