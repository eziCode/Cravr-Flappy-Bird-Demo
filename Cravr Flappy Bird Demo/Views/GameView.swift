//
//  GameView.swift
//  Cravr Flappy Bird Demo
//
//  Created by Ezra Akresh on 10/16/25.
//

import SwiftUI

struct GameView: View {
    @ObservedObject var viewModel: GameViewModel
    
    var body: some View {
        ZStack {
            // Sloth with enhanced styling
            SlothIcon(size: 40)
                .scaleEffect(viewModel.sloth.scale)
                .animation(.easeOut(duration: 0.1), value: viewModel.sloth.scale)
                .position(x: 100, y: viewModel.sloth.y + GameConstants.screenCenter)
            
            // Enhanced Pipes
            ForEach(viewModel.pipes) { pipe in
                PipeView(pipe: pipe)
            }
            
            // Enhanced Score Display (only show when playing)
            if viewModel.gameState == .playing {
                ZStack {
                    // Score background
                    RoundedRectangle(cornerRadius: 15)
                        .frame(width: 200, height: 60)
                        .foregroundColor(.black.opacity(0.6))
                        .blur(radius: 1)
                    
                    Text("Score: \(viewModel.score)")
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundColor(Color(hex: "f7ec59")) // Maize
                        .shadow(color: .black, radius: 2, x: 1, y: 1)
                }
                .position(x: GameConstants.screenWidth / 2, y: 60)
            }
        }
    }
}

struct PipeView: View {
    let pipe: Pipe
    
    var body: some View {
        ZStack {
            // Top pipe - extended beyond screen
            ZStack {
                Image("tree-trunk-pipe-image")
                    .resizable()
                    .scaledToFill()
                    .frame(width: GameConstants.pipeWidth, height: pipe.topHeight + 300) // Consistent width, variable height
                    .scaleEffect(x: 1, y: -1) // Only reflection, no width scaling
                    .offset(x: -19.5, y: -150) // Use off-screen content for gap
                    .position(x: pipe.x, y: pipe.topHeight / 2)
            }
            
            // Bottom pipe - extended beyond screen
            ZStack {
                Image("tree-trunk-pipe-image")
                    .resizable()
                    .scaledToFill()
                    .frame(width: GameConstants.pipeWidth, height: pipe.bottomHeight + 300) // Consistent width, variable height
                    .scaleEffect(x: 0.6, y: 1) // No scaling
                    .offset(x: -19.5, y: 150) // Use off-screen content for gap
                    .position(x: pipe.x, y: UIScreen.main.bounds.height - (pipe.bottomHeight / 2))
            }
        }
    }
}
