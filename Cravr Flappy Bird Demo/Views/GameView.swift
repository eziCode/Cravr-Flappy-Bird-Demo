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
        VStack(spacing: 0) {
            // Top pipe
            ZStack {
                Rectangle()
                    .frame(width: GameConstants.pipeWidth + 4, height: pipe.topHeight + 4)
                    .foregroundColor(.black.opacity(0.3))
                    .offset(x: 2, y: 2)
                
                Rectangle()
                    .frame(width: GameConstants.pipeWidth, height: pipe.topHeight)
                    .foregroundStyle(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color(hex: "1cd91f"), // SGBus Green
                                Color(hex: "0d4f0d")  // Darker green for depth
                            ]),
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .overlay(
                        Rectangle()
                            .frame(width: GameConstants.pipeWidth - 8, height: 8)
                            .foregroundColor(Color(hex: "92dce5")) // Non Photo Blue accent
                            .offset(y: pipe.topHeight/2 - 4)
                    )
            }
            
            Spacer().frame(height: GameConstants.pipeSpacing)
            
            // Bottom pipe
            ZStack {
                Rectangle()
                    .frame(width: GameConstants.pipeWidth + 4, height: pipe.bottomHeight + 4)
                    .foregroundColor(.black.opacity(0.3))
                    .offset(x: 2, y: -2)
                
                Rectangle()
                    .frame(width: GameConstants.pipeWidth, height: pipe.bottomHeight)
                    .foregroundStyle(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color(hex: "0d4f0d"), // Darker green for depth
                                Color(hex: "1cd91f")  // SGBus Green
                            ]),
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .overlay(
                        Rectangle()
                            .frame(width: GameConstants.pipeWidth - 8, height: 8)
                            .foregroundColor(Color(hex: "92dce5")) // Non Photo Blue accent
                            .offset(y: -pipe.bottomHeight/2 + 4)
                    )
            }
        }
        .position(x: pipe.x, y: GameConstants.screenCenter)
    }
}
