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
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .foregroundColor(game.currentPlayer.team.color.opacity(0.5))
                    )
            }
#endif
            GridView(game: game)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .foregroundColor(game.currentPlayer.team.color.opacity(0.5))
                )
                .clipShape(
                    RoundedRectangle(cornerRadius: 10)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .strokeBorder(Color.main.opacity(0.5), lineWidth: 2)
                )
                .padding([.leading, .trailing])
                .frame(height: 500)
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
                                    Text("Land: \(game.players[i].land)")
                                        .appText2()
                                    Text("Bases: \(game.players[i].bases)")
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
            if game.dirty == false {
                Text("Waiting for other player...")
                    .appText2()
            } else if !game.canPlay {
                Text("Tap Save to finish your turn...")
                    .appText2()
            }
        }
    }
}
