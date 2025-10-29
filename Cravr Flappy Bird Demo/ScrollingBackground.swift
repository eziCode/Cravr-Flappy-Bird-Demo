//
//  ScrollingBackground.swift
//  Cravr Flappy Bird Demo
//
//  Created by Ezra Akresh on 10/28/25.
//

import SwiftUI
import Combine

// Persistent scroll state that survives view transitions
class ScrollingBackgroundState: ObservableObject {
    @Published var offset: CGFloat = 0
    @Published var cloudOffset1: CGFloat = 0
    @Published var cloudOffset2: CGFloat = 0
    @Published var cloudOffset3: CGFloat = 0
    @Published var starOffset: CGFloat = 0
}

// Star struct from StarBackground
struct Star {
    let id = UUID()
    let position: CGPoint
    let size: CGFloat
    let opacity: Double
    let twinkleDuration: Double
    let color: Color
}

struct ScrollingBackgroundImage: View {
    @StateObject private var scrollState = ScrollingBackgroundState()
    @State private var stars: [Star] = []
    
    var body: some View {
        GeometryReader { geometry in
            let screenWidth = geometry.size.width
            let screenHeight = geometry.size.height
            
            ZStack {
                // Dark mode green gradient background
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(hex: "0d4f0d"), // Dark green
                        Color(hex: "1cd91f"), // SGBus Green
                        Color(hex: "0a3a0a")  // Darker green
                    ]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                
                // Stars with scrolling - enhanced visibility
                TimelineView(.animation) { timeline in
                    ZStack {
                        ForEach(stars, id: \.id) { star in
                            Circle()
                                .fill(star.color.opacity(star.opacity))
                                .frame(width: star.size, height: star.size)
                                .position(x: star.position.x + scrollState.starOffset, y: star.position.y)
                                .shadow(color: star.color.opacity(0.8), radius: star.size * 1.5)
                                .shadow(color: star.color.opacity(0.4), radius: star.size * 3)
                                .animation(.linear(duration: star.twinkleDuration).repeatForever(autoreverses: true), value: star.opacity)
                        }
                    }
                    .onChange(of: timeline.date) { _ in
                        // Scroll stars left slowly
                        let starScrollSpeed = screenWidth * 0.002
                        scrollState.starOffset -= starScrollSpeed
                        
                        // Reset offset when stars have scrolled far enough
                        if scrollState.starOffset <= -screenWidth * 2 {
                            scrollState.starOffset = 0
                        }
                    }
                }
                .onAppear {
                    generateStars(in: geometry.size)
                }
            }
        }
        .ignoresSafeArea()
        .allowsHitTesting(false) // Make background non-interactive so taps pass through
    }
    
    // Enhanced star generation for better visibility
    private func generateStars(in size: CGSize) {
        let starColors = [
            Color.white,
            Color(hex: "f7ec59"), // Maize
            Color(hex: "fa7921"), // Pumpkin
            Color(hex: "92dce5")  // Non Photo Blue
        ]
        
        stars = (0..<100).map { _ in
            Star(
                position: CGPoint(
                    x: CGFloat.random(in: 0...(size.width * 3)), // Extended for seamless scrolling
                    y: CGFloat.random(in: 0...size.height)
                ),
                size: CGFloat.random(in: 1.5...4), // Larger stars (was 1...3)
                opacity: Double.random(in: 0.5...1.0), // Brighter stars (was 0.3...1.0)
                twinkleDuration: Double.random(in: 1...3),
                color: starColors.randomElement() ?? Color.white
            )
        }
    }
}