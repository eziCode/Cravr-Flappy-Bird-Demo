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
    static let pipeWidth: CGFloat = 80
    static let pipeSpacing: CGFloat = 180
    static let pipeCapHeight: CGFloat = 20.0   // matches PipeTopCap().frame(height: 20)
    static let basePipeSpeed: CGFloat = 4
    static let gameTimerInterval: Double = 0.016 // ~60 FPS
    
    // Scoring thresholds
    static let speedIncreaseThreshold = 10
    static let difficultyIncreaseThreshold = 10
    static let maxDifficultyLevel = 4
    
    // Pipe generation
    static let easyPipeHeightRange: ClosedRange<CGFloat> = 120...280
    static let pipeGenerationDistance: CGFloat = 200
    static let pipeRemovalThreshold: CGFloat = -50
    
    // Screen bounds
    static var screenHeight: CGFloat { UIScreen.main.bounds.height }
    static var screenWidth: CGFloat { UIScreen.main.bounds.width }
    static var screenCenter: CGFloat { screenHeight / 2 }
}
