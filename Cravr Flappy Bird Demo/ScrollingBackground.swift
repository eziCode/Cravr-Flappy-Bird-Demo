//
//  ScrollingBackground.swift
//  Cravr Flappy Bird Demo
//
//  Created by Ezra Akresh on 10/28/25.
//

import SwiftUI
import Combine

struct ScrollingBackgroundImage: View {
    @State private var offset: CGFloat = 0
    
    let timer = Timer.publish(every: 0.016, on: .main, in: .common).autoconnect() // ~60fps
    
    var body: some View {
        GeometryReader { geometry in
            let screenWidth = geometry.size.width
            let screenHeight = geometry.size.height
            // Match pipe speed: basePipeSpeed = screenWidth * 0.015 per frame
            // At 60fps: screenWidth * 0.015 / 0.016 = screenWidth * 0.9375 per second
            
            VStack(spacing: 0) {
                // Spacer() // Push content to bottom
                
                // We'll use two copies of the image side-by-side for seamless looping
                HStack(spacing: 0) {
                    Image("flappy_sloth_background")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: screenWidth)
                    
                    Image("flappy_sloth_background")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: screenWidth)
                }
                .offset(x: offset)
                .onReceive(timer) { _ in
                    // Scroll left at a smooth pace
                    let scrollSpeed = screenWidth * 0.005 // Match pipe speed
                    offset -= scrollSpeed
                    
                    // Reset offset when the first image is completely off-screen
                    if offset <= -screenWidth {
                        offset = 0
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
        }
        .ignoresSafeArea(edges: .bottom)
        .allowsHitTesting(false) // Make background non-interactive so taps pass through
    }
}
