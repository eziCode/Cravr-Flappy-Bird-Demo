//
//  PixelTitle.swift
//  Cravr Flappy Bird Demo
//
//  Created by Ezra Akresh on 10/16/25.
//

import SwiftUI

struct PixelTitle: View {
    var text: String = "FLAPPY SLOTH"
    
    // Flappy Bird style colors - vibrant and distinct per letter
    let flappyColors: [Color] = [
        Color(hex: "f7ec59"), // Bright Yellow (F)
        Color(hex: "ff69b4"), // Vibrant Pink (L) 
        Color(hex: "87ceeb"), // Light Sky Blue (A)
        Color(hex: "4169e1"), // Medium Royal Blue (P)
        Color(hex: "32cd32"), // Bright Lime Green (P)
        Color(hex: "9370db"), // Medium Lavender Purple (Y)
    ]
    
    let slothColors: [Color] = [
        Color(hex: "9370db"), // Medium Lavender Purple (S)
        Color(hex: "f7ec59"), // Bright Yellow (L)
        Color(hex: "ff69b4"), // Vibrant Pink (O)
        Color(hex: "87ceeb"), // Light Sky Blue (T)
        Color(hex: "4169e1"), // Medium Royal Blue (H)
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
