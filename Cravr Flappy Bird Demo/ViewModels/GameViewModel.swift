//
//  GameViewModel.swift
//  Cravr Flappy Bird Demo
//
//  Created by Ezra Akresh on 10/16/25.
//

import SwiftUI
import Combine
import UIKit

@MainActor
class GameViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var gameState: GameState = .menu
    @Published var sloth: Sloth = Sloth()
    @Published var pipes: [Pipe] = []
    @Published var score: Int = 0
    @Published var hasPlayedOnce: Bool = false
    @Published var highScore: Int = 0
    
    // MARK: - Private Properties
    private var timer: Timer?
    private let soundManager = SoundManager.shared
    private let haptics = Haptics.shared
    
    // MARK: - Computed Properties
    var pipeSpeed: CGFloat {
        if score <= GameConstants.speedIncreaseThreshold {
            return GameConstants.basePipeSpeed
        } else {
            let speedIncrease = CGFloat((score - GameConstants.speedIncreaseThreshold) / 5) * 0.1
            return GameConstants.basePipeSpeed + speedIncrease
        }
    }
    
    // MARK: - Initialization
    init() {
        loadHighScore()
    }
    
    // MARK: - Game Control
    func startGame() {
        gameState = .playing
        sloth.reset()
        score = 0
        pipes = [Pipe(x: GameConstants.screenWidth + GameConstants.screenWidth * 0.25, topHeight: CGFloat.random(in: GameConstants.easyPipeHeightRange))]
        hasPlayedOnce = true
        startGameTimer()
    }
    
    func resetGame() {
        
        // Update high score if current score is higher
        if score > highScore {
            highScore = score
            saveHighScore()
        }
        
        stopGameTimer()
        gameState = .menu
        sloth.reset()
        score = 0
        pipes = []
    }
    
    func handleTap() {
        if gameState == .playing {
            sloth.jump(with: GameConstants.jump)
            animateSlothScale()
            haptics.impact(.light)
        }
    }
    
    // MARK: - Game Logic
    private func startGameTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: GameConstants.gameTimerInterval, repeats: true) { _ in
            Task { @MainActor in
                self.updateGame()
            }
        }
    }
    
    private func stopGameTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    private func updateGame() {
        guard gameState == .playing else { return }
        
        // Update sloth physics
        sloth.applyGravity(GameConstants.gravity)
        
        // Update pipes
        updatePipes()
        
        // Check collisions
        if checkCollisions() {
            resetGame()
            return
        }
        
        // Check ground & ceiling
        if checkBoundaryCollisions() {
            resetGame()
            return
        }
        
        // Check for score increments
        checkScoreIncrement()
    }
    
    private func updatePipes() {
        // TODO: implement
        for i in 0..<pipes.count {
            pipes[i].x -= pipeSpeed
        }

        pipes.removeAll { $0.x + GameConstants.pipeWidth < 0 }

        if let lastPipe = pipes.last {
            if lastPipe.x < GameConstants.screenWidth - GameConstants.screenWidth * 0.5 {
                let topHeight = CGFloat.random(in: GameConstants.easyPipeHeightRange)
                pipes.append(Pipe(x: GameConstants.screenWidth + GameConstants.pipeWidth, topHeight: topHeight))
            }
        }
    }
    
    private func checkCollisions() -> Bool {
        let slothX: CGFloat = GameConstants.screenWidth * 0.25 // 25% from left
        let slothY: CGFloat = sloth.y + GameConstants.screenCenter
        let slothRadius: CGFloat = GameConstants.screenWidth * 0.05 // 5% of screen width

        // These match the TriangleCutRectangle sizes
        let triangleSize: CGFloat = GameConstants.screenWidth * 0.1   // 10% of screen width for right corners
        let triangleSize2: CGFloat = GameConstants.screenWidth * 0.05  // 5% of screen width for left corners

        for pipe in pipes {
            // === TOP PIPE ===
            let topPipeX = pipe.x - GameConstants.screenWidth * 0.04875
            let topPipeY = pipe.topHeight / 2 - GameConstants.screenHeight * 0.1875
            let topPipeWidth = GameConstants.pipeWidth
            let topPipeHeight = pipe.topHeight + GameConstants.screenHeight * 0.375

            // Fast bounding-box rejection
            if abs(slothX - topPipeX) < (slothRadius + topPipeWidth / 2),
            abs(slothY - topPipeY) < (slothRadius + topPipeHeight / 2) {

                // Convert sloth position to local coords of the top pipe
                let localX = slothX - (topPipeX - topPipeWidth / 2)
                let localY = slothY - (topPipeY - topPipeHeight / 2)

                // Define cutout triangles (bottomLeft & bottomRight)
                let inBottomRightCutout =
                    (localX > topPipeWidth - triangleSize) &&
                    (localY > topPipeHeight - triangleSize) &&
                    ((localX - (topPipeWidth - triangleSize)) + (localY - (topPipeHeight - triangleSize)) > triangleSize)

                let inBottomLeftCutout =
                    (localX < triangleSize2) &&
                    (localY > topPipeHeight - triangleSize2) &&
                    (((triangleSize2 - localX) + (localY - (topPipeHeight - triangleSize2))) > triangleSize2)

                // Collide if not inside either cutout
                if !(inBottomRightCutout || inBottomLeftCutout) {
                    return true
                }
            }

            // === BOTTOM PIPE ===
            let bottomPipeX = pipe.x - GameConstants.screenWidth * 0.04875
            let bottomPipeY = GameConstants.screenHeight - (pipe.bottomHeight / 2) + GameConstants.screenHeight * 0.1875
            let bottomPipeWidth = GameConstants.pipeWidth
            let bottomPipeHeight = pipe.bottomHeight + GameConstants.screenHeight * 0.375

            if abs(slothX - bottomPipeX) < (slothRadius + bottomPipeWidth / 2),
            abs(slothY - bottomPipeY) < (slothRadius + bottomPipeHeight / 2) {

                let localX = slothX - (bottomPipeX - bottomPipeWidth / 2)
                let localY = slothY - (bottomPipeY - bottomPipeHeight / 2)

                // Define topRight & topLeft cutouts
                let inTopRightCutout =
                    (localX > bottomPipeWidth - triangleSize) &&
                    (localY < triangleSize) &&
                    ((localX - (bottomPipeWidth - triangleSize)) + (triangleSize - localY) > triangleSize)

                let inTopLeftCutout =
                    (localX < triangleSize2) &&
                    (localY < triangleSize2) &&
                    (((triangleSize2 - localX) + (triangleSize2 - localY)) > triangleSize2)

                if !(inTopRightCutout || inTopLeftCutout) {
                    return true
                }
            }
        }

        return false
    }


    
    private func checkScoreIncrement() {
        let slothX: CGFloat = GameConstants.screenWidth * 0.25 // Sloth X position - 25% from left
        
        for i in 0..<pipes.count {
            // Check if sloth has passed through this pipe
            if !pipes[i].passed && pipes[i].x + GameConstants.pipeWidth < slothX {
                pipes[i].passed = true
                score += 1
            }
        }
    }
    
    private func checkBoundaryCollisions() -> Bool {
        let boundaryMargin = GameConstants.screenHeight * 0.0375 // 3.75% of screen height
        if sloth.y + boundaryMargin > GameConstants.screenCenter || sloth.y - boundaryMargin < -GameConstants.screenCenter {
            return true
        }
        return false
    }
    
    // MARK: - Visual Effects
    private func animateSlothScale() {
        withAnimation(.easeOut(duration: 0.1)) {
            sloth.scale = 1.2
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            withAnimation(.easeOut(duration: 0.1)) {
                self.sloth.scale = 1.0
            }
        }
    }
    
    // MARK: - Audio
    private func playScoringSound() {
        if score % 10 == 0 && score > 0 {
            soundManager.playChime()
        } else {
            soundManager.playDing()
        }
    }
    
    // MARK: - Persistence
    private func loadHighScore() {
        highScore = UserDefaults.standard.integer(forKey: "highScore")
    }
    
    private func saveHighScore() {
        UserDefaults.standard.set(highScore, forKey: "highScore")
    }
    
    // MARK: - Cleanup
    deinit {
        // Timer will be automatically invalidated when the view model is deallocated
        // No need for explicit cleanup since timer is weak-referenced
    }
}
