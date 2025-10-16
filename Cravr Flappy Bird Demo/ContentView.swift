//
//  ContentView.swift
//  Cravr Flappy Bird Demo
//
//  Created by Ezra Akresh on 10/16/25.
//

import SwiftUI
import Combine

struct ContentView: View {
    @State private var birdY: CGFloat = 0
    @State private var velocity: CGFloat = 0
    @State private var score: Int = 0
    @State private var pipes: [Pipe] = []
    @State private var gameOver = false
    
    let gravity: CGFloat = 0.6
    let jump: CGFloat = -12
    let pipeWidth: CGFloat = 50
    let pipeSpacing: CGFloat = 150
    let pipeSpeed: CGFloat = 5
    let timer = Timer.publish(every: 0.02, on: .main, in: .common).autoconnect()
    
    var body: some View {
        ZStack {
            Color.blue.ignoresSafeArea()
            
            // Bird
            Circle()
                .frame(width: 30, height: 30)
                .foregroundColor(.yellow)
                .position(x: 100, y: birdY + UIScreen.main.bounds.height / 2)
            
            // Pipes
            ForEach(pipes) { pipe in
                VStack {
                    Rectangle()
                        .frame(width: pipeWidth, height: pipe.topHeight)
                        .foregroundColor(.green)
                    Spacer().frame(height: pipeSpacing)
                    Rectangle()
                        .frame(width: pipeWidth, height: pipe.bottomHeight)
                        .foregroundColor(.green)
                }
                .position(x: pipe.x, y: UIScreen.main.bounds.height / 2)
            }
            
            // Score
            Text("Score: \(score)")
                .font(.largeTitle)
                .foregroundColor(.white)
                .position(x: UIScreen.main.bounds.width / 2, y: 50)
            
            if gameOver {
                Text("Game Over")
                    .font(.largeTitle)
                    .foregroundColor(.red)
            }
        }
        .onTapGesture {
            if !gameOver {
                velocity = jump
            } else {
                resetGame()
            }
        }
        .onReceive(timer) { _ in
            if !gameOver {
                updateGame()
            }
        }
        .onAppear {
            resetGame()
        }
    }
    
    func resetGame() {
        birdY = 0
        velocity = 0
        score = 0
        pipes = [Pipe(x: UIScreen.main.bounds.width + 100, topHeight: CGFloat.random(in: 100...300))]
        gameOver = false
    }
    
    func updateGame() {
        // Bird physics
        velocity += gravity
        birdY += velocity
        
        // Pipe movement
        for i in pipes.indices {
            pipes[i].x -= pipeSpeed
            
            // Check for scoring
            if pipes[i].x + pipeWidth/2 < 100 && !pipes[i].passed {
                score += 1
                pipes[i].passed = true
            }
        }
        
        // Remove offscreen pipes
        pipes.removeAll { $0.x < -pipeWidth }
        
        // Add new pipe if needed
        if pipes.last?.x ?? 0 < UIScreen.main.bounds.width - 200 {
            let topHeight = CGFloat.random(in: 100...300)
            pipes.append(Pipe(x: UIScreen.main.bounds.width + pipeWidth, topHeight: topHeight))
        }
        
        // Check collisions
        for pipe in pipes {
            let birdFrame = CGRect(x: 100 - 15, y: birdY + UIScreen.main.bounds.height / 2 - 15, width: 30, height: 30)
            let topRect = CGRect(x: pipe.x - pipeWidth/2, y: 0, width: pipeWidth, height: pipe.topHeight)
            let bottomRect = CGRect(x: pipe.x - pipeWidth/2, y: pipe.topHeight + pipeSpacing, width: pipeWidth, height: UIScreen.main.bounds.height - pipe.topHeight - pipeSpacing)
            if birdFrame.intersects(topRect) || birdFrame.intersects(bottomRect) {
                gameOver = true
            }
        }
        
        // Check ground & ceiling
        if birdY + 15 > UIScreen.main.bounds.height / 2 || birdY - 15 < -UIScreen.main.bounds.height / 2 {
            gameOver = true
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

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
