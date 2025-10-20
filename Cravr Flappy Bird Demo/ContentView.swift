//
//  ContentView.swift
//  Cravr Flappy Bird Demo
//
//  Created by Ezra Akresh on 10/16/25.
//

import SwiftUI
import Combine
import UIKit

struct ContentView: View {
    @StateObject private var viewModel = GameViewModel()
    
    var body: some View {
        ZStack {
            // Star background
            StarBackground()
                .ignoresSafeArea()
            
            if viewModel.gameState == .menu {
                MenuView(viewModel: viewModel)
            } else {
                GameView(viewModel: viewModel)
            }
        }
        .contentShape(Rectangle())
        .onTapGesture {
            viewModel.handleTap()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

