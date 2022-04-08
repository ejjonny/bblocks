//
//  Game.swift
//  bblocks
//
//  Created by Ethan John on 4/4/22.
//

import SwiftUI
import Combine

class Game: ObservableObject {
    enum Mode {
        case base
        case prep
        case combat
    }
    enum PlayerStatus {
        case playing
        case dead
        case won(Player)
    }
    @Published var grid: Grid<Block>
    @Published var mode: Mode = .base
    @Published var hint: String?
    let initialBaseSize = 2
    let basePlacements = 6
    var players: [Player]
    var currentPlayerIndex = 0
    var id: String?
    var local: Bool
    var user: String?
    let updated = PassthroughSubject<Game, Never>()
    var currentPlayerCanPlay: Bool {
        currentPlayer.id == user || local
    }
    var playerStatus: PlayerStatus {
        if local {
            let alive = players.filter{ !$0.dead }
            let finished = alive.count == 1
            if finished, let winner = alive.first {
                return .won(winner)
            } else {
                return .playing
            }
        }
        let dead = players
            .filter(\.dead)
            .contains { $0.id == user }
        let won = players
            .filter { $0.id != user }
            .allSatisfy { $0.dead }
        if dead {
            return .dead
        } else if won,
                  let winner = players.first(where: { !$0.dead }) {
            return .won(winner)
        } else {
            return .playing
        }
    }
    var finished: Bool {
        switch playerStatus {
        case .playing:
            return false
        case .dead,
                .won:
            return true
        }
    }
    var currentPlayer: Player {
        get {
            players[currentPlayerIndex]
        }
        set {
            players[currentPlayerIndex] = newValue
        }
    }
    var blocksLeft: Int {
        switch mode {
        case .base:
            return 1
        case .prep:
            return basePlacements - currentPlayer.placed
        case .combat:
            return currentPlayer.placementsLeft
        }
    }
    init(grid: Grid<Block>, players: [Player], currentPlayerIndex: Int = 0, mode: Mode, id: String?, local: Bool, user: String?) {
        self.grid = grid
        self.mode = mode
        self.players = players
        self.currentPlayerIndex = currentPlayerIndex
        self.id = id
        self.local = local
        self.user = user
    }
    convenience init(grid: Grid<Block>, players: [Player], currentPlayerIndex: Int, mode: Mode = .base) {
        self.init(grid: grid, players: players, currentPlayerIndex: currentPlayerIndex, mode: mode, id: nil, local: false, user: nil)
    }
    func placeBase(_ team: Team, i: Int) -> Bool {
        defer { clearHint() }
        let solution = paths(from: i)
        for i in grid.items.indices {
            let block = grid.items[i]
            guard case let .base(baseTeam) = block.blockType,
                  baseTeam != team,
                  let solutionDistance = solution
                .first(where: { $0.block == block })?
                .pathLengthFromStart else {
                continue
            }
            if solutionDistance <= Double(basePlacements + 1) {
                hint = "You can be captured on the first turn with your base there. Pick somewhere further from enemies."
                return false
            }
        }
        grid[i] = .init(blockType: .base(team))
        var land = 1
        for point in grid.neighborPoints(i) {
            grid[point] = .init(blockType: .land(team, 1))
            land += 1
        }
        let meIndex = players.firstIndex {
            $0.team == team
        }
        players[meIndex!].land += land
        return true
    }
    func clearHint() {
        if hint != nil {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [weak self] in
                self?.hint = nil
            }
        }
    }
    func placePending(_ team: Team, i: Int) -> Bool {
        defer { clearHint() }
        let block = grid.items[i].blockType
        var isTouching = false
        for neighbor in grid.neighbors(i) {
            if case .land(team, _) = neighbor.blockType {
                isTouching = true
                break
            }
        }
        guard let playerIndex = players.firstIndex(where: { $0.team == team }) else {
            assertionFailure()
            return false
        }
        switch block {
        case .land(let blockTeam, let stack):
            guard isTouching else {
                hint = "You can only capture land next to a block you own"
                return false
            }
            if blockTeam != team {
                guard let enemyIndex = players.firstIndex(where: { $0.team == blockTeam }) else {
                    assertionFailure()
                    return false
                }
                if stack == 1 {
                    players[enemyIndex].land -= 1
                    grid[i] = .init(blockType: .land(team, 1))
                    currentPlayer.placed += 1
                    currentPlayer.land += 1
                    guard let baseIndex = grid.items.firstIndex(where: { $0.blockType == .base(blockTeam) }) else {
                        assertionFailure()
                        return false
                    }
                    let solution = paths(from: baseIndex) { block in
                        if case .land(blockTeam, _) = block.blockType {
                            return true
                        }
                        return false
                    }
                    for i in grid.items.indices {
                        let block = grid.items[i]
                        if solution.first(where: { $0.block == block })?.pathVerticesFromStart.isEmpty == true,
                           case .land(blockTeam, _) = block.blockType {
                            players[enemyIndex].land -= 1
                            grid[i] = .empty
                        }
                    }
                } else {
                    grid[i] = .init(blockType: .land(blockTeam, stack - 1))
                    currentPlayer.placed += 1
                }
                return true
            } else {
                grid[i] = .init(blockType: .land(team, stack + 1))
                currentPlayer.placed += 1
                return true
            }

        case .base(let blockTeam):
            if blockTeam != team, isTouching {
                guard let enemyIndex = players.firstIndex(where: { $0.team == blockTeam }) else {
                    assertionFailure()
                    return false
                }
                
                grid.items.indices.filter {
                    switch grid.items[$0].blockType {
                    case .land(blockTeam, _):
                        return true
                    default:
                        return false
                    }
                }
                .forEach { i in
                    grid[i] = .init(blockType: .land(team, 1))
                    players[playerIndex].land += 1
                }
                currentPlayer.bases += 1
                players[enemyIndex].dead = true
                grid[i] = .init(blockType: .base(team))
                currentPlayer.placed += 1
                return true
            }
            hint = "You can't stack blocks on your base"
        case .empty:
            if isTouching {
                grid[i] = .init(blockType: .land(team, 1))
                currentPlayer.placed += 1
                currentPlayer.land += 1
                return true
            }
            hint = "You can only capture land next to a block you own"
        }
        return false
    }
    func tapped(_ i: Int) {
        guard currentPlayerCanPlay && !finished else {
            return
        }
        defer { updated.send(self) }
        switch mode {
        case .base:
            if placeBase(currentPlayer.team, i: i) {
                mode = .prep
            }
        case .prep:
            let placed = placePending(currentPlayer.team, i: i)
            if placed, currentPlayer.placed >= basePlacements {
                currentPlayer.placed = 0
                if advancePlayers() {
                    mode = .base
                } else {
                    mode = .combat
                }
            }
        case .combat:
            let placed = placePending(currentPlayer.team, i: i)
            if placed, Double(currentPlayer.placed) >= currentPlayer.placements.rounded(.down) {
                currentPlayer.placed = 0
                advancePlayers()
                while currentPlayer.dead {
                    advancePlayers()
                }
            }
        }
    }
    @discardableResult
    func advancePlayers() -> Bool {
        if players.indices.contains(currentPlayerIndex + 1) {
            currentPlayerIndex += 1
            return true
        } else {
            currentPlayerIndex = 0
            return false
        }
    }
    func path(from: Int, to: Int, validBlocks: (Block) -> Bool = { _ in true }) -> [Block] {
        let blockSet = paths(from: from, validBlocks: validBlocks)
        guard let toIndex = blockSet.firstIndex(of: Vertex(block: grid.items[to])) else {
            return []
        }
        let solution = blockSet[toIndex].pathVerticesFromStart
        return Array(solution).map(\.block)
    }
    func paths(from: Int, validBlocks: (Block) -> Bool = { _ in true }) -> Set<Vertex> {
        let blocks = grid.items.map { Vertex(block: $0 ) }
        for i in blocks.indices {
            blocks[i].neighbours = grid.neighbors(i)
                .filter(validBlocks)
                .compactMap { neighbor in
                    blocks.first(where: { $0.block == neighbor })
                }
                .map { ($0, 1) }
        }
        let blockSet = Set(blocks)
        guard let fromIndex = blockSet.firstIndex(of: blocks[from]) else {
            return []
        }
        var dij = Dijkstra(vertices: blockSet)
        dij.findShortestPaths(from: blockSet[fromIndex])
        return blockSet
    }
}
