//
//  StarBackground.swift
//  Cravr Flappy Bird Demo
//
//  Created by Ezra Akresh on 10/16/25.
//

import SwiftUI

// MARK: - Star Background
struct StarBackground: View {
    @State private var stars: [Star] = []
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Green gradient background (Cravr theme)
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color("0d4f0d"), // Dark green
                        Color("1cd91f"), // SGBus Green
                        Color("0a3a0a")  // Darker green
                    ]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                
                // Stars
                ForEach(stars, id: \.id) { star in
                    Circle()
                        .fill(star.color.opacity(star.opacity))
                        .frame(width: star.size, height: star.size)
                        .position(star.position)
                        .animation(.linear(duration: star.twinkleDuration).repeatForever(autoreverses: true), value: star.opacity)
                }
            }
            .onAppear {
                generateStars(in: geometry.size)
            }
        }
    }
    
    private func generateStars(in size: CGSize) {
        let starColors = [
            Color.white,
            Color("f7ec59"), // Maize
            Color("fa7921"), // Pumpkin
            Color("92dce5")  // Non Photo Blue
        ]
        
        stars = (0..<100).map { _ in
            Star(
                position: CGPoint(
                    x: CGFloat.random(in: 0...size.width),
                    y: CGFloat.random(in: 0...size.height)
                ),
                size: CGFloat.random(in: 1...3),
                opacity: Double.random(in: 0.3...1.0),
                twinkleDuration: Double.random(in: 1...3),
                color: starColors.randomElement() ?? Color.white
            )
        }
    }
}

struct Star {
    let id = UUID()
    let position: CGPoint
    let size: CGFloat
    let opacity: Double
    let twinkleDuration: Double
    let color: Color
}
