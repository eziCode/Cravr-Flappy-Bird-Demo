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
    
    var body: some View {
        GeometryReader { geometry in
            let screenWidth = geometry.size.width
            let screenHeight = geometry.size.height
            
            TimelineView(.animation) { timeline in
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
                .onChange(of: timeline.date) { _ in
                    // Scroll left at a smooth pace
                    let scrollSpeed = screenWidth * 0.005
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
