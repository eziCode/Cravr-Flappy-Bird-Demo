//
//  Sloth.swift
//  Cravr Flappy Bird Demo
//
//  Created by Ezra Akresh on 10/16/25.
//

import Foundation
import SwiftUI

struct Sloth {
    var y: CGFloat = 0
    var velocity: CGFloat = 0
    var scale: CGFloat = 1.0
    var rotation: Double = 0.0 // Rotation in degrees
    
    mutating func reset() {
        y = 0
        velocity = 0
        scale = 1.0
        rotation = 0.0
    }
    
    mutating func jump(with jumpForce: CGFloat) {
        velocity = jumpForce
    }
    
    mutating func applyGravity(_ gravity: CGFloat) {
        velocity += gravity
        y += velocity
    }
    
    mutating func updateRotation() {
        // Rotate 30 degrees up when flying upward (negative velocity)
        // Rotate 30 degrees down when falling (positive velocity)
        if velocity < 0 {
            // Flying upward - rotate above horizontal
            rotation = -15.0
        } else {
            // Falling downward - rotate below horizontal
            rotation = 20.0
        }
    }
    
    var frame: CGRect {
        CGRect(x: 100 - 15, y: y + UIScreen.main.bounds.height / 2 - 15, width: 30, height: 30)
    }
}
