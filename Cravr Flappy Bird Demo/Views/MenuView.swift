//
//  MenuView.swift
//  Cravr Flappy Bird Demo
//
//  Created by Ezra Akresh on 10/16/25.
//

import SwiftUI

struct MenuView: View {
    @ObservedObject var viewModel: GameViewModel
    
    var body: some View {
        VStack(spacing: 30) {
            Spacer()
            
            // Title Graphic
            VStack(spacing: 20) {
                // Game Title
                PixelTitle()
                    .scaleEffect(viewModel.hasPlayedOnce ? 1.0 : 1.1)
                    .animation(.easeInOut(duration: 1).repeatForever(autoreverses: true), value: viewModel.hasPlayedOnce)
                
                // Sloth Logo
                SlothIcon(size: 100)
                    .scaleEffect(viewModel.sloth.scale)
                    .animation(.easeOut(duration: 0.1), value: viewModel.sloth.scale)
            }
            
            // High Score Display
            VStack(spacing: 10) {
                Text("HIGH SCORE")
                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                    .foregroundColor(Color(hex: "92dce5")) // Non Photo Blue
                    .shadow(color: .black, radius: 2, x: 1, y: 1)
                
                ZStack {
                    // Score background
                    RoundedRectangle(cornerRadius: 12)
                        .frame(width: 120, height: 50)
                        .foregroundColor(.black.opacity(0.6))
                        .blur(radius: 1)
                    
                    Text("\(viewModel.highScore)")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundColor(Color(hex: "f7ec59")) // Maize
                        .shadow(color: .black, radius: 2, x: 1, y: 1)
                }
            }
            
            Spacer()
            
            // Menu Buttons
            VStack(spacing: 20) {
                // Play Button
                Button(action: {
                    viewModel.startGame()
                }) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 15)
                            .frame(width: 200, height: 60)
                            .foregroundColor(Color(hex: "1cd91f")) // SGBus Green
                            .shadow(color: .black.opacity(0.3), radius: 3, x: 2, y: 2)
                        
                        Text("PLAY")
                            .font(.system(size: 24, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                            .shadow(color: .black, radius: 2, x: 1, y: 1)
                    }
                }
                .scaleEffect(1.0)
                .animation(.easeOut(duration: 0.1), value: viewModel.sloth.scale)
                
                // Back Button (TODO)
                Button(action: {
                    // TODO: Implement back button functionality to dismiss to rest of app
                    print("Back button tapped - TODO: implement dismiss functionality")
                }) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 12)
                            .frame(width: 160, height: 50)
                            .foregroundColor(Color(hex: "fa7921")) // Pumpkin
                            .shadow(color: .black.opacity(0.3), radius: 2, x: 1, y: 1)
                        
                        Text("BACK")
                            .font(.system(size: 18, weight: .semibold, design: .rounded))
                            .foregroundColor(.white)
                            .shadow(color: .black, radius: 1, x: 1, y: 1)
                    }
                }
            }
            
            Spacer()
        }
    }
}
