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
    
    mutating func reset() {
        y = 0
        velocity = 0
        scale = 1.0
    }
    
    mutating func jump(with jumpForce: CGFloat) {
        velocity = jumpForce
    }
    
    mutating func applyGravity(_ gravity: CGFloat) {
        velocity += gravity
        y += velocity
    }
    
    var frame: CGRect {
        CGRect(x: 100 - 15, y: y + UIScreen.main.bounds.height / 2 - 15, width: 30, height: 30)
    }
}
