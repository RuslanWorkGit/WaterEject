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
    }

    func playRight() {
        audioManager.play(channel: "right")
    }

    func playBoth() {
        audioManager.play(channel: "both")
    }

    func stop() {
        audioManager.stop()
    }
}
