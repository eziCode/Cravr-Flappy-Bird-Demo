//
//  AudioService.swift
//  Cravr Flappy Bird Demo
//
//  Created by Assistant on 10/30/25.
//

import Foundation
import AVFoundation

final class AudioService {
    static let shared = AudioService()
    
    private var wingPlayer: AVAudioPlayer?
    private var pointPlayer: AVAudioPlayer?
    
    private init() {
        // Optional: Keep system sounds/music unaffected
        try? AVAudioSession.sharedInstance().setCategory(.ambient, mode: .default, options: [])
        try? AVAudioSession.sharedInstance().setActive(true, options: [])
        
        wingPlayer = loadPlayer(resource: "sfx_wing", type: "mp3")
        pointPlayer = loadPlayer(resource: "sfx_point", type: "mp3")
        
        wingPlayer?.prepareToPlay()
        pointPlayer?.prepareToPlay()
    }
    
    private func loadPlayer(resource: String, type: String) -> AVAudioPlayer? {
        guard let url = Bundle.main.url(forResource: resource, withExtension: type) else {
            return nil
        }
        do {
            let player = try AVAudioPlayer(contentsOf: url)
            player.numberOfLoops = 0
            player.volume = 1.0
            return player
        } catch {
            return nil
        }
    }
    
    // Plays the wing sound; restarts immediately on rapid taps
    func playWing() {
        guard let player = wingPlayer else { return }
        if player.isPlaying {
            player.stop()
        }
        player.currentTime = 0
        player.play()
    }
    
    // Plays the point sound when scoring
    func playPoint() {
        guard let player = pointPlayer else { return }
        // For short SFX, a restart is fine even if overlapping events occur
        if player.isPlaying {
            player.stop()
        }
        player.currentTime = 0
        player.play()
    }
}


