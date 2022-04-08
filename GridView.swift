import SwiftUI

struct GridView: View {
    let size: CGFloat = 30
    let blockOpacity: CGFloat = 0.5
    let borderOpacity: CGFloat = 0.7
    @ObservedObject var game: Game
    var body: some View {
        LazyVGrid(
            columns: (0..<game.grid.rows[0].count).map { _ in
                GridItem(.flexible(minimum: 10, maximum: 100), spacing: 1)
            },
            spacing: 1
        ) {
            ForEach(game.grid.items.indices, id: \.self) { i in
                if case let .land(_, stack) = game.grid.items[i].blockType,
                   stack > 1 {
                    ZStack {
                        ForEach(0..<stack, id: \.self) { stackI in
                            RoundedRectangle(cornerRadius: 5)
                                .foregroundColor(game.grid.items[i].color)
                                .opacity(blockOpacity)
                                .aspectRatio(contentMode: .fit)
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 5)
                                        .stroke(game.grid.items[i].color, lineWidth: 1)
                                        .opacity(borderOpacity)
                                )
                                .offset(y: CGFloat(-1 * stackI))
                        }
                        Text("\(stack)")
                            .appText3()
                            .opacity(0.7)
                            .offset(y: CGFloat(-1 * stack))
                    }
                    .onTapGesture {
                        game.tapped(i)
                    }
                } else {
                    RoundedRectangle(cornerRadius: 5)
                        .foregroundColor(game.grid.items[i].color)
                        .opacity(blockOpacity)
                        .aspectRatio(contentMode: .fit)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .overlay(
                            RoundedRectangle(cornerRadius: 5)
                                .stroke(game.grid.items[i].color, lineWidth: 1)
                                .opacity(borderOpacity)
                        )
                        .onTapGesture {
                            game.tapped(i)
                        }
                        .shadow(color: game.currentPlayer.team.color.opacity(0.2), radius: 5, x: 0, y: 0)
                }
            }
            .blendMode(.hardLight)
        }
        .opacity(game.currentPlayerCanPlay && !game.finished ? 1 : 0.2)
    }
}
