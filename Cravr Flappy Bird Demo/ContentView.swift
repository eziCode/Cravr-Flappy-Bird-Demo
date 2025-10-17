//
//  ContentView.swift
//  Cravr Flappy Bird Demo
//
//  Created by Ezra Akresh on 10/16/25.
//

import SwiftUI
import Combine
import UIKit

enum GameState {
    case menu
    case playing
    case gameOver
}

struct ContentView: View {
    @State private var birdY: CGFloat = 0
    @State private var velocity: CGFloat = 0
    @State private var score: Int = 0
    @State private var pipes: [Pipe] = []
    @State private var gameState: GameState = .menu
    @State private var birdScale: CGFloat = 1.0
    @State private var hasPlayedOnce: Bool = false
    @State private var justLost: Bool = false
    
    let gravity: CGFloat = 0.55
    let jump: CGFloat = -9
    let pipeWidth: CGFloat = 50
    let pipeSpacing: CGFloat = 180
    let basePipeSpeed: CGFloat = 4
    let timer = Timer.publish(every: 0.016, on: .main, in: .common).autoconnect() // ~60 FPS for smoother gameplay
    
    // Dynamic pipe speed that increases after score 10
    var pipeSpeed: CGFloat {
        if score <= 10 {
            return basePipeSpeed
        } else {
            // Gradually increase speed by 0.1 every 5 points after score 10
            let speedIncrease = CGFloat((score - 10) / 5) * 0.1
            return basePipeSpeed + speedIncrease
        }
    }
    
    var body: some View {
        ZStack {
            // Star background
            StarBackground()
                .ignoresSafeArea()
            
            if gameState == .menu {
                // Welcome Menu Screen
                VStack(spacing: 40) {
                    Spacer()
                    
                    // Welcome message
                    Text("Welcome!")
                        .font(.system(size: 48, weight: .bold, design: .rounded))
                        .foregroundColor(Color(hex: "f7ec59")) // Maize
                        .shadow(color: .black, radius: 3, x: 2, y: 2)
                    
                    // Bird in menu
                    ZStack {
                        // Bird shadow
                        Circle()
                            .frame(width: 64, height: 64)
                            .foregroundColor(.black.opacity(0.3))
                            .offset(x: 4, y: 4)
                        
                        // Main bird body
                        Circle()
                            .frame(width: 60, height: 60)
                            .foregroundStyle(
                                RadialGradient(
                                    gradient: Gradient(colors: [
                                        Color(hex: "f7ec59"), // Maize - lighter center
                                        Color(hex: "fa7921")  // Pumpkin - darker edges
                                    ]),
                                    center: .topLeading,
                                    startRadius: 10,
                                    endRadius: 40
                                )
                            )
                            .overlay(
                                // Bird eye
                                Circle()
                                    .frame(width: 16, height: 16)
                                    .foregroundColor(.black)
                                    .offset(x: -10, y: -10)
                            )
                            .overlay(
                                // Bird beak
                                Triangle()
                                    .frame(width: 12, height: 8)
                                    .foregroundColor(Color(hex: "fa7921"))
                                    .offset(x: 24, y: 0)
                            )
                    }
                    .scaleEffect(birdScale)
                    .animation(.easeOut(duration: 0.1), value: birdScale)
                    
                    Text("Tap to Start Playing!")
                        .font(.system(size: 24, weight: .medium, design: .rounded))
                        .foregroundColor(Color(hex: "92dce5")) // Non Photo Blue
                        .shadow(color: .black, radius: 2, x: 1, y: 1)
                    
                    Spacer()
                }
            } else {
                // Game Screen (playing or game over)
                
                // Bird with enhanced styling
                ZStack {
                    // Bird shadow
                    Circle()
                        .frame(width: 32, height: 32)
                        .foregroundColor(.black.opacity(0.3))
                        .offset(x: 2, y: 2)
                    
                    // Main bird body
                    Circle()
                        .frame(width: 30, height: 30)
                        .foregroundStyle(
                            RadialGradient(
                                gradient: Gradient(colors: [
                                    Color(hex: "f7ec59"), // Maize - lighter center
                                    Color(hex: "fa7921")  // Pumpkin - darker edges
                                ]),
                                center: .topLeading,
                                startRadius: 5,
                                endRadius: 20
                            )
                        )
                        .overlay(
                            // Bird eye
                            Circle()
                                .frame(width: 8, height: 8)
                                .foregroundColor(.black)
                                .offset(x: -5, y: -5)
                        )
                        .overlay(
                            // Bird beak
                            Triangle()
                                .frame(width: 6, height: 4)
                                .foregroundColor(Color(hex: "fa7921"))
                                .offset(x: 12, y: 0)
                        )
                }
                .scaleEffect(birdScale)
                .animation(.easeOut(duration: 0.1), value: birdScale)
                .position(x: 100, y: birdY + UIScreen.main.bounds.height / 2)
                
                // Enhanced Pipes
                ForEach(pipes) { pipe in
                    VStack(spacing: 0) {
                        // Top pipe
                        ZStack {
                            Rectangle()
                                .frame(width: pipeWidth + 4, height: pipe.topHeight + 4)
                                .foregroundColor(.black.opacity(0.3))
                                .offset(x: 2, y: 2)
                            
                            Rectangle()
                                .frame(width: pipeWidth, height: pipe.topHeight)
                                .foregroundStyle(
                                    LinearGradient(
                                        gradient: Gradient(colors: [
                                            Color(hex: "1cd91f"), // SGBus Green
                                            Color(hex: "0d4f0d")  // Darker green for depth
                                        ]),
                                        startPoint: .top,
                                        endPoint: .bottom
                                    )
                                )
                                .overlay(
                                    Rectangle()
                                        .frame(width: pipeWidth - 8, height: 8)
                                        .foregroundColor(Color(hex: "92dce5")) // Non Photo Blue accent
                                        .offset(y: pipe.topHeight/2 - 4)
                                )
                        }
                        
                        Spacer().frame(height: pipeSpacing)
                        
                        // Bottom pipe
                        ZStack {
                            Rectangle()
                                .frame(width: pipeWidth + 4, height: pipe.bottomHeight + 4)
                                .foregroundColor(.black.opacity(0.3))
                                .offset(x: 2, y: -2)
                            
                            Rectangle()
                                .frame(width: pipeWidth, height: pipe.bottomHeight)
                                .foregroundStyle(
                                    LinearGradient(
                                        gradient: Gradient(colors: [
                                            Color(hex: "0d4f0d"), // Darker green for depth
                                            Color(hex: "1cd91f")  // SGBus Green
                                        ]),
                                        startPoint: .top,
                                        endPoint: .bottom
                                    )
                                )
                                .overlay(
                                    Rectangle()
                                        .frame(width: pipeWidth - 8, height: 8)
                                        .foregroundColor(Color(hex: "92dce5")) // Non Photo Blue accent
                                        .offset(y: -pipe.bottomHeight/2 + 4)
                                )
                        }
                    }
                    .position(x: pipe.x, y: UIScreen.main.bounds.height / 2)
                }
                
                // Enhanced Score Display (only show when playing)
                if gameState == .playing {
                    ZStack {
                        // Score background
                        RoundedRectangle(cornerRadius: 15)
                            .frame(width: 200, height: 60)
                            .foregroundColor(.black.opacity(0.6))
                            .blur(radius: 1)
                        
                        Text("Score: \(score)")
                            .font(.system(size: 24, weight: .bold, design: .rounded))
                            .foregroundColor(Color(hex: "f7ec59")) // Maize
                            .shadow(color: .black, radius: 2, x: 1, y: 1)
                    }
                    .position(x: UIScreen.main.bounds.width / 2, y: 60)
                }
            
                // Play Again Overlay (shows when user has just lost and we're showing the game screen)
                if gameState == .playing && justLost {
                    ZStack {
                        // Semi-transparent background
                        Rectangle()
                            .fill(.black.opacity(0.6))
                            .ignoresSafeArea()
                        
                        VStack(spacing: 20) {
                            Text("Play Again")
                                .font(.system(size: 36, weight: .bold, design: .rounded))
                                .foregroundColor(Color(hex: "f7ec59")) // Maize
                                .shadow(color: .black, radius: 3, x: 2, y: 2)
                            
                            Text("Tap to Start!")
                                .font(.system(size: 18, weight: .medium, design: .rounded))
                                .foregroundColor(Color(hex: "92dce5")) // Non Photo Blue
                                .shadow(color: .black, radius: 2, x: 1, y: 1)
                        }
                    }
                }
            }
        }
        .contentShape(Rectangle()) // Ensure the entire area is tappable
        .onTapGesture {
            print("Tap detected! gameState: \(gameState)") // Debug print
            if gameState == .menu {
                // Start the game
                startGame()
            } else if gameState == .playing {
                // Check if we're in the play again overlay
                if justLost {
                    // Start the game (remove the overlay)
                    startGameplay()
                } else {
                    // Jump during gameplay
                    velocity = jump
                    
                    // Visual feedback - quick scale animation
                    withAnimation(.easeOut(duration: 0.1)) {
                        birdScale = 1.2
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        withAnimation(.easeOut(duration: 0.1)) {
                            birdScale = 1.0
                        }
                    }
                    
                    // Add slight haptic feedback if available
                    let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                    impactFeedback.impactOccurred()
                }
            }
            // No action needed for gameOver state - it will automatically redirect to menu
        }
        .onReceive(timer) { _ in
            if gameState == .playing && !justLost {
                updateGame()
            }
        }
        .onAppear {
            // Game starts in menu state
        }
    }
    
    func startGame() {
        print("Starting game...") // Debug print
        gameState = .playing
        birdY = 0
        velocity = 0
        score = 0
        birdScale = 1.0
        pipes = [Pipe(x: UIScreen.main.bounds.width + 100, topHeight: CGFloat.random(in: 120...280))]
        hasPlayedOnce = true
        print("Game started. gameState: \(gameState)") // Debug print
    }
    
    func resetGameForPlayAgain() {
        print("Resetting game for play again...") // Debug print
        justLost = true
        birdY = 0
        velocity = 0
        score = 0
        birdScale = 1.0
        pipes = [Pipe(x: UIScreen.main.bounds.width + 100, topHeight: CGFloat.random(in: 120...280))]
        print("Game reset for play again. justLost: \(justLost)") // Debug print
    }
    
    func startGameplay() {
        print("Starting gameplay (removing overlay)...") // Debug print
        // This function is called when user taps during play again overlay
        justLost = false
        // The game is already in playing state, just need to start the timer
        // No additional setup needed since the game is already initialized
    }
    
    func resetGame() {
        print("Resetting to menu...") // Debug print
        gameState = .menu
        birdY = 0
        velocity = 0
        score = 0
        birdScale = 1.0
        pipes = []
        justLost = false
        // Don't reset hasPlayedOnce - we want to remember they've played before
        print("Game reset to menu. gameState: \(gameState)") // Debug print
    }
    
    func updateGame() {
        // Bird physics
        velocity += gravity
        birdY += velocity
        
        // Pipe movement
        for i in pipes.indices {
            pipes[i].x -= pipeSpeed
            
            // Check for scoring - only when bird is completely through the pipe gap
            if pipes[i].x + pipeWidth/2 < 100 - 15 && !pipes[i].passed {
                score += 1
                pipes[i].passed = true
                
                // Play scoring sound effect
                playScoringSound()
                
                // Light haptic feedback for passing through pole
                let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                impactFeedback.impactOccurred()
            }
        }
        
        // Remove offscreen pipes
        pipes.removeAll { $0.x < -pipeWidth }
        
        // Add new pipe if needed
        if pipes.last?.x ?? 0 < UIScreen.main.bounds.width - 200 {
            // Make first 10 pipes easier with more consistent gaps
            let topHeight: CGFloat
            if score < 10 {
                // Easier range for first 10 pipes (more consistent, wider gaps)
                topHeight = CGFloat.random(in: 120...280)
            } else {
                // Gradually increase difficulty after score 10
                let difficulty = min((score - 10) / 5, 4) // Increase difficulty every 5 points, max at score 30
                let minHeight = 100 + CGFloat(difficulty) * 20
                let maxHeight = 300 - CGFloat(difficulty) * 20
                topHeight = CGFloat.random(in: minHeight...maxHeight)
            }
            pipes.append(Pipe(x: UIScreen.main.bounds.width + pipeWidth, topHeight: topHeight))
        }
        
        // Check collisions
        for pipe in pipes {
            let birdFrame = CGRect(x: 100 - 15, y: birdY + UIScreen.main.bounds.height / 2 - 15, width: 30, height: 30)
            let topRect = CGRect(x: pipe.x - pipeWidth/2, y: 0, width: pipeWidth, height: pipe.topHeight)
            let bottomRect = CGRect(x: pipe.x - pipeWidth/2, y: pipe.topHeight + pipeSpacing, width: pipeWidth, height: UIScreen.main.bounds.height - pipe.topHeight - pipeSpacing)
            if birdFrame.intersects(topRect) || birdFrame.intersects(bottomRect) {
                print("Game over - pipe collision! Showing play again screen...") // Debug print
                resetGameForPlayAgain()
                return
            }
        }
        
        // Check ground & ceiling
        if birdY + 15 > UIScreen.main.bounds.height / 2 || birdY - 15 < -UIScreen.main.bounds.height / 2 {
            print("Game over - ground/ceiling collision! birdY: \(birdY). Showing play again screen...") // Debug print
            resetGameForPlayAgain()
            return
        }
    }
    
    // MARK: - Audio and Haptic Feedback
    
    private func playScoringSound() {
        if score % 10 == 0 && score > 0 {
            // Special sound for every 10 points
            SoundManager.shared.playChime()
        } else {
            // Regular scoring sound
            SoundManager.shared.playDing()
        }
    }
}

struct Pipe: Identifiable {
    let id = UUID()
    var x: CGFloat
    var topHeight: CGFloat
    var bottomHeight: CGFloat {
        UIScreen.main.bounds.height - topHeight - 150
    }
    var passed = false
}

// MARK: - Extensions and Helper Views

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.midX, y: rect.minY))
        return path
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
