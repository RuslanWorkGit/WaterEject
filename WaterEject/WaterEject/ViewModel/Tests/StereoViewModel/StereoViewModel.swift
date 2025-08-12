//
//  StereoViewModel.swift
//  WaterEject
//
//  Created by Ruslan Liulka on 08.08.2025.
//

import Foundation
import AVFoundation
import Combine

class StereoViewModel: NSObject, ObservableObject {
    @Published var volume: Float = 0.5
    
    private let engine = AVAudioEngine()
    private let player = AVAudioPlayerNode()
    private var audioFile: AVAudioFile?
    private var hasStartedEngine = false
    private let session = AVAudioSession.sharedInstance()

    override init() {
        super.init()
        // 1) Готуємо сесію відтворення, яка працює в silent mode
        preparePlaybackSession()

        // KVO гучності — щоб показувати % у UI
        session.addObserver(self, forKeyPath: "outputVolume", options: [.new], context: nil)
        try? session.setActive(true)
        self.volume = session.outputVolume

        configureEngineIfNeeded()
        loadDefaultAudioFile()
    }
    
    deinit {
        session.removeObserver(self, forKeyPath: "outputVolume")
        engine.stop()
    }
    
    // Категорія .playback ігнорує тумблер mute
    private func preparePlaybackSession() {
        do {
            try session.setCategory(
                .playback,
                mode: .default,
                options: [.mixWithOthers, .allowBluetoothA2DP, .defaultToSpeaker]
            )
            try session.setActive(true, options: [])
        } catch {
            print("Audio session error:", error)
        }
    }

    override func observeValue(forKeyPath keyPath: String?,
                               of object: Any?, change: [NSKeyValueChangeKey : Any]?,
                               context: UnsafeMutableRawPointer?) {
        if keyPath == "outputVolume",
           let newVolume = change?[.newKey] as? Float {
            DispatchQueue.main.async { self.volume = newVolume }
        }
    }
    
    func playTest(left: Bool, right: Bool) {
        guard left || right else { return }

        // ще раз гарантуємо правильну категорію перед відтворенням
        preparePlaybackSession()
        configureEngineIfNeeded()
        
        // панорама: -1 ліво, 0 центр, +1 право
        player.pan = (left && right) ? 0 : (left ? -1 : 1)
        
        player.stop()
        if let file = audioFile {
            player.scheduleFile(file, at: nil, completionHandler: nil)
            player.play()
        } else if let buf = Self.makeSineBuffer(freq: 1000, seconds: 1.0) {
            player.scheduleBuffer(buf, at: nil, options: [], completionHandler: nil)
            player.play()
        }
    }
    
    func stop() { player.stop() }
    
    func configureEngineIfNeeded() {
        guard !hasStartedEngine else { return }
        engine.attach(player)
        engine.connect(player, to: engine.mainMixerNode, format: nil)
        do {
            try engine.start()
            hasStartedEngine = true
        } catch {
            print("AVAudioEngine start error:", error)
        }
    }
    
    func loadDefaultAudioFile() {
        if let url = Bundle.main.url(forResource: "pianino", withExtension: "wav") {
            audioFile = try? AVAudioFile(forReading: url)
        }
    }
    
    static func makeSineBuffer(freq: Double, seconds: Double) -> AVAudioPCMBuffer? {
        let sr: Double = 44100
        let frames = AVAudioFrameCount(seconds * sr)
        let format = AVAudioFormat(standardFormatWithSampleRate: sr, channels: 1)!
        guard let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: frames) else { return nil }
        buffer.frameLength = frames
        let p = buffer.floatChannelData![0]
        let w = 2.0 * .pi * freq / sr
        for i in 0..<Int(frames) { p[i] = Float(sin(w * Double(i)) * 0.7) }
        return buffer
    }
}

