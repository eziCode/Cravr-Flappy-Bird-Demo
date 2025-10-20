//
//  GameView.swift
//  Cravr Flappy Bird Demo
//
//  Created by Ezra Akresh on 10/16/25.
//

import SwiftUI

struct GameView: View {
    @ObservedObject var viewModel: GameViewModel
    
    var body: some View {
        ZStack {
            // Sloth with enhanced styling
            SlothIcon(size: 40)
                .scaleEffect(viewModel.sloth.scale)
                .animation(.easeOut(duration: 0.1), value: viewModel.sloth.scale)
                .position(x: 100, y: viewModel.sloth.y + GameConstants.screenCenter)
            
            // Enhanced Pipes
            ForEach(viewModel.pipes) { pipe in
                PipeView(pipe: pipe)
            }
            
            // Enhanced Score Display (only show when playing)
            if viewModel.gameState == .playing {
                ZStack {
                    // Score background
                    RoundedRectangle(cornerRadius: 15)
                        .frame(width: 200, height: 60)
                        .foregroundColor(.black.opacity(0.6))
                        .blur(radius: 1)
                    
                    Text("Score: \(viewModel.score)")
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundColor(Color(hex: "f7ec59")) // Maize
                        .shadow(color: .black, radius: 2, x: 1, y: 1)
                }
                .position(x: GameConstants.screenWidth / 2, y: 60)
            }
        }
    }
}

import SwiftUI

struct PipeView: View {
    let pipe: Pipe
    
    var body: some View {
        VStack(spacing: 0) {
            // Top pipe
            ZStack(alignment: .top) {
                TreePipeShape()
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color(hex: "#3B6B33"),
                                Color(hex: "#214B25")
                            ]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: GameConstants.pipeWidth, height: pipe.topHeight)
                    .overlay(TreePipeDetails(), alignment: .center)
                    .overlay(LeavesOnPipe(), alignment: .center)
                    .overlay(
                        PipeTopCap()
                            .frame(height: 20)
                            .offset(y: -10)
                        , alignment: .top
                    )
                    .shadow(color: .black.opacity(0.3), radius: 4, x: 2, y: 2)
            }
            
            Spacer().frame(height: GameConstants.pipeSpacing)
            
            // Bottom pipe
            ZStack(alignment: .bottom) {
                TreePipeShape()
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color(hex: "#214B25"),
                                Color(hex: "#3B6B33")
                            ]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: GameConstants.pipeWidth, height: pipe.bottomHeight)
                    .overlay(TreePipeDetails(), alignment: .center)
                    .overlay(LeavesOnPipe(), alignment: .center)
                    .overlay(
                        PipeTopCap()
                            .frame(height: 20)
                            .offset(y: 10)
                        , alignment: .bottom
                    )
                    .shadow(color: .black.opacity(0.3), radius: 4, x: 2, y: -2)
            }
        }
        .position(x: pipe.x, y: GameConstants.screenCenter)
    }
}

struct TreePipeShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path(roundedRect: rect, cornerRadius: rect.width / 4)
        return path
    }
}

struct TreePipeDetails: View {
    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let h = geo.size.height
            
            Path { path in
                // Add subtle bark lines
                path.move(to: CGPoint(x: w * 0.3, y: h * 0.1))
                path.addLine(to: CGPoint(x: w * 0.3, y: h * 0.9))
                
                path.move(to: CGPoint(x: w * 0.7, y: h * 0.2))
                path.addLine(to: CGPoint(x: w * 0.7, y: h * 0.85))
            }
            .stroke(Color.black.opacity(0.25), lineWidth: 2)
            
            // Bark knots
            Circle()
                .stroke(Color.black.opacity(0.25), lineWidth: 1.5)
                .frame(width: w * 0.15, height: w * 0.08)
                .offset(x: w * 0.15, y: h * 0.3)
            
            Circle()
                .stroke(Color.black.opacity(0.25), lineWidth: 1.5)
                .frame(width: w * 0.1, height: w * 0.05)
                .offset(x: w * 0.6, y: h * 0.6)
        }
    }
}

struct PipeTopCap: View {
    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let h = geo.size.height
            
            ZStack {
                Ellipse()
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color(hex: "#82B857"),
                                Color(hex: "#4F7F33")
                            ]),
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .overlay(
                        Ellipse()
                            .stroke(Color.black.opacity(0.3), lineWidth: 2)
                    )
                
                Ellipse()
                    .inset(by: w * 0.15)
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color(hex: "#F3E58B"),
                                Color(hex: "#C7A75C")
                            ]),
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .offset(y: h * 0.05)
            }
        }
    }
}

struct LeavesOnPipe: View {
    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let h = geo.size.height
            
            Group {
                Leaf()
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [Color(hex: "#5FAE3E"), Color(hex: "#3F7B2A")]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: w * 0.2, height: w * 0.1)
                    .rotationEffect(.degrees(-20))
                    .offset(x: -w * 0.55, y: h * 0.3)
                
                Leaf()
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [Color(hex: "#5FAE3E"), Color(hex: "#3F7B2A")]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: w * 0.2, height: w * 0.1)
                    .rotationEffect(.degrees(20))
                    .offset(x: w * 0.55, y: h * 0.6)
            }
        }
    }
}

struct Leaf: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addQuadCurve(to: CGPoint(x: rect.midX, y: rect.maxY),
                          control: CGPoint(x: rect.maxX, y: rect.midY))
        path.addQuadCurve(to: CGPoint(x: rect.midX, y: rect.minY),
                          control: CGPoint(x: rect.minX, y: rect.midY))
        return path
    }
}