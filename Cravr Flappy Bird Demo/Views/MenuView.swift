//
//  MenuView.swift
//  Cravr Flappy Bird Demo
//
//  Created by Ezra Akresh on 10/16/25.
//

import SwiftUI

struct MenuView: View {
    @ObservedObject var viewModel: GameViewModel
    @State private var logoPulseScale: CGFloat = 0.95
    @State private var slothHopOffset: CGFloat = 0
    
    var body: some View {
        VStack(spacing: 30) {
            Spacer()
            
            // Title Graphic
            VStack(spacing: 20) {
                // Game Title
                PixelTitle()
                    .scaleEffect(viewModel.hasPlayedOnce ? 1.0 : 1.1)
                    .animation(.easeInOut(duration: 1).repeatForever(autoreverses: true), value: viewModel.hasPlayedOnce)
                    .animation(.easeOut(duration: 0.1), value: viewModel.sloth.scale)
                    .scaleEffect(logoPulseScale) // Pulsing scale animation
                    .animation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true), value: logoPulseScale)
                    .onAppear {
                        logoPulseScale = 1.05
                    }
                
                // Sloth Logo
                Image("sloth-image")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: GameConstants.screenWidth * 0.25, height: GameConstants.screenWidth * 0.25) // 25% of screen width
                    .scaleEffect(viewModel.sloth.scale)
                    .offset(y: slothHopOffset)
                    .animation(.easeInOut(duration: 0.6).repeatForever(autoreverses: true), value: slothHopOffset)
                    .onAppear {
                        slothHopOffset = -15 // Hop up by 15 points
                    }
            }
            
            // High Score Display
            VStack(spacing: 10) {
                Text("HIGH SCORE")
                    .font(.system(size: GameConstants.screenWidth * 0.045, weight: .semibold, design: .rounded)) // 4.5% of screen width
                    .foregroundColor(Color(hex: "92dce5")) // Non Photo Blue
                    .shadow(color: .black, radius: 2, x: 1, y: 1)
                
                ZStack {
                    // Score background
                    RoundedRectangle(cornerRadius: GameConstants.screenWidth * 0.03) // 3% of screen width
                        .frame(width: GameConstants.screenWidth * 0.3, height: GameConstants.screenHeight * 0.065) // 30% width, 6.5% height
                        .foregroundColor(.black.opacity(0.6))
                        .blur(radius: 1)
                    
                    Text("\(viewModel.highScore)")
                        .font(.system(size: GameConstants.screenWidth * 0.07, weight: .bold, design: .rounded)) // 7% of screen width
                        .foregroundColor(Color(hex: "f7ec59")) // Maize
                        .shadow(color: .black, radius: 2, x: 1, y: 1)
                }
            }
            
            Spacer()
            
            // Tap to Start Text
            VStack(spacing: 15) {
                Text("TAP ANYWHERE")
                    .font(.system(size: GameConstants.screenWidth * 0.055, weight: .bold, design: .rounded)) // 5.5% of screen width
                    .foregroundColor(Color(hex: "92dce5")) // Non Photo Blue
                    .shadow(color: .black, radius: 2, x: 1, y: 1)
                
                Text("TO START")
                    .font(.system(size: GameConstants.screenWidth * 0.055, weight: .bold, design: .rounded)) // 5.5% of screen width
                    .foregroundColor(Color(hex: "92dce5")) // Non Photo Blue
                    .shadow(color: .black, radius: 2, x: 1, y: 1)
                    .opacity(0.9)
            }
            .scaleEffect(logoPulseScale) // Pulsing scale animation
            .animation(.easeInOut(duration: 1.2).repeatForever(autoreverses: true), value: logoPulseScale)
            
            Spacer()
        }
        .contentShape(Rectangle())
        .onTapGesture {
            viewModel.handleTap()
        }
    }
}
