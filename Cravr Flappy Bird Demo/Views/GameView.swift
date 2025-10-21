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

struct PipeView: View {
    let pipe: Pipe
    
    var body: some View {
        ZStack {
            // Top pipe - extended beyond screen
            ZStack {
                Image("tree-trunk-pipe-image")
                    .resizable()
                    .frame(width: GameConstants.pipeWidth, height: pipe.topHeight + 300) // Consistent width, variable height
                    .scaleEffect(x: 1, y: -1) // Only reflection, no width scaling
                    .position(x: pipe.x - 19.5, y: pipe.topHeight / 2 - 150) // Match collision detection positioning
                
                Rectangle()
                    .fill(Color.red.opacity(0.3))
                    .frame(width: GameConstants.pipeWidth, height: pipe.topHeight + 300) // Consistent width, variable height
                    .clipShape(TriangleCutRectangle(cutCorners: [.bottomLeft, .bottomRight], triangleSize: 40, triangleSize2: 20))
                    .position(x: pipe.x - 19.5, y: pipe.topHeight / 2 - 150) // Match collision detection positioning
            }
            
            // Bottom pipe - extended beyond screen
            ZStack {
                Image("tree-trunk-pipe-image")
                    .resizable()
                    .scaledToFill()
                    .frame(width: GameConstants.pipeWidth, height: pipe.bottomHeight + 300) // Consistent width, variable height
                    .scaleEffect(x: 0.6, y: 1) // No scaling
                    .position(x: pipe.x - 19.5, y: UIScreen.main.bounds.height - (pipe.bottomHeight / 2) + 150) // Match collision detection positioning
                
                Rectangle()
                    .fill(Color.red.opacity(0.3))
                    .frame(width: GameConstants.pipeWidth, height: pipe.bottomHeight + 300) // Consistent width, variable height
                    .clipShape(TriangleCutRectangle(cutCorners: [.topRight, .topLeft], triangleSize: 40, triangleSize2: 20))
                    .position(x: pipe.x - 19.5, y: UIScreen.main.bounds.height - (pipe.bottomHeight / 2) + 150) // Match collision detection positioning
            }
        }
    }
}

struct TriangleCutRectangle: Shape {
    let cutCorners: [UIRectCorner]
    let triangleSize: CGFloat
    let triangleSize2: CGFloat
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        // Start with the full rectangle
        path.addRect(rect)
        
        // Cut out triangles from specified corners
        for corner in cutCorners {
            let trianglePath = createTrianglePath(in: rect, corner: corner, size: triangleSize, size2: triangleSize2)
            path = path.subtracting(trianglePath)
        }
        
        return path
    }
    
    private func createTrianglePath(in rect: CGRect, corner: UIRectCorner, size: CGFloat, size2: CGFloat) -> Path {
        var trianglePath = Path()
        
        switch corner {
        case .topRight:
            // Triangle pointing down and left from top-right corner
            let topRight = CGPoint(x: rect.maxX, y: rect.minY)
            let trianglePoint1 = CGPoint(x: rect.maxX - size, y: rect.minY)
            let trianglePoint2 = CGPoint(x: rect.maxX, y: rect.minY + size)
            trianglePath.move(to: topRight)
            trianglePath.addLine(to: trianglePoint1)
            trianglePath.addLine(to: trianglePoint2)
            trianglePath.closeSubpath()
            
        case .bottomRight:
            // Triangle pointing up and left from bottom-right corner
            let bottomRight = CGPoint(x: rect.maxX, y: rect.maxY)
            let trianglePoint1 = CGPoint(x: rect.maxX - size, y: rect.maxY)
            let trianglePoint2 = CGPoint(x: rect.maxX, y: rect.maxY - size)
            trianglePath.move(to: bottomRight)
            trianglePath.addLine(to: trianglePoint1)
            trianglePath.addLine(to: trianglePoint2)
            trianglePath.closeSubpath()
            
        case .topLeft:
            // Triangle pointing down and right from top-left corner
            let topLeft = CGPoint(x: rect.minX, y: rect.minY)
            let trianglePoint1 = CGPoint(x: rect.minX + size2, y: rect.minY)
            let trianglePoint2 = CGPoint(x: rect.minX, y: rect.minY + size2)
            trianglePath.move(to: topLeft)
            trianglePath.addLine(to: trianglePoint1)
            trianglePath.addLine(to: trianglePoint2)
            trianglePath.closeSubpath()
            
        case .bottomLeft:
            // Triangle pointing up and right from bottom-left corner
            let bottomLeft = CGPoint(x: rect.minX, y: rect.maxY)
            let trianglePoint1 = CGPoint(x: rect.minX + size2, y: rect.maxY)
            let trianglePoint2 = CGPoint(x: rect.minX, y: rect.maxY - size2)
            trianglePath.move(to: bottomLeft)
            trianglePath.addLine(to: trianglePoint1)
            trianglePath.addLine(to: trianglePoint2)
            trianglePath.closeSubpath()
            
        default:
            break
        }
        
        return trianglePath
    }
}
