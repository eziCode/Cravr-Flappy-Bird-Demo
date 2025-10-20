//
//  PixelTitle.swift
//  Cravr Flappy Bird Demo
//
//  Created by Ezra Akresh on 10/16/25.
//

import SwiftUI

struct PixelTitle: View {
    var text: String = "FLAPPY SLOTH"
    
    // Define retro palette
    let colors: [Color] = [
        Color(hex: "f7ec59"), // Maize
        Color(hex: "92dce5"), // Non Photo Blue
        Color(hex: "fa7921"), // Pumpkin
        Color(hex: "1cd91f")  // SGBus Green
    ]
    
    var body: some View {
        VStack(spacing: 4) {
            // First line - FLAPPY
            PixelText(
                text: "FLAPPY", 
                fontSize: 36, 
                color: UIColor(colors[0]), 
                outlineColor: UIColor.black
            )
            .scaleEffect(x: 1.5, y: 1.25) // 50% fatter, 25% taller
            .frame(height: 50)
            
            // Second line - SLOTH
            PixelText(
                text: "SLOTH", 
                fontSize: 36, 
                color: UIColor(colors[1]), 
                outlineColor: UIColor.black
            )
            .scaleEffect(x: 1.5, y: 1.25) // 50% fatter, 25% taller
            .frame(height: 50)
        }
        .padding(.horizontal, 6)
    }
}

// MARK: - Pixel Text with proper stroke outline
struct PixelText: UIViewRepresentable {
    let text: String
    let fontSize: CGFloat
    let color: UIColor
    let outlineColor: UIColor

    func makeUIView(context: Context) -> UILabel {
        let label = UILabel()
        label.attributedText = attributedString()
        label.textAlignment = .center
        label.adjustsFontSizeToFitWidth = false
        label.numberOfLines = 1
        return label
    }

    func updateUIView(_ uiView: UILabel, context: Context) {
        uiView.attributedText = attributedString()
    }

    private func attributedString() -> NSAttributedString {
        let font = UIFont(name: "PressStart2P-Regular", size: fontSize) ?? UIFont.monospacedSystemFont(ofSize: fontSize, weight: .regular)
        let strokeWidth: CGFloat = -2 // negative = stroke + fill

        return NSAttributedString(
            string: text,
            attributes: [
                .font: font,
                .foregroundColor: color,
                .strokeColor: outlineColor,
                .strokeWidth: strokeWidth,
                .kern: -2 // Negative letter spacing to bring letters closer
            ]
        )
    }
}

// MARK: - Pixel Letter (crisp 1px outline around pixel font)
struct PixelLetter: View {
    let char: Character
    let color: Color
    let size: CGFloat
    var widthScale: CGFloat = 1.0

    private var pixelFont: Font { 
        if let uiFont = UIFont(name: "PressStart2P-Regular", size: size) {
            return Font(uiFont)
        } else {
            return .system(size: size, design: .monospaced)
        }
    }

    var body: some View {
        ZStack {
            // 1px outline scaled properly
            Group {
                Text(String(char)).font(pixelFont).foregroundColor(.black).offset(x: -1 * widthScale, y: 0)
                Text(String(char)).font(pixelFont).foregroundColor(.black).offset(x: 1 * widthScale, y: 0)
                Text(String(char)).font(pixelFont).foregroundColor(.black).offset(x: 0, y: -1)
                Text(String(char)).font(pixelFont).foregroundColor(.black).offset(x: 0, y: 1)
                Text(String(char)).font(pixelFont).foregroundColor(.black).offset(x: -1 * widthScale, y: -1)
                Text(String(char)).font(pixelFont).foregroundColor(.black).offset(x: 1 * widthScale, y: -1)
                Text(String(char)).font(pixelFont).foregroundColor(.black).offset(x: -1 * widthScale, y: 1)
                Text(String(char)).font(pixelFont).foregroundColor(.black).offset(x: 1 * widthScale, y: 1)
            }
            
            // Main colored letter
            Text(String(char))
                .font(pixelFont)
                .foregroundColor(color)
                .shadow(color: Color.black.opacity(0.5), radius: 0, x: 1 * widthScale, y: 1)
        }
        .scaleEffect(x: widthScale, y: 1.0, anchor: .center)
        .padding(.horizontal, 1)
        .drawingGroup()
    }
}
