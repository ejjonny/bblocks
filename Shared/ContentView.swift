//
//  ContentView.swift
//  Shared
//
//  Created by Ethan John on 4/3/22.
//


import SwiftUI
import Combine

struct ContentView: View {
    var body: some View {
        AppView(app: .init(.menu))
            .frame(maxHeight: .infinity)
    }
}

