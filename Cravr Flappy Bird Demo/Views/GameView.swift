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
            Image("sloth-image")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: GameConstants.screenWidth * 0.15, height: GameConstants.screenWidth * 0.15) // 15% of screen width
                .scaleEffect(viewModel.sloth.scale)
                .rotationEffect(.degrees(viewModel.sloth.rotation))
                .animation(.easeOut(duration: 0.1), value: viewModel.sloth.scale)
                .animation(.easeOut(duration: 0.2), value: viewModel.sloth.rotation)
                .position(x: GameConstants.screenWidth * 0.25, y: viewModel.sloth.y + GameConstants.screenCenter) // 25% from left
            
            // DEBUG: Polygonal Sloth Hitbox (UPDATED)
            // SlothHitbox()
            //     .stroke(Color.red, lineWidth: 2)
            //     .frame(width: GameConstants.screenWidth * 0.15, height: GameConstants.screenWidth * 0.15)
            //     .scaleEffect(viewModel.sloth.scale)
            //     .rotationEffect(.degrees(viewModel.sloth.rotation))
            //     .animation(.easeOut(duration: 0.1), value: viewModel.sloth.scale)
            //     .animation(.easeOut(duration: 0.2), value: viewModel.sloth.rotation)
            //     .position(x: GameConstants.screenWidth * 0.25, y: viewModel.sloth.y + GameConstants.screenCenter)
            //     .opacity(0.7)
            
            // Enhanced Pipes
            ForEach(viewModel.pipes) { pipe in
                PipeView(pipe: pipe)
            }
            
            // Enhanced Score Display (only show when playing)
            if viewModel.gameState == .playing {
                ZStack {
                    // Score background
                    RoundedRectangle(cornerRadius: GameConstants.screenWidth * 0.0375) // 3.75% of screen width
                        .frame(width: GameConstants.screenWidth * 0.5, height: GameConstants.screenHeight * 0.08) // 50% width, 8% height
                        .foregroundColor(.black.opacity(0.6))
                        .blur(radius: 1)
                    
                    Text("Score: \(viewModel.score)")
                        .font(.system(size: GameConstants.screenWidth * 0.06, weight: .bold, design: .rounded)) // 6% of screen width
                        .foregroundColor(Color(hex: "f7ec59")) // Maize
                        .shadow(color: .black, radius: 2, x: 1, y: 1)
                }
                .position(x: GameConstants.screenWidth / 2, y: GameConstants.screenHeight * 0.08) // 8% from top
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
                    .frame(width: GameConstants.pipeWidth, height: pipe.topHeight + GameConstants.screenHeight * 0.375) // Consistent width, variable height
                    .scaleEffect(x: 1, y: -1) // Only reflection, no width scaling
                    .position(x: pipe.x - GameConstants.screenWidth * 0.04875, y: pipe.topHeight / 2 - GameConstants.screenHeight * 0.1875) // Match collision detection positioning
                
                // Rectangle()
                //     .fill(Color.red.opacity(0.3))
                //     .frame(width: GameConstants.pipeWidth, height: pipe.topHeight + 300) // Consistent width, variable height
                //     .clipShape(TriangleCutRectangle(cutCorners: [.bottomLeft, .bottomRight], triangleSize: 40, triangleSize2: 20))
                //     // .position(x: pipe.x - 19.5, y: pipe.topHeight / 2 - 150) // Match collision detection positioning
            }
            
            // Bottom pipe - extended beyond screen
            ZStack {
                Image("tree-trunk-pipe-image")
                    .resizable()
                    .scaledToFill()
                    .frame(width: GameConstants.pipeWidth, height: pipe.bottomHeight + GameConstants.screenHeight * 0.375) // Consistent width, variable height
                    .scaleEffect(x: 0.6, y: 1) // No scaling
                    .position(x: pipe.x - GameConstants.screenWidth * 0.04875, y: GameConstants.screenHeight - (pipe.bottomHeight / 2) + GameConstants.screenHeight * 0.1875) // Match collision detection positioning
                
                // Rectangle()
                //     .fill(Color.red.opacity(0.3))
                //     .frame(width: GameConstants.pipeWidth, height: pipe.bottomHeight + 300) // Consistent width, variable height
                //     .clipShape(TriangleCutRectangle(cutCorners: [.topRight, .topLeft], triangleSize: 40, triangleSize2: 20))
                //     // .position(x: pipe.x - 19.5, y: UIScreen.main.bounds.height - (pipe.bottomHeight / 2) + 150) // Match collision detection positioning
            }
        }
    }
}

// MARK: - UPDATED SLOTH HITBOX (Final Precision Tweaks)
struct SlothHitbox: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        // Start near the face/upper body (mid-left)
        
        // Start Point (Face/Neck) - Tighter to the body
        path.move(to: CGPoint(x: rect.minX + rect.width * 0.35, y: rect.minY + rect.height * 0.32)) // Moved X right (0.3->0.35) and Y up (0.35->0.32)
        
        // 1. Top Outline (Back/Shoulder)
        // Upper Head/Back Curve (highest point)
        path.addLine(to: CGPoint(x: rect.minX + rect.width * 0.5, y: rect.minY + rect.height * 0.25))
        
        // Shoulder/Upper Arm Curve - Dropped slightly to fix overlap
        path.addLine(to: CGPoint(x: rect.minX + rect.width * 0.7, y: rect.minY + rect.height * 0.33)) // Y changed from 0.3 to 0.33
        
        // 2. Front Arm/Hand (Far Right - CAPTURING FINGERS)
        // Hand tip (Upper edge of claw - further out)
        path.addLine(to: CGPoint(x: rect.maxX - rect.width * 0.03, y: rect.minY + rect.height * 0.5)) 
        
        // Lowest part of the fingers/claw
        path.addLine(to: CGPoint(x: rect.maxX - rect.width * 0.05, y: rect.minY + rect.height * 0.6)) 
        
        // 3. Bottom Outline (Lower Arm/Belly/Leg)
        // Underside of arm (Tweak from previous step)
        path.addLine(to: CGPoint(x: rect.maxX - rect.width * 0.3, y: rect.minY + rect.height * 0.6))
        
        // Belly curve (Kept tight)
        path.addLine(to: CGPoint(x: rect.minX + rect.width * 0.6, y: rect.maxY - rect.height * 0.4))
        
        // Back Leg (Lowest point, kept high)
        path.addLine(to: CGPoint(x: rect.minX + rect.width * 0.3, y: rect.maxY - rect.height * 0.15))
        
        // 4. Back Leg/Foot (Far Left)
        // Back foot tip 
        path.addLine(to: CGPoint(x: rect.minX + rect.width * 0.05, y: rect.minY + rect.height * 0.75))
        
        // Upper back leg/Connect to start
        path.addLine(to: CGPoint(x: rect.minX + rect.width * 0.15, y: rect.minY + rect.height * 0.55))
        
        // Close the path back to start (connects to the first point)
        path.closeSubpath()
        
        return path
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
    
    // Note: UIRectCorner is not a standard SwiftUI/Shape type, you might need a simple enum if this isn't in a UIKit/AppKit context.
    // Assuming UIRectCorner is defined elsewhere or this is part of a larger, custom environment.
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
