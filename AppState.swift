//
//  AppState.swift
//  bblocks
//
//  Created by Ethan John on 4/4/22.
//

import SwiftUI
import Combine
import Starscream

class AppState: ObservableObject {
    enum Mode {
        case playing
        case menu
        case name
        case nameCode
    }
    @Published var mode: Mode
    @Published var game: Game?
    @Published var showShare = false
    @Published var gameField = String()
    @Published var userField = String()
    @Published var startingGame = false
    let api = API.live()
    var canc = Set<AnyCancellable>()
    var sock: GameSock?
    let local = false
    static let width = 13
    static let height = 20
    static let rows: [[Block]] = (0..<height).map { _ in (0..<width).map { _ in .empty } }
    static let grid = Grid(rows: rows)
    init(_ mode: Mode) {
        let name = UserDefaults.standard.object(forKey: "nickname") as? String
        userField = name ?? ""
        self.mode = mode
    }
    func nicknameUpdated(_ name: String) {
        UserDefaults.standard.set(name, forKey: "nickname")
    }
    func back() {
        mode = .menu
    }
    func newGame() {
        mode = .name
    }
    func loadGame() {
        mode = .nameCode
    }
    func start() {
        nicknameUpdated(userField)
        let game = Game(
            grid: Self.grid,
            players: [
                .init(team: .init(number: 1), id: userField),
                .init(team: .init(number: 2), id: "")
            ],
            mode: .base,
            id: nil,
            local: local,
            user: userField
        )
        setGame(game)
        if !local {
            startingGame = true
            api.saveGame(game)
                .receive(on: DispatchQueue.main)
                .sink { result in
                    guard case let .failure(error) = result else {
                        return
                    }
                    print(error)
                    self.startingGame = false
                } receiveValue: { output in
                    self.gameField = output
                    self.openGame()
                }
                .store(in: &canc)
        } else {
            mode = .playing
        }
    }
    func setGame(_ newGame: Game) {
        self.game = newGame
        self.game?.id = self.gameField
        self.game?.user = self.userField
        if game?.players.map(\.id).contains(userField) == false,
           let openSpot = self.game?.players.firstIndex(where: {
            $0.id == ""
        }) {
            newGame.players[openSpot].id = userField
        }
        newGame.objectWillChange
            .sink { _ in
                self.objectWillChange.send()
            }
            .store(in: &canc)
        if !local {
            newGame.updated
                .sink { game in
                    let _ = self.sock?.write(game.string)
                }
                .store(in: &canc)
        }
    }
    func exit() {
        if !local {
            sock?.close()
            canc.forEach { $0.cancel() }
            canc.removeAll()
            sock = nil
        }
        mode = .menu
        game = nil
    }
    func openGame() {
        nicknameUpdated(userField)
        if !local {
            sock = api.gameSock(gameField)
            sock?.recieve()
                .receive(on: DispatchQueue.main)
                .sink { result in
                    guard case let .failure(error) = result else {
                        return
                    }
                    print(error)
                } receiveValue: { value in
                    self.setGame(value)
                    self.startingGame = false
                    self.mode = .playing
                }
                .store(in: &canc)
            sock?.connectionStatus()
                .receive(on: DispatchQueue.main)
                .sink { connected in
                    self.game = nil
                    self.mode = .nameCode
                }
                .store(in: &canc)
        }
    }
    func copy() {
        guard let id = game?.id else {
            return
        }
        #if canImport(UIKit)
        UIPasteboard.general.string = id
        #else
        let pasteboard = NSPasteboard.general
        pasteboard.declareTypes([.string], owner: nil)
        pasteboard.setString(id, forType: .string)
        #endif
    }
}
