//
//  AppView.swift
//  bblocks
//
//  Created by Ethan John on 4/4/22.
//
#if canImport(UIKit)
import UIKit
#endif
import SwiftUI

struct AppView: View {
    @ObservedObject var app: AppState
    var body: some View {
        switch app.mode {
        case .playing:
            if let game = app.game {
                GameView(game: game)
            }
            HStack {
                Button {
                    app.exit()
                } label: {
                    Text("Exit Game")
                        .appText()
                        .section()
                }
                .buttonStyle(.plain)
                .foregroundColor(.main)
#if canImport(UIKit)
                .sheet(isPresented: $app.showShare) {
                    ShareSheet(activityItems: ["no.bblocks/\(app.game!.string)"])
                }
#endif
                Button {
                    app.copy()
                } label: {
                    Text("Copy Code")
                        .appText()
                }
                .section()
                .buttonStyle(.plain)
                .foregroundColor(.main)
            }
        case .menu:
            VStack(spacing: 20) {
                Button {
                    app.newGame()
                } label: {
                    Text("New Game")
                        .appText()
                        .section()
                }
                .buttonStyle(.plain)
                Button {
                    app.loadGame()
                } label: {
                    Text("Load Game")
                        .appText()
                        .section()
                }
                .buttonStyle(.plain)
            }
            .foregroundColor(.main)
        case .name:
            TextField(
                "Nickname",
                text: $app.userField
            )
                .font(.system(.title, design: .rounded))
                .section()
            Button {
                app.start()
            } label: {
                if app.startingGame {
                    Squinner()
                } else {
                    Text("Start")
                        .appText()
                        .section()
                }
            }
            .buttonStyle(.plain)
            .disabled(app.userField.isEmpty || app.startingGame)
            Button {
                app.back()
            } label: {
                Text("Back")
                    .appText()
                    .section()
            }
            .buttonStyle(.plain)
        case .nameCode:
            TextField(
                "Nickname",
                text: $app.userField
            )
                .font(.system(.title, design: .rounded))
                .section()
            TextField("Game Code", text: $app.gameField)
                .font(.system(.title, design: .rounded))
                .section()
            Button {
                app.openGame()
            } label: {
                Text("Load")
                    .appText()
                    .section()
            }
            .buttonStyle(.plain)
            .disabled(app.gameField.isEmpty || app.userField.isEmpty)
            Button {
                app.back()
            } label: {
                Text("Back")
                    .appText()
                    .section()
            }
            .buttonStyle(.plain)
        }
    }
}

struct Squinner: View {
    @State var animating = false
    var body: some View {
        RoundedRectangle(cornerRadius: animating ? 5 : 12)
            .stroke(lineWidth: 5)
            .animation(.easeInOut.repeatForever(autoreverses: true).speed(0.5), value: animating)
            .frame(width: 25, height: 25)
            .rotationEffect(animating ? Angle(degrees: 0) : Angle(degrees: 360))
            .animation(.easeInOut.repeatForever(autoreverses: false).speed(0.5), value: animating)
            .onAppear {
                animating.toggle()
            }
    }
}

#if canImport(UIKit)
struct ShareSheet: UIViewControllerRepresentable {
    typealias Callback = (_ activityType: UIActivity.ActivityType?, _ completed: Bool, _ returnedItems: [Any]?, _ error: Error?) -> Void
    
    let activityItems: [Any]
    let applicationActivities: [UIActivity]? = nil
    let excludedActivityTypes: [UIActivity.ActivityType]? = nil
    let callback: Callback? = nil
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(
            activityItems: activityItems,
            applicationActivities: applicationActivities)
        controller.excludedActivityTypes = excludedActivityTypes
        controller.completionWithItemsHandler = callback
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {
        // nothing to do here
    }
}
#endif
