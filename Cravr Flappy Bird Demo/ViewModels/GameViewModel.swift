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
    private var displayLink: CADisplayLink?
    private let soundManager = SoundManager.shared
    private let haptics = Haptics.shared
    private var lastUpdateTime: TimeInterval?
    
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
        lastUpdateTime = CACurrentMediaTime()
    }
    
    // MARK: - Game Control
    func startGame() {
        // Prevent multiple calls to startGame
        guard gameState != .playing else {
            return
        }
        
        gameState = .playing
        sloth.reset()
        score = 0
        
        // Generate first pipe with new structure
        let gapHeight = GameConstants.gapHeight(for: score)
        let verticalOffset = CGFloat.random(in: -GameConstants.screenHeight * 0.2...GameConstants.screenHeight * 0.2)
        pipes = [Pipe(x: GameConstants.screenWidth + GameConstants.screenWidth * 0.25, gapHeight: gapHeight, verticalOffset: verticalOffset)]
        
        hasPlayedOnce = true
        lastUpdateTime = CACurrentMediaTime() // ✅ important
        
        // ✅ Small delay ensures SwiftUI body updates and avoids glitch
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
            self.startGameTimer()
        }
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
        if gameState == .menu {
            startGame()
            return
        }
        
        guard gameState == .playing else {
            return
        }
        
        sloth.jump(with: GameConstants.jump)
        animateSlothScale()
        haptics.impact(.light)
    }
    
    // MARK: - Game Logic
    private func startGameTimer() {
        stopGameTimer()
        displayLink = CADisplayLink(target: self, selector: #selector(gameLoop))
        displayLink?.add(to: .main, forMode: .common)
    }
    
    @objc private func gameLoop() {
        updateGame()
    }
    
    private func stopGameTimer() {
        displayLink?.invalidate()
        displayLink = nil
    }
    
    private func updateGame() {
        guard gameState == .playing else { return }

        let currentTime = CACurrentMediaTime()
        let deltaTime: CGFloat
        if let lastTime = lastUpdateTime {
            deltaTime = CGFloat(currentTime - lastTime)
        } else {
            deltaTime = 1 / 60 // Assume 60 FPS on first frame
        }
        lastUpdateTime = currentTime
        
        // Cap delta time to prevent large jumps and ensure consistent physics
        let clampedDeltaTime = min(max(deltaTime, 0.008), 0.033) // Between 30-120 FPS equivalent

        // Apply gravity scaled by delta time
        sloth.applyGravity(GameConstants.gravity, deltaTime: clampedDeltaTime)
        sloth.updateRotation()

        updatePipes()
        
        if checkCollisions() {
            resetGame()
            return
        }
        
        if checkBoundaryCollisions() {
            resetGame()
            return
        }
        
        checkScoreIncrement()
    }
    
    private func updatePipes() {
        guard !pipes.isEmpty else { return } // ✅ prevents accidental early call
        
        for i in 0..<pipes.count {
            pipes[i].x -= pipeSpeed
        }

        pipes.removeAll { $0.x + GameConstants.pipeWidth < 0 }

        // Generate new pipes - check if we need to add one
        if let lastPipe = pipes.last,
           lastPipe.x < GameConstants.screenWidth - GameConstants.screenWidth * 0.5 {
            let gapHeight = GameConstants.gapHeight(for: score)
            let verticalOffset = CGFloat.random(in: -GameConstants.screenHeight * 0.2...GameConstants.screenHeight * 0.2)
            pipes.append(Pipe(x: GameConstants.screenWidth + GameConstants.pipeWidth, gapHeight: gapHeight, verticalOffset: verticalOffset))
        }
    }
    
    private func checkCollisions() -> Bool {
        let slothX: CGFloat = GameConstants.screenWidth * 0.25 // 25% from left
        let slothY: CGFloat = sloth.y + GameConstants.screenCenter
        let slothSize: CGFloat = GameConstants.screenWidth * 0.15 // 15% of screen width (matches visual)
        let slothScale = sloth.scale

        for pipe in pipes {
            // Calculate pipe positions based on VStack structure
            let totalVStackHeight = 2 * GameConstants.pipeExtendedHeight + pipe.gapHeight
            let vStackCenterY = GameConstants.screenHeight / 2 + pipe.verticalOffset
            let vStackTop = vStackCenterY - totalVStackHeight / 2
            
            // Top pipe bounds
            let topPipeX = pipe.x
            let topPipeY = vStackTop + GameConstants.pipeExtendedHeight / 2
            let topPipeWidth = GameConstants.pipeWidth
            let topPipeHeight = GameConstants.pipeExtendedHeight
            
            // Bottom pipe bounds
            let bottomPipeX = pipe.x
            let bottomPipeY = vStackTop + GameConstants.pipeExtendedHeight + pipe.gapHeight + GameConstants.pipeExtendedHeight / 2
            let bottomPipeWidth = GameConstants.pipeWidth
            let bottomPipeHeight = GameConstants.pipeExtendedHeight

            // Check collision with top pipe
            if checkSlothPolygonCollisionWithPipe(
                slothX: slothX, 
                slothY: slothY, 
                slothSize: slothSize, 
                slothScale: slothScale,
                pipeX: topPipeX, 
                pipeY: topPipeY, 
                pipeWidth: topPipeWidth, 
                pipeHeight: topPipeHeight
            ) {
                return true
            }

            // Check collision with bottom pipe
            if checkSlothPolygonCollisionWithPipe(
                slothX: slothX, 
                slothY: slothY, 
                slothSize: slothSize, 
                slothScale: slothScale,
                pipeX: bottomPipeX, 
                pipeY: bottomPipeY, 
                pipeWidth: bottomPipeWidth, 
                pipeHeight: bottomPipeHeight
            ) {
                return true
            }
        }

        return false
    }
    
    // MARK: - Polygon Collision Detection
    private func checkSlothPolygonCollisionWithPipe(
        slothX: CGFloat, 
        slothY: CGFloat, 
        slothSize: CGFloat, 
        slothScale: CGFloat,
        pipeX: CGFloat, 
        pipeY: CGFloat, 
        pipeWidth: CGFloat, 
        pipeHeight: CGFloat
    ) -> Bool {
        // Get the sloth polygon points (exact same as SlothHitbox struct)
        let slothPolygon = getSlothPolygonPoints(
            centerX: slothX, 
            centerY: slothY, 
            size: slothSize, 
            scale: slothScale
        )
        
        // Fast bounding box check first
        let slothBounds = getPolygonBounds(polygon: slothPolygon)
        let pipeBounds = CGRect(
            x: pipeX - pipeWidth / 2,
            y: pipeY - pipeHeight / 2,
            width: pipeWidth,
            height: pipeHeight
        )
        
        if !slothBounds.intersects(pipeBounds) {
            return false
        }
        
        // Check if any sloth polygon vertices are inside the pipe (simple rectangle)
        for point in slothPolygon {
            if isPointInRectangle(
                point: point,
                rectX: pipeX,
                rectY: pipeY,
                rectWidth: pipeWidth,
                rectHeight: pipeHeight
            ) {
                return true
            }
        }
        
        // Check if any pipe corners are inside the sloth polygon
        let pipeCorners = [
            CGPoint(x: pipeX - pipeWidth / 2, y: pipeY - pipeHeight / 2), // top-left
            CGPoint(x: pipeX + pipeWidth / 2, y: pipeY - pipeHeight / 2), // top-right
            CGPoint(x: pipeX - pipeWidth / 2, y: pipeY + pipeHeight / 2), // bottom-left
            CGPoint(x: pipeX + pipeWidth / 2, y: pipeY + pipeHeight / 2)  // bottom-right
        ]
        
        for corner in pipeCorners {
            if isPointInPolygon(point: corner, polygon: slothPolygon) {
                return true
            }
        }
        
        return false
    }
    
    private func getSlothPolygonPoints(centerX: CGFloat, centerY: CGFloat, size: CGFloat, scale: CGFloat) -> [CGPoint] {
        let scaledSize = size * scale
        let halfSize = scaledSize / 2
        
        // Create a rect centered at the sloth position
        let rect = CGRect(
            x: centerX - halfSize,
            y: centerY - halfSize,
            width: scaledSize,
            height: scaledSize
        )
        
        // Get the base polygon points (same as SlothHitbox struct)
        let basePoints = [
            // Start Point (Face/Neck) - Tighter to the body
            CGPoint(x: rect.minX + rect.width * 0.35, y: rect.minY + rect.height * 0.32),
            
            // 1. Top Outline (Back/Shoulder)
            // Upper Head/Back Curve (highest point)
            CGPoint(x: rect.minX + rect.width * 0.5, y: rect.minY + rect.height * 0.25),
            
            // Shoulder/Upper Arm Curve - Dropped slightly to fix overlap
            CGPoint(x: rect.minX + rect.width * 0.7, y: rect.minY + rect.height * 0.33),
            
            // 2. Front Arm/Hand (Far Right - CAPTURING FINGERS)
            // Hand tip (Upper edge of claw - further out)
            CGPoint(x: rect.maxX - rect.width * 0.03, y: rect.minY + rect.height * 0.5),
            
            // Lowest part of the fingers/claw
            CGPoint(x: rect.maxX - rect.width * 0.05, y: rect.minY + rect.height * 0.6),
            
            // 3. Bottom Outline (Lower Arm/Belly/Leg)
            // Underside of arm (Tweak from previous step)
            CGPoint(x: rect.maxX - rect.width * 0.3, y: rect.minY + rect.height * 0.6),
            
            // Belly curve (Kept tight)
            CGPoint(x: rect.minX + rect.width * 0.6, y: rect.maxY - rect.height * 0.4),
            
            // Back Leg (Lowest point, kept high)
            CGPoint(x: rect.minX + rect.width * 0.3, y: rect.maxY - rect.height * 0.15),
            
            // 4. Back Leg/Foot (Far Left)
            // Back foot tip 
            CGPoint(x: rect.minX + rect.width * 0.05, y: rect.minY + rect.height * 0.75),
            
            // Upper back leg/Connect to start
            CGPoint(x: rect.minX + rect.width * 0.15, y: rect.minY + rect.height * 0.55)
        ]
        
        // Apply rotation if needed
        if sloth.rotation != 0 {
            return rotatePolygonPoints(basePoints, around: CGPoint(x: centerX, y: centerY), by: sloth.rotation)
        }
        
        return basePoints
    }
    
    private func rotatePolygonPoints(_ points: [CGPoint], around center: CGPoint, by degrees: Double) -> [CGPoint] {
        let radians = degrees * .pi / 180.0
        let cos = cos(radians)
        let sin = sin(radians)
        
        return points.map { point in
            // Translate to origin
            let translatedX = point.x - center.x
            let translatedY = point.y - center.y
            
            // Apply rotation
            let rotatedX = translatedX * cos - translatedY * sin
            let rotatedY = translatedX * sin + translatedY * cos
            
            // Translate back
            return CGPoint(x: rotatedX + center.x, y: rotatedY + center.y)
        }
    }
    
    private func getPolygonBounds(polygon: [CGPoint]) -> CGRect {
        guard !polygon.isEmpty else { return CGRect.zero }
        
        let minX = polygon.map { $0.x }.min() ?? 0
        let maxX = polygon.map { $0.x }.max() ?? 0
        let minY = polygon.map { $0.y }.min() ?? 0
        let maxY = polygon.map { $0.y }.max() ?? 0
        
        return CGRect(x: minX, y: minY, width: maxX - minX, height: maxY - minY)
    }
    
    private func isPointInPolygon(point: CGPoint, polygon: [CGPoint]) -> Bool {
        guard polygon.count >= 3 else { return false }
        
        var inside = false
        var j = polygon.count - 1
        
        for i in 0..<polygon.count {
            let pi = polygon[i]
            let pj = polygon[j]
            
            if ((pi.y > point.y) != (pj.y > point.y)) &&
               (point.x < (pj.x - pi.x) * (point.y - pi.y) / (pj.y - pi.y) + pi.x) {
                inside = !inside
            }
            j = i
        }
        
        return inside
    }
    
    private func isPointInRectangle(
        point: CGPoint,
        rectX: CGFloat,
        rectY: CGFloat,
        rectWidth: CGFloat,
        rectHeight: CGFloat
    ) -> Bool {
        let left = rectX - rectWidth / 2
        let right = rectX + rectWidth / 2
        let top = rectY - rectHeight / 2
        let bottom = rectY + rectHeight / 2
        
        return point.x >= left && point.x <= right && point.y >= top && point.y <= bottom
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
        // Check if sloth hits top or bottom of screen
        // sloth.y is relative to screen center, so we check against screen bounds
        let slothScreenY = sloth.y + GameConstants.screenCenter
        if slothScreenY + boundaryMargin > GameConstants.screenHeight || slothScreenY - boundaryMargin < 0 {
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
        displayLink?.invalidate()
        displayLink = nil
    }
}
