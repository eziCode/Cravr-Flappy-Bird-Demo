//
//  SlothIcon.swift
//  Cravr Flappy Bird Demo
//
//  Created by Ezra Akresh on 10/16/25.
//

import SwiftUI

struct SlothIcon: View {
    var size: CGFloat = 80
    
    var body: some View {
        let faceColor = Color(hex: "8B7355")
        let maskColor = Color(hex: "CBB38A")
        let patchColor = Color(hex: "5A4632")
        let noseColor = Color(hex: "3C2C1E")

        ZStack {
            // Shadow
            Circle()
                .fill(Color.black.opacity(0.25))
                .frame(width: size * 1.02, height: size * 1.02)
                .offset(x: size * 0.07, y: size * 0.07)

            // Head
            Circle()
                .fill(faceColor)
                .frame(width: size, height: size)

            // Face mask (lighter oval area)
            Ellipse()
                .fill(maskColor)
                .frame(width: size * 0.8, height: size * 0.6)
                .offset(y: -size * 0.05)

            // Eye patches
            Group {
                Ellipse()
                    .fill(patchColor)
                    .frame(width: size * 0.25, height: size * 0.18)
                    .offset(x: -size * 0.22, y: -size * 0.12)
                Ellipse()
                    .fill(patchColor)
                    .frame(width: size * 0.25, height: size * 0.18)
                    .offset(x: size * 0.22, y: -size * 0.12)
            }

            // Eyes
            Group {
                Circle()
                    .fill(Color.black)
                    .frame(width: size * 0.08, height: size * 0.08)
                    .offset(x: -size * 0.22, y: -size * 0.12)
                Circle()
                    .fill(Color.black)
                    .frame(width: size * 0.08, height: size * 0.08)
                    .offset(x: size * 0.22, y: -size * 0.12)
            }

            // Nose
            Ellipse()
                .fill(noseColor)
                .frame(width: size * 0.14, height: size * 0.1)
                .offset(y: size * 0.05)

            // Mouth (gentle smile)
            Path { path in
                let mouthWidth = size * 0.25
                let mouthHeight = size * 0.08
                path.addArc(
                    center: CGPoint(x: 0, y: size * 0.08),
                    radius: mouthWidth / 2,
                    startAngle: .degrees(20),
                    endAngle: .degrees(160),
                    clockwise: false
                )
            }
            .stroke(noseColor, lineWidth: size * 0.02)
            .offset(y: size * 0.04)
        }
    }
}
