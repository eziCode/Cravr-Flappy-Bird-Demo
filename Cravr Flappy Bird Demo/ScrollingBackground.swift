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
}

struct ScrollingBackgroundImage: View {
    @StateObject private var scrollState = ScrollingBackgroundState()
    
    var body: some View {
        GeometryReader { geometry in
            let screenWidth = geometry.size.width
            let screenHeight = geometry.size.height
            
            ZStack {
                // Cloud layers (slowest to fastest, back to front)
                TimelineView(.animation) { timeline in
                    // Distant clouds (slowest)
                    CloudLayer(offset: scrollState.cloudOffset1, speed: 0.002, yPosition: 0.15, cloudCount: 3, scale: 1.2, opacity: 0.5)
                        .onChange(of: timeline.date) { _ in
                            scrollState.cloudOffset1 -= screenWidth * 0.002
                            if scrollState.cloudOffset1 <= -screenWidth * 2.5 {
                                scrollState.cloudOffset1 = 0
                            }
                        }
                    
                    // Mid-distance clouds
                    CloudLayer(offset: scrollState.cloudOffset2, speed: 0.003, yPosition: 0.3, cloudCount: 4, scale: 1.0, opacity: 0.7)
                        .onChange(of: timeline.date) { _ in
                            scrollState.cloudOffset2 -= screenWidth * 0.003
                            if scrollState.cloudOffset2 <= -screenWidth * 2.5 {
                                scrollState.cloudOffset2 = 0
                            }
                        }
                    
                    // Near clouds (fastest)
                    CloudLayer(offset: scrollState.cloudOffset3, speed: 0.004, yPosition: 0.45, cloudCount: 3, scale: 0.8, opacity: 0.9)
                        .onChange(of: timeline.date) { _ in
                            scrollState.cloudOffset3 -= screenWidth * 0.004
                            if scrollState.cloudOffset3 <= -screenWidth * 2.5 {
                                scrollState.cloudOffset3 = 0
                            }
                        }
                }
                
                // Ground background
                TimelineView(.animation) { timeline in
                    HStack(spacing: 0) {
                        Image("flappy_sloth_background")
                            .resizable()
                            .frame(width: screenWidth * 1.15, height: screenHeight * 0.5)
                        
                        Image("flappy_sloth_background")
                            .resizable()
                            .frame(width: screenWidth * 1.15, height: screenHeight * 0.5)
                    }
                    .offset(x: scrollState.offset)
                    .onChange(of: timeline.date) { _ in
                        // Scroll left at a smooth pace
                        let scrollSpeed = screenWidth * 0.005
                        scrollState.offset -= scrollSpeed
                        
                        // Reset offset when the first image is completely off-screen
                        if scrollState.offset <= -(screenWidth * 1.15) {
                            scrollState.offset = 0
                        }
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
            }
        }
        .ignoresSafeArea(edges: .bottom)
        .allowsHitTesting(false) // Make background non-interactive so taps pass through
    }
}

// MARK: - Cloud Layer
struct CloudLayer: View {
    let offset: CGFloat
    let speed: CGFloat
    let yPosition: CGFloat
    let cloudCount: Int
    let scale: CGFloat
    let opacity: Double
    
    var body: some View {
        GeometryReader { geometry in
            let screenWidth = geometry.size.width
            let screenHeight = geometry.size.height
            let spacing = screenWidth * 2.5 / CGFloat(cloudCount)
            
            HStack(spacing: 0) {
                // First set of clouds
                ForEach(0..<cloudCount, id: \.self) { index in
                    CloudShape()
                        .fill(Color.white.opacity(opacity))
                        .frame(width: screenWidth * 0.25 * scale, height: screenWidth * 0.15 * scale)
                        .offset(x: CGFloat(index) * spacing)
                }
                
                // Duplicate set for seamless looping
                ForEach(0..<cloudCount, id: \.self) { index in
                    CloudShape()
                        .fill(Color.white.opacity(opacity))
                        .frame(width: screenWidth * 0.25 * scale, height: screenWidth * 0.15 * scale)
                        .offset(x: CGFloat(index) * spacing)
                }
            }
            .offset(x: offset)
            .position(x: screenWidth * 1.25, y: screenHeight * yPosition)
        }
    }
}

// MARK: - Cloud Shape
struct CloudShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        // Create a cloud using circles
        let centerX = rect.midX
        let centerY = rect.midY
        let width = rect.width
        let height = rect.height
        
        // Main body (large center circle)
        path.addEllipse(in: CGRect(
            x: centerX - width * 0.25,
            y: centerY - height * 0.2,
            width: width * 0.5,
            height: height * 0.6
        ))
        
        // Left bump
        path.addEllipse(in: CGRect(
            x: centerX - width * 0.45,
            y: centerY - height * 0.1,
            width: width * 0.35,
            height: height * 0.5
        ))
        
        // Right bump
        path.addEllipse(in: CGRect(
            x: centerX + width * 0.1,
            y: centerY - height * 0.15,
            width: width * 0.4,
            height: height * 0.55
        ))
        
        // Top bump
        path.addEllipse(in: CGRect(
            x: centerX - width * 0.15,
            y: centerY - height * 0.3,
            width: width * 0.35,
            height: height * 0.45
        ))
        
        return path
    }
}
