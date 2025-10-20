//
//  PixelTitle.swift
//  Cravr Flappy Bird Demo
//
//  Created by Ezra Akresh on 10/16/25.
//

import SwiftUI

struct PixelTitle: View {
    var text: String = "FLAPPY SLOTH"
    
    // App theme colors - using Cravr color palette
    let flappyColors: [Color] = [
        Color(hex: "f7ec59"), // Maize (F)
        Color(hex: "fa7921"), // Pumpkin (L) 
        Color(hex: "92dce5"), // Non Photo Blue (A)
        Color(hex: "f7ec59"), // Maize (P)
        Color(hex: "fa7921"), // Pumpkin (P)
        Color(hex: "92dce5"), // Non Photo Blue (Y)
    ]
    
    let slothColors: [Color] = [
        Color(hex: "92dce5"), // Non Photo Blue (S)
        Color(hex: "f7ec59"), // Maize (L)
        Color(hex: "fa7921"), // Pumpkin (O)
        Color(hex: "92dce5"), // Non Photo Blue (T)
        Color(hex: "f7ec59"), // Maize (H)
    ]
    
    var body: some View {
        VStack(spacing: 0) { // No spacing between lines
            // First line - FLAPPY
            HStack(spacing: 0) { // No spacing between letters
                ForEach(Array("FLAPPY".enumerated()), id: \.offset) { index, char in
                    PixelLetter(
                        char: char,
                        color: flappyColors[index % flappyColors.count],
                        size: 44
                    )
                }
            }
            
            // Second line - SLOTH  
            HStack(spacing: 0) { // No spacing between letters
                ForEach(Array("SLOTH".enumerated()), id: \.offset) { index, char in
                    PixelLetter(
                        char: char,
                        color: slothColors[index % slothColors.count],
                        size: 44
                    )
                }
            }
        }
        .padding(.horizontal, 20)
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

// MARK: - Pixel Letter (Flappy Bird style - thick but readable)
struct PixelLetter: View {
    let char: Character
    let color: Color
    let size: CGFloat
    var widthScale: CGFloat = 1.5
    var outlineOffset: CGFloat = 1.5 // match the max offset in outline

    private var pixelFont: Font { 
        if let uiFont = UIFont(name: "PressStart2P-Regular", size: size) {
            return Font(uiFont)
        } else {
            return .system(size: size, design: .monospaced)
        }
    }

    var body: some View {
        ZStack {
            // Outline
            Group {
                Text(String(char)).font(pixelFont).foregroundColor(.black).offset(x: -outlineOffset, y: 0)
                Text(String(char)).font(pixelFont).foregroundColor(.black).offset(x: outlineOffset, y: 0)
                Text(String(char)).font(pixelFont).foregroundColor(.black).offset(x: 0, y: -1)
                Text(String(char)).font(pixelFont).foregroundColor(.black).offset(x: 0, y: 1)
                Text(String(char)).font(pixelFont).foregroundColor(.black).offset(x: -outlineOffset, y: -1)
                Text(String(char)).font(pixelFont).foregroundColor(.black).offset(x: outlineOffset, y: -1)
                Text(String(char)).font(pixelFont).foregroundColor(.black).offset(x: -outlineOffset, y: 1)
                Text(String(char)).font(pixelFont).foregroundColor(.black).offset(x: outlineOffset, y: 1)
            }
            
            // Main letter
            Text(String(char))
                .font(pixelFont)
                .foregroundColor(color)
        }
        // Scale from leading so letters touch left edge
        .scaleEffect(x: widthScale, y: 1.0, anchor: .center)
    }
}
