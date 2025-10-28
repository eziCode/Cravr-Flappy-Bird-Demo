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
}

struct ScrollingBackgroundImage: View {
    @StateObject private var scrollState = ScrollingBackgroundState()
    
    var body: some View {
        GeometryReader { geometry in
            let screenWidth = geometry.size.width
            let screenHeight = geometry.size.height
            
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
        .ignoresSafeArea(edges: .bottom)
        .allowsHitTesting(false) // Make background non-interactive so taps pass through
    }
}
