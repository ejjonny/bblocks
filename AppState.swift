//
//  AppState.swift
//  bblocks
//
//  Created by Ethan John on 4/4/22.
//

import SwiftUI
import Combine

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
    @Published var gameSaving = false
    @Published var areYouSure = false
    let api = API.live()
    var canc = Set<AnyCancellable>()
    static let width = 18
    static let height = 25
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
        mode = .playing
        game = .init(
            grid: Self.grid,
            players: [
                .init(team: .init(number: 1), id: userField),
                .init(team: .init(number: 2), id: "")
            ],
            mode: .base,
            id: nil,
            local: true,
            user: userField
        )
    }
    func exit() {
        guard game?.dirty == false ||
                areYouSure else {
            areYouSure = true
            return
        }
        areYouSure = false
        mode = .menu
        game = nil
    }
    func openGame() {
        nicknameUpdated(userField)
        api.loadGame(gameField)
            .receive(on: DispatchQueue.main)
            .sink { result in
                guard case let .failure(error) = result else {
                    return
                }
                print(error)
            } receiveValue: { loaded in
                if self.game?.currentPlayer.id.isEmpty == true {
                    self.game?.currentPlayer.id = self.userField
                }
                self.game = loaded
                self.game?.id = self.gameField
                self.game?.user = self.userField
                self.game?.dirty = false
                self.mode = .playing
            }
            .store(in: &canc)
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
    func save() {
//        guard false else {
//            print(game!.string)
//            print(Game(game!.string)!)
//            return
//        }
        guard let game = game else {
            return
        }
        gameSaving = true
        if let id = game.id {
            api.updateGame(id, game)
                .receive(on: DispatchQueue.main)
                .sink { result in
                    guard case let .failure(error) = result else {
                        return
                    }
                    print(error)
                    self.gameSaving = false
                } receiveValue: { success in
                    print(success)
                    self.gameSaving = false
                    self.game?.dirty = false
                }
                .store(in: &canc)
        } else {
            api.saveGame(game)
                .receive(on: DispatchQueue.main)
                .sink { result in
                    guard case let .failure(error) = result else {
                        return
                    }
                    print(error)
                    self.gameSaving = false
                } receiveValue: { uid in
                    game.id = uid
                    self.gameSaving = false
                    self.game?.dirty = false
                }
                .store(in: &canc)
        }
    }
}
