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
            // Solid color background for both menu and game
            Color(hex: "88ced4")
                .ignoresSafeArea()
            
            // Scrolling background image (always visible)
            ScrollingBackgroundImage()
                .ignoresSafeArea()
            
            // Content
            if viewModel.gameState == .menu {
                MenuView(viewModel: viewModel)
            } else {
                GameView(viewModel: viewModel)
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

