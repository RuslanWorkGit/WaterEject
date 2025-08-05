//
//  StartViewModel.swift
//  WaterEject
//
//  Created by Ruslan Liulka on 04.08.2025.
//

import Foundation
import SwiftUI
import AVFoundation

final class StartViewModel: ObservableObject {
    
    private var engine: AVAudioEngine?
    private var playerNode: AVAudioPlayerNode?
    private var sweepTimer: Timer?
    private var player: AVAudioPlayer?
    
    private let audioManager = AudioManager()
    private let seqPlayer = AudioSequencePlayer()
    
    
    @Published var startCleaning: Bool = false
    @Published var countdown: Int = 25
    
    private var timer: Timer?
    
    
    func playCleaningSequence() {
        setupAudioSessionForPlayback()
        // Приклад: 4 файли, усі в папці проєкту (без розширення!)
        seqPlayer.playSequence(soundNames: ["fifty-tone", "hundred-tone-v1", "hundred-tone-v2", "hundred-and-fifty-tone", "hundred-tone-v1"], duration: 5.0)
    }
    
    
    func setupAudioSessionForPlayback() {
        let session = AVAudioSession.sharedInstance()
        do {
            try session.setCategory(.playback, mode: .default, options: [.mixWithOthers])
            try session.setActive(true)
        } catch {
            print("Failed to setup AVAudioSession: \(error)")
        }
    }
    
    func startTimer() {
        stopTimer()
        countdown = 25
        startCleaning = true
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            if self.countdown > 0 {
                self.countdown -= 1
            }
            if self.countdown == 0 {
                self.stopTimer()
            }
        }
    }
    
    func stopTimer() {
        timer?.invalidate()
        timer = nil
        startCleaning = false
        countdown = 25
    }
}
