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
        print("Starting game...")
        gameState = .playing
        sloth.reset()
        score = 0
        pipes = [Pipe(x: GameConstants.screenWidth + 100, topHeight: CGFloat.random(in: GameConstants.easyPipeHeightRange))]
        hasPlayedOnce = true
        startGameTimer()
        print("Game started. gameState: \(gameState)")
    }
    
    func resetGame() {
        print("Resetting to menu...")
        
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
        print("Game reset to menu. gameState: \(gameState), highScore: \(highScore)")
    }
    
    func handleTap() {
        print("Tap detected! gameState: \(gameState)")
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
            if lastPipe.x < GameConstants.screenWidth - 200 {
                let topHeight = CGFloat.random(in: GameConstants.easyPipeHeightRange)
                pipes.append(Pipe(x: GameConstants.screenWidth + GameConstants.pipeWidth, topHeight: topHeight))
            }
        }
    }
    
    private func checkCollisions() -> Bool {
        let slothX: CGFloat = 100
        let slothY: CGFloat = sloth.y + GameConstants.screenCenter
        let slothRadius: CGFloat = 20

        // These match the TriangleCutRectangle sizes
        let triangleSize: CGFloat = 40   // For right corners
        let triangleSize2: CGFloat = 20  // For left corners

        for pipe in pipes {
            // === TOP PIPE ===
            let topPipeX = pipe.x - 19.5
            let topPipeY = pipe.topHeight / 2 - 150
            let topPipeWidth = GameConstants.pipeWidth
            let topPipeHeight = pipe.topHeight + 300

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
                    print("💥 Game over - TOP pipe collision! (matches new bounding shape)")
                    return true
                }
            }

            // === BOTTOM PIPE ===
            let bottomPipeX = pipe.x - 19.5
            let bottomPipeY = UIScreen.main.bounds.height - (pipe.bottomHeight / 2) + 150
            let bottomPipeWidth = GameConstants.pipeWidth
            let bottomPipeHeight = pipe.bottomHeight + 300

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
                    print("💥 Game over - BOTTOM pipe collision! (matches new bounding shape)")
                    return true
                }
            }
        }

        return false
    }


    
    private func checkScoreIncrement() {
        let slothX: CGFloat = 100 // Sloth X position
        
        for i in 0..<pipes.count {
            // Check if sloth has passed through this pipe
            if !pipes[i].passed && pipes[i].x + GameConstants.pipeWidth < slothX {
                pipes[i].passed = true
                score += 1
                print("Score incremented! New score: \(score)")
            }
        }
    }
    
    private func checkBoundaryCollisions() -> Bool {
        if sloth.y + 15 > GameConstants.screenCenter || sloth.y - 15 < -GameConstants.screenCenter {
            print("Game over - boundary collision! slothY: \(sloth.y)")
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
