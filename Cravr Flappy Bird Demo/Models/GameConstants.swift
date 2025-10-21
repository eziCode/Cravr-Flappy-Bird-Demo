//
//  GameConstants.swift
//  Cravr Flappy Bird Demo
//
//  Created by Ezra Akresh on 10/16/25.
//

import Foundation
import UIKit

struct GameConstants {
    static let gravity: CGFloat = 0.55
    static let jump: CGFloat = -9
    
    // Relative to screen width
    static var pipeWidth: CGFloat { screenWidth * 0.2 } // 20% of screen width
    static var pipeSpacing: CGFloat { screenWidth * 0.45 } // 45% of screen width
    static var pipeCapHeight: CGFloat { screenWidth * 0.05 } // 5% of screen width
    static var basePipeSpeed: CGFloat { screenWidth * 0.01 } // 1% of screen width per frame
    static let gameTimerInterval: Double = 0.016 // ~60 FPS
    
    // Scoring thresholds
    static let speedIncreaseThreshold = 10
    static let difficultyIncreaseThreshold = 10
    static let maxDifficultyLevel = 4
    
    // Pipe generation - relative to screen dimensions
    static var easyPipeHeightRange: ClosedRange<CGFloat> { 
        let minHeight = screenHeight * 0.15 // 15% of screen height
        let maxHeight = screenHeight * 0.35 // 35% of screen height
        return minHeight...maxHeight
    }
    static var pipeGenerationDistance: CGFloat { screenWidth * 0.5 } // 50% of screen width
    static var pipeRemovalThreshold: CGFloat { -screenWidth * 0.125 } // -12.5% of screen width
    
    // Screen bounds
    static var screenHeight: CGFloat { UIScreen.main.bounds.height }
    static var screenWidth: CGFloat { UIScreen.main.bounds.width }
    static var screenCenter: CGFloat { screenHeight / 2 }
}
