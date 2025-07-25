//
//  CleanerViewModel.swift
//  WaterEject
//
//  Created by Ruslan Liulka on 24.07.2025.
//

import Foundation

class CleanerViewModel: ObservableObject {
    private let audioManager = AudioManager()
    private let seqPlayer = AudioSequencePlayer()
    
    func playLeft() {
        audioManager.play(channel: "left")
        print("left")
    }
    
    func playRight() {
        audioManager.play(channel: "right")
        print("right")
    }
    
    func playBoth() {
        audioManager.play(channel: "both")
        print("both")
    }
    
    func playSweep() {
        audioManager.playSweep()
        print("sweep")
    }
    
    
    func playBurst() {
        audioManager.playBurst()
        print("Burst")
    }
    
    func playBurstAndSweep() {
        audioManager.playBurstAndSweep()
        print("Burst and Sweep")
    }
    
    func playLowFreqBursts() {
        audioManager.playLowFreqBursts()
        print("Low Frequency Bursts")
    }
    
    func playMultiVibration() {
        audioManager.playMultiVibration()
        print("Multi Vibration")
    }
    
    
    func playCustomWaterEjectSequence() {
            audioManager.playCustomWaterEjectSequence()
            print("Custom Water Eject Sequence")
        }
    
    func playSomeWav() {
        audioManager.playWav(named: "some-sound")
    }
    
    
        func playCleaningSequence() {
            // Приклад: 4 файли, усі в папці проєкту (без розширення!)
            seqPlayer.playSequence(soundNames: ["fifty-tone", "hundred-tone-v1", "hundred-tone-v2", "hundred-and-fifty-tone"], duration: 5.0)
        }
    
    
    func stop() {
        audioManager.stop()
        seqPlayer.stop()
    }
}
