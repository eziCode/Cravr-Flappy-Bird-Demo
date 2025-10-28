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
    var gapHeight: CGFloat // Height of the gap between pipes
    var verticalOffset: CGFloat // Vertical offset to position the gap
    var passed = false
}
