//
//  Pipe.swift
//  Cravr Flappy Bird Demo
//
//  Created by Ezra Akresh on 10/16/25.
//

import Foundation
import SwiftUI

struct Pipe: Identifiable {
    let id = UUID()
    var x: CGFloat
    var topHeight: CGFloat
    var bottomHeight: CGFloat {
        UIScreen.main.bounds.height - topHeight - 150
    }
    var passed = false
}
