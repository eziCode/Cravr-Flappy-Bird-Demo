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
            // Scrolling background with stars and gradient (always visible)
            ScrollingBackgroundImage()
                .ignoresSafeArea()
                .id("scrolling_background") // Stable identity across transitions
            
            // Content
            if viewModel.gameState == .menu {
                MenuView(viewModel: viewModel)
                    .transition(.opacity)
            } else {
                GameView(viewModel: viewModel)
                    .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.3), value: viewModel.gameState)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

