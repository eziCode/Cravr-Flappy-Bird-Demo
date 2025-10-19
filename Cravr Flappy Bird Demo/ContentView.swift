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
    @State private var slothY: CGFloat = 0
    @State private var velocity: CGFloat = 0
    @State private var score: Int = 0
    @State private var pipes: [Pipe] = []
    @State private var gameState: GameState = .menu
    @State private var slothScale: CGFloat = 1.0
    @State private var hasPlayedOnce: Bool = false
    @AppStorage("highScore") private var highScore: Int = 0

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
                // Main Menu Screen
                VStack(spacing: 30) {
                    Spacer()
                    
                    // Title Graphic
                    VStack(spacing: 20) {
                        // Game Title
                        Text("FLAPPY SLOTH")
                            .font(.system(size: 36, weight: .bold, design: .rounded))
                            .foregroundColor(Color(hex: "f7ec59")) // Maize
                            .shadow(color: .black, radius: 3, x: 2, y: 2)
                            .multilineTextAlignment(.center)
                        
                        // Sloth Logo
                        ZStack {
                            // Sloth shadow
                            Circle()
                                .frame(width: 80, height: 80)
                                .foregroundColor(.black.opacity(0.3))
                                .offset(x: 6, y: 6)
                            
                            // Main sloth body
                            RoundedRectangle(cornerRadius: 38)
                                .frame(width: 76, height: 90)
                                .foregroundStyle(
                                    LinearGradient(
                                        gradient: Gradient(colors: [
                                            Color(hex: "8B7355"), // Brown - lighter
                                            Color(hex: "6B5B47")  // Darker brown
                                        ]),
                                        startPoint: .top,
                                        endPoint: .bottom
                                    )
                                )
                                .overlay(
                                    // Sloth face mask
                                    RoundedRectangle(cornerRadius: 20)
                                        .frame(width: 50, height: 35)
                                        .foregroundColor(Color(hex: "A68B5B")) // Lighter brown
                                        .offset(y: -15)
                                )
                                .overlay(
                                    // Sloth eye
                                    Circle()
                                        .frame(width: 16, height: 16)
                                        .foregroundColor(.black)
                                        .offset(x: -8, y: -20)
                                )
                                .overlay(
                                    // Sloth nose
                                    Circle()
                                        .frame(width: 8, height: 6)
                                        .foregroundColor(Color(hex: "4A3A2A"))
                                        .offset(x: 5, y: -8)
                                )
                                .overlay(
                                    // Sloth mouth
                                    Capsule()
                                        .frame(width: 12, height: 3)
                                        .foregroundColor(Color(hex: "4A3A2A"))
                                        .offset(x: 2, y: 5)
                                )
                        }
                        .scaleEffect(slothScale)
                        .animation(.easeOut(duration: 0.1), value: slothScale)
                    }
                    
                    // High Score Display
                    VStack(spacing: 10) {
                        Text("HIGH SCORE")
                            .font(.system(size: 18, weight: .semibold, design: .rounded))
                            .foregroundColor(Color(hex: "92dce5")) // Non Photo Blue
                            .shadow(color: .black, radius: 2, x: 1, y: 1)
                        
                        ZStack {
                            // Score background
                            RoundedRectangle(cornerRadius: 12)
                                .frame(width: 120, height: 50)
                                .foregroundColor(.black.opacity(0.6))
                                .blur(radius: 1)
                            
                            Text("\(highScore)")
                                .font(.system(size: 28, weight: .bold, design: .rounded))
                                .foregroundColor(Color(hex: "f7ec59")) // Maize
                                .shadow(color: .black, radius: 2, x: 1, y: 1)
                        }
                    }
                    
                    Spacer()
                    
                    // Menu Buttons
                    VStack(spacing: 20) {
                        // Play Button
                        Button(action: {
                            startGame()
                        }) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 15)
                                    .frame(width: 200, height: 60)
                                    .foregroundColor(Color(hex: "1cd91f")) // SGBus Green
                                    .shadow(color: .black.opacity(0.3), radius: 3, x: 2, y: 2)
                                
                                Text("PLAY")
                                    .font(.system(size: 24, weight: .bold, design: .rounded))
                                    .foregroundColor(.white)
                                    .shadow(color: .black, radius: 2, x: 1, y: 1)
                            }
                        }
                        .scaleEffect(1.0)
                        .animation(.easeOut(duration: 0.1), value: slothScale)
                        
                        // Back Button (TODO)
                        Button(action: {
                            // TODO: Implement back button functionality to dismiss to rest of app
                            print("Back button tapped - TODO: implement dismiss functionality")
                        }) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 12)
                                    .frame(width: 160, height: 50)
                                    .foregroundColor(Color(hex: "fa7921")) // Pumpkin
                                    .shadow(color: .black.opacity(0.3), radius: 2, x: 1, y: 1)
                                
                                Text("BACK")
                                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                                    .foregroundColor(.white)
                                    .shadow(color: .black, radius: 1, x: 1, y: 1)
                            }
                        }
                    }
                    
                    Spacer()
                }
            } else {
                // Game Screen (playing or game over)
                
                // Sloth with enhanced styling
                ZStack {
                    // Sloth shadow
                    Circle()
                        .frame(width: 32, height: 32)
                        .foregroundColor(.black.opacity(0.3))
                        .offset(x: 2, y: 2)
                    
                    // Main sloth body
                    RoundedRectangle(cornerRadius: 15)
                        .frame(width: 30, height: 36)
                        .foregroundStyle(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color(hex: "8B7355"), // Brown - lighter
                                    Color(hex: "6B5B47")  // Darker brown
                                ]),
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .overlay(
                            // Sloth face mask
                            RoundedRectangle(cornerRadius: 8)
                                .frame(width: 20, height: 14)
                                .foregroundColor(Color(hex: "A68B5B")) // Lighter brown
                                .offset(y: -8)
                        )
                        .overlay(
                            // Sloth eye
                            Circle()
                                .frame(width: 6, height: 6)
                                .foregroundColor(.black)
                                .offset(x: -3, y: -8)
                        )
                        .overlay(
                            // Sloth nose
                            Circle()
                                .frame(width: 3, height: 2)
                                .foregroundColor(Color(hex: "4A3A2A"))
                                .offset(x: 2, y: -3)
                        )
                        .overlay(
                            // Sloth mouth
                            Capsule()
                                .frame(width: 5, height: 1)
                                .foregroundColor(Color(hex: "4A3A2A"))
                                .offset(x: 1, y: 2)
                        )
                }
                .scaleEffect(slothScale)
                .animation(.easeOut(duration: 0.1), value: slothScale)
                .position(x: 100, y: slothY + UIScreen.main.bounds.height / 2)
                
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
            
            }
        }
        .contentShape(Rectangle()) // Ensure the entire area is tappable
        .onTapGesture {
            print("Tap detected! gameState: \(gameState)") // Debug print
            if gameState == .playing {
                // Swing during gameplay
                velocity = jump
                
                // Visual feedback - quick scale animation
                withAnimation(.easeOut(duration: 0.1)) {
                    slothScale = 1.2
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    withAnimation(.easeOut(duration: 0.1)) {
                        slothScale = 1.0
                    }
                }
                
                // Add slight haptic feedback if available
                let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                impactFeedback.impactOccurred()
            }
        }
        .onReceive(timer) { _ in
            if gameState == .playing {
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
        slothY = 0
        velocity = 0
        score = 0
        slothScale = 1.0
        pipes = [Pipe(x: UIScreen.main.bounds.width + 100, topHeight: CGFloat.random(in: 120...280))]
        hasPlayedOnce = true
        print("Game started. gameState: \(gameState)") // Debug print
    }
    
    
    func resetGame() {
        print("Resetting to menu...") // Debug print
        
        // Update high score if current score is higher
        if score > highScore {
            highScore = score
        }
        
        gameState = .menu
        slothY = 0
        velocity = 0
        score = 0
        slothScale = 1.0
        pipes = []
        // Don't reset hasPlayedOnce - we want to remember they've played before
        print("Game reset to menu. gameState: \(gameState), highScore: \(highScore)") // Debug print
    }
    
    func updateGame() {
        // Sloth physics
        velocity += gravity
        slothY += velocity
        
        // Pipe movement
        for i in pipes.indices {
            pipes[i].x -= pipeSpeed
            
            // Check for scoring - only when sloth is completely through the pipe gap
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
            let slothFrame = CGRect(x: 100 - 15, y: slothY + UIScreen.main.bounds.height / 2 - 15, width: 30, height: 30)
            let topRect = CGRect(x: pipe.x - pipeWidth/2, y: 0, width: pipeWidth, height: pipe.topHeight)
            let bottomRect = CGRect(x: pipe.x - pipeWidth/2, y: pipe.topHeight + pipeSpacing, width: pipeWidth, height: UIScreen.main.bounds.height - pipe.topHeight - pipeSpacing)
            if slothFrame.intersects(topRect) || slothFrame.intersects(bottomRect) {
                print("Game over - pipe collision! Redirecting to menu...") // Debug print
                resetGame()
                return
            }
        }
        
        // Check ground & ceiling
        if slothY + 15 > UIScreen.main.bounds.height / 2 || slothY - 15 < -UIScreen.main.bounds.height / 2 {
            print("Game over - ground/ceiling collision! slothY: \(slothY). Redirecting to menu...") // Debug print
            resetGame()
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

