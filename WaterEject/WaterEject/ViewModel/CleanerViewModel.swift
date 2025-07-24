//
//  CleanerViewModel.swift
//  WaterEject
//
//  Created by Ruslan Liulka on 24.07.2025.
//

import Foundation

class CleanerViewModel: ObservableObject {
    private let audioManager = AudioManager()
    
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
    }
    
    
    
    func stop() {
        audioManager.stop()
    }
}
