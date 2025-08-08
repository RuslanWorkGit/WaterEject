//
//  TestViewModel.swift
//  WaterEject
//
//  Created by Ruslan Liulka on 08.08.2025.
//

import Foundation
import AVFoundation
import Combine


class TestViewModel: NSObject, ObservableObject {
    @Published var volume: Float = 0.5

    override init() {
        super.init()
        let audioSession = AVAudioSession.sharedInstance()
        audioSession.addObserver(self, forKeyPath: "outputVolume", options: [.new], context: nil)
        try? audioSession.setActive(true)
        self.volume = audioSession.outputVolume
    }

    deinit {
        let audioSession = AVAudioSession.sharedInstance()
        audioSession.removeObserver(self, forKeyPath: "outputVolume")
    }

    override func observeValue(
        forKeyPath keyPath: String?,
        of object: Any?,
        change: [NSKeyValueChangeKey : Any]?,
        context: UnsafeMutableRawPointer?
    ) {
        if keyPath == "outputVolume",
           let newVolume = change?[.newKey] as? Float {
            DispatchQueue.main.async {
                self.volume = newVolume
            }
        }
    }
}

