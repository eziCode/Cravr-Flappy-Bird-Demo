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
        pipes = [Pipe(x: GameConstants.screenWidth + 100, topHeight: CGFloat.random(in: GameConstants.easyPipeHeightRange))]
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
    }
    
    private func updatePipes() {
        // Move pipes
        for i in pipes.indices {
            pipes[i].x -= pipeSpeed
            
            // Check for scoring
            if pipes[i].x + GameConstants.pipeWidth/2 < 100 - 15 && !pipes[i].passed {
                score += 1
                pipes[i].passed = true
                playScoringSound()
                haptics.impact(.light)
            }
        }
        
        // Remove offscreen pipes
        pipes.removeAll { $0.x < GameConstants.pipeRemovalThreshold }
        
        // Add new pipe if needed
        if pipes.last?.x ?? 0 < GameConstants.screenWidth - GameConstants.pipeGenerationDistance {
            let topHeight = generatePipeHeight()
            pipes.append(Pipe(x: GameConstants.screenWidth + GameConstants.pipeWidth, topHeight: topHeight))
        }
    }
    
    private func generatePipeHeight() -> CGFloat {
        if score < GameConstants.difficultyIncreaseThreshold {
            return CGFloat.random(in: GameConstants.easyPipeHeightRange)
        } else {
            let difficulty = min((score - GameConstants.difficultyIncreaseThreshold) / 5, GameConstants.maxDifficultyLevel)
            let minHeight = 100 + CGFloat(difficulty) * 20
            let maxHeight = 300 - CGFloat(difficulty) * 20
            return CGFloat.random(in: minHeight...maxHeight)
        }
    }
    
    private func checkCollisions() -> Bool {
        // Sample density (more samples => more accurate; 9x9 = 81 checks)
        let sampleGrid = 9

        for pipe in pipes {
            // Body rects (same as before)
            let topRect = CGRect(
                x: pipe.x - GameConstants.pipeWidth / 2,
                y: 0,
                width: GameConstants.pipeWidth,
                height: pipe.topHeight
            )
            let bottomRect = CGRect(
                x: pipe.x - GameConstants.pipeWidth / 2,
                y: pipe.topHeight + GameConstants.pipeSpacing,
                width: GameConstants.pipeWidth,
                height: GameConstants.screenHeight - pipe.topHeight - GameConstants.pipeSpacing
            )

            // Build precise CGPaths for the top and bottom pipe (rounded rect + cap ellipse for top only)
            let topPath = makePipeCGPath(forRect: topRect, capPosition: .top)
            let bottomPath = makePipeCGPath(forRect: bottomRect, capPosition: .none)

            // Quick bounding-box reject
            let slothBox = sloth.frame

            if !slothBox.intersects(topPath.boundingBox) && !slothBox.intersects(bottomPath.boundingBox) {
                // no possible intersection for this pipe, continue
                continue
            }

            // Sample points in sloth rect (dense grid) and test for containment in either path.
            if rectIntersectsPath(rect: slothBox, path: topPath, samplesPerSide: sampleGrid) {
                return true
            }
            if rectIntersectsPath(rect: slothBox, path: bottomPath, samplesPerSide: sampleGrid) {
                return true
            }

            // Additional: also test if any point from the pipe path's bounding box overlaps sloth rect (to catch thin overlap cases).
            // Sample some points along the path bounding box as well.
            if rectIntersectsPath(rect: topPath.boundingBox, path: makeRectCGPath(from: slothBox), samplesPerSide: sampleGrid) {
                return true
            }
            if rectIntersectsPath(rect: bottomPath.boundingBox, path: makeRectCGPath(from: slothBox), samplesPerSide: sampleGrid) {
                return true
            }
        }
        return false
    }
    
    private func checkBoundaryCollisions() -> Bool {
        if sloth.y + 15 > GameConstants.screenCenter || sloth.y - 15 < -GameConstants.screenCenter {
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
    
    // MARK: - Precise collision helpers

    private enum CapPosition {
        case top
        case bottom
        case none
    }

    /// Create a CGPath consisting of a rounded rect (corner radius = width / 4, same as TreePipeShape)
    /// plus the ellipse cap positioned at the top or bottom. Coordinates are in the same coordinate system
    /// as your on-screen layout (same as pipe.x / heights).
    private func makePipeCGPath(forRect rect: CGRect, capPosition: CapPosition) -> CGPath {
        let path = CGMutablePath()

        // Rounded rect (cornerRadius same as TreePipeShape)
        let cornerRadius = rect.width / 4.0
        let roundedRectPath = UIBezierPath(roundedRect: rect, cornerRadius: cornerRadius)
        path.addPath(roundedRectPath.cgPath)

        // Cap ellipse: width == rect.width, height == GameConstants.pipeCapHeight
        let capH = GameConstants.pipeCapHeight
        let capRect: CGRect
        switch capPosition {
        case .top:
            // The PipeTopCap() in the pipe view was .frame(height: 20) and offset(y: -10) for top.
            // So the ellipse center sits above the topRect by capH/2 (offset -capH/2).
            capRect = CGRect(x: rect.minX, y: rect.minY - capH, width: rect.width, height: capH)
            let capPath = UIBezierPath(ovalIn: capRect)
            path.addPath(capPath.cgPath)
        case .bottom:
            // For bottom cap overlay offset there was .offset(y: 10) (so bubble sits below the bottom rect)
            capRect = CGRect(x: rect.minX, y: rect.maxY, width: rect.width, height: capH)
            let capPath = UIBezierPath(ovalIn: capRect)
            path.addPath(capPath.cgPath)
        case .none:
            // No cap - just the rounded rectangle
            break
        }

        return path
    }

    /// Build a rectangle CGPath (useful if you want to test path vs rect)
    private func makeRectCGPath(from rect: CGRect) -> CGPath {
        let p = CGMutablePath()
        p.addRect(rect)
        return p
    }

    /// Return true if any sample point inside `rect` is contained in `path`.
    /// We sample a grid across the rect to catch intersections even if edges just graze.
    private func rectIntersectsPath(rect: CGRect, path: CGPath, samplesPerSide: Int) -> Bool {
        if samplesPerSide <= 0 { return false }

        // Quick reject using bounding boxes
        if !rect.intersects(path.boundingBox) {
            return false
        }

        // Sample a grid of points inside rect (inclusive of edges)
        for row in 0..<samplesPerSide {
            for col in 0..<samplesPerSide {
                let fx = CGFloat(col) / CGFloat(max(1, samplesPerSide - 1)) // 0..1
                let fy = CGFloat(row) / CGFloat(max(1, samplesPerSide - 1)) // 0..1
                let px = rect.minX + fx * rect.width
                let py = rect.minY + fy * rect.height
                if path.contains(CGPoint(x: px, y: py)) {
                    return true
                }
            }
        }

        // Also sample the perimeter points (helps catch thin touches)
        let perimeterSamples = max(12, samplesPerSide * 4)
        for i in 0..<perimeterSamples {
            let t = CGFloat(i) / CGFloat(perimeterSamples)
            // walk rectangle perimeter: top, right, bottom, left
            var point = CGPoint.zero
            let segment = Int(t * 4.0)
            let localT = (t * 4.0) - CGFloat(segment)
            switch segment {
            case 0: // top
                point = CGPoint(x: rect.minX + localT * rect.width, y: rect.minY)
            case 1: // right
                point = CGPoint(x: rect.maxX, y: rect.minY + localT * rect.height)
            case 2: // bottom
                point = CGPoint(x: rect.maxX - localT * rect.width, y: rect.maxY)
            default: // left
                point = CGPoint(x: rect.minX, y: rect.maxY - localT * rect.height)
            }
            if path.contains(point) { return true }
        }

        return false
    }

    // MARK: - Cleanup
    deinit {
        // Timer will be automatically invalidated when the view model is deallocated
        // No need for explicit cleanup since timer is weak-referenced
    }
}
