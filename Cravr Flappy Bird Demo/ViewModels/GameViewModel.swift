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
        let slothSize: CGFloat = GameConstants.screenWidth * 0.15 // 15% of screen width (matches visual)
        let slothScale = sloth.scale
        
        // These match the TriangleCutRectangle sizes
        let triangleSize: CGFloat = GameConstants.screenWidth * 0.1   // 10% of screen width for right corners
        let triangleSize2: CGFloat = GameConstants.screenWidth * 0.05  // 5% of screen width for left corners

        for pipe in pipes {
            // === TOP PIPE ===
            let topPipeX = pipe.x - GameConstants.screenWidth * 0.04875
            let topPipeY = pipe.topHeight / 2 - GameConstants.screenHeight * 0.1875
            let topPipeWidth = GameConstants.pipeWidth
            let topPipeHeight = pipe.topHeight + GameConstants.screenHeight * 0.375

            // Check if sloth polygonal hitbox intersects with top pipe
            if checkSlothPolygonCollisionWithPipe(
                slothX: slothX, 
                slothY: slothY, 
                slothSize: slothSize, 
                slothScale: slothScale,
                pipeX: topPipeX, 
                pipeY: topPipeY, 
                pipeWidth: topPipeWidth, 
                pipeHeight: topPipeHeight,
                triangleSize: triangleSize,
                triangleSize2: triangleSize2,
                isTopPipe: true
            ) {
                return true
            }

            // === BOTTOM PIPE ===
            let bottomPipeX = pipe.x - GameConstants.screenWidth * 0.04875
            let bottomPipeY = GameConstants.screenHeight - (pipe.bottomHeight / 2) + GameConstants.screenHeight * 0.1875
            let bottomPipeWidth = GameConstants.pipeWidth
            let bottomPipeHeight = pipe.bottomHeight + GameConstants.screenHeight * 0.375

            // Check if sloth polygonal hitbox intersects with bottom pipe
            if checkSlothPolygonCollisionWithPipe(
                slothX: slothX, 
                slothY: slothY, 
                slothSize: slothSize, 
                slothScale: slothScale,
                pipeX: bottomPipeX, 
                pipeY: bottomPipeY, 
                pipeWidth: bottomPipeWidth, 
                pipeHeight: bottomPipeHeight,
                triangleSize: triangleSize,
                triangleSize2: triangleSize2,
                isTopPipe: false
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
        pipeHeight: CGFloat,
        triangleSize: CGFloat,
        triangleSize2: CGFloat,
        isTopPipe: Bool
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
        
        // Check if any sloth polygon vertices are inside the pipe (with cutouts)
        for point in slothPolygon {
            if isPointInPipeWithCutouts(
                point: point,
                pipeX: pipeX,
                pipeY: pipeY,
                pipeWidth: pipeWidth,
                pipeHeight: pipeHeight,
                triangleSize: triangleSize,
                triangleSize2: triangleSize2,
                isTopPipe: isTopPipe
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
        
        // Use the exact same polygon points as SlothHitbox struct
        return [
            // Start Point (Face/Neck) - Tighter to the body
            CGPoint(x: rect.minX + rect.width * 0.35, y: rect.minY + rect.height * 0.32),
            
            // 1. Top Outline (Back/Shoulder)
            // Upper Head/Back Curve (highest point)
            CGPoint(x: rect.minX + rect.width * 0.5, y: rect.minY + rect.height * 0.25),
            
            // Shoulder/Upper Arm Curve - Dropped slightly to fix overlap
            CGPoint(x: rect.minX + rect.width * 0.7, y: rect.minY + rect.height * 0.33),
            
            // 2. Front Arm/Hand (Far Right - CAPTURING FINGERS)
            // Hand tip (Upper edge of claw - further out)
            CGPoint(x: rect.maxX - rect.width * 0.03, y: rect.minY + rect.height * 0.4),
            
            // Lowest part of the fingers/claw
            CGPoint(x: rect.maxX - rect.width * 0.05, y: rect.minY + rect.height * 0.6),
            
            // 3. Bottom Outline (Lower Arm/Belly/Leg)
            // Underside of arm (Tweak from previous step)
            CGPoint(x: rect.maxX - rect.width * 0.3, y: rect.minY + rect.height * 0.6),
            
            // Belly curve (Kept tight)
            CGPoint(x: rect.minX + rect.width * 0.6, y: rect.maxY - rect.height * 0.2),
            
            // Back Leg (Lowest point, kept high)
            CGPoint(x: rect.minX + rect.width * 0.3, y: rect.maxY - rect.height * 0.15),
            
            // 4. Back Leg/Foot (Far Left)
            // Back foot tip 
            CGPoint(x: rect.minX + rect.width * 0.05, y: rect.minY + rect.height * 0.75),
            
            // Upper back leg/Connect to start
            CGPoint(x: rect.minX + rect.width * 0.15, y: rect.minY + rect.height * 0.55)
        ]
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
    
    private func isPointInPipeWithCutouts(
        point: CGPoint,
        pipeX: CGFloat,
        pipeY: CGFloat,
        pipeWidth: CGFloat,
        pipeHeight: CGFloat,
        triangleSize: CGFloat,
        triangleSize2: CGFloat,
        isTopPipe: Bool
    ) -> Bool {
        // Convert point to local coordinates of the pipe
        let localX = point.x - (pipeX - pipeWidth / 2)
        let localY = point.y - (pipeY - pipeHeight / 2)
        
        // Check if point is within pipe bounds
        if localX < 0 || localX > pipeWidth || localY < 0 || localY > pipeHeight {
            return false
        }
        
        if isTopPipe {
            // Define cutout triangles (bottomLeft & bottomRight)
            let inBottomRightCutout =
                (localX > pipeWidth - triangleSize) &&
                (localY > pipeHeight - triangleSize) &&
                ((localX - (pipeWidth - triangleSize)) + (localY - (pipeHeight - triangleSize)) > triangleSize)

            let inBottomLeftCutout =
                (localX < triangleSize2) &&
                (localY > pipeHeight - triangleSize2) &&
                (((triangleSize2 - localX) + (localY - (pipeHeight - triangleSize2))) > triangleSize2)

            // Return true if point is in pipe but not in cutouts
            return !(inBottomRightCutout || inBottomLeftCutout)
        } else {
            // Define topRight & topLeft cutouts
            let inTopRightCutout =
                (localX > pipeWidth - triangleSize) &&
                (localY < triangleSize) &&
                ((localX - (pipeWidth - triangleSize)) + (triangleSize - localY) > triangleSize)

            let inTopLeftCutout =
                (localX < triangleSize2) &&
                (localY < triangleSize2) &&
                (((triangleSize2 - localX) + (triangleSize2 - localY)) > triangleSize2)

            // Return true if point is in pipe but not in cutouts
            return !(inTopRightCutout || inTopLeftCutout)
        }
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
