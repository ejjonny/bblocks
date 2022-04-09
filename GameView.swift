//
//  GameView.swift
//  bblocks
//
//  Created by Ethan John on 4/4/22.
//

import SwiftUI

struct GameView: View {
    let size: CGFloat = 30
    @ObservedObject var game: Game
    var body: some View {
        VStack(spacing: 10) {
#if canImport(UIKit)
            ZoomableScrollView {
                GridView(game: game)
                    .padding()
            }
            .clipShape(
                RoundedRectangle(cornerRadius: 10)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .strokeBorder(game.currentPlayer.team.color, lineWidth: 2)
            )
            .padding([.leading, .trailing])

#else
            GridView(game: game)
                .padding()
                .clipShape(
                    RoundedRectangle(cornerRadius: 10)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .strokeBorder(game.currentPlayer.team.color, lineWidth: 2)
                )
                .padding([.leading, .trailing])
                .frame(height: 500)
#endif
            HStack(alignment: .top) {
                if let hint = game.hint {
                    Text(hint)
                        .appText2()
                        .lineLimit(nil)
                        .fixedSize(horizontal: false, vertical: true)
                        .transition(.opacity)
                        .animation(.default, value: game.hint)
                } else {
                    VStack(alignment: .leading) {
                        ForEach(game.players.indices, id: \.self) { i in
                            HStack(alignment: .top) {
                                Text("\(game.players[i].team.name)")
                                    .appText()
                                    .foregroundColor(game.players[i].team.color)
                                VStack(alignment: .leading) {
                                    Text(String(format: "Land: %.2f", game.players[i].land))
                                        .appText2()
                                    Text("Bases: \(game.players[i].bases)")
                                        .appText2()
                                    Text(String(format: "Blocks/turn: %.2f", game.currentPlayerPlacements))
                                        .appText2()
                                }
                            }
                        }
                    }
                    Spacer()
                    Text("Blocks Left: \(game.blocksLeft)")
                        .appText2()
                }
            }
            .frame(height: 100)
            .section()
        }
        .overlay {
            if game.currentPlayerCanPlay == false, !game.finished {
                Text("Waiting for other player...")
                    .appText2()
            }
        }
        .overlay {
            switch game.playerStatus {
            case .playing:
                EmptyView()
            case let .won(player):
                if game.local {
                    Text("\(player.team.name) wins!")
                        .appText()
                } else {
                    Text("You won!")
                        .appText()
                }
            case .dead:
                Text("You died!")
                    .appText()
            }
        }
    }
}
