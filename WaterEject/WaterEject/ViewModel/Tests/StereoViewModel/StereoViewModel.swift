//
//  StereoViewModel.swift
//  WaterEject
//
//  Created by Ruslan Liulka on 08.08.2025.
//

import AVFoundation
import Combine

final class StereoViewModel: NSObject, ObservableObject {
    @Published var volume: Float = 0.5
    @Published var isPlaying: Bool = false

    private let session = AVAudioSession.sharedInstance()
    private let engine  = AVAudioEngine()
    private let left    = AVAudioPlayerNode()
    private let right   = AVAudioPlayerNode()

    private var loopBuffer: AVAudioPCMBuffer?
    private var engineStarted = false
    private var scheduled = false   // <- чи вже закладено буфер у ноди

    override init() {
        super.init()
        preparePlaybackSession()
        session.addObserver(self, forKeyPath: "outputVolume", options: [.new], context: nil)
        try? session.setActive(true)
        self.volume = session.outputVolume

        configureEngineIfNeeded()
        loadLoopBuffer()
    }

    deinit {
        session.removeObserver(self, forKeyPath: "outputVolume")
        engine.stop()
    }

    private func preparePlaybackSession() {
        do {
            try session.setCategory(.playback,
                                    mode: .default,
                                    options: [.mixWithOthers, .defaultToSpeaker, .allowBluetoothA2DP])
            try session.setActive(true)
        } catch { print("Audio session error:", error) }
    }

    override func observeValue(forKeyPath keyPath: String?, of object: Any?,
                               change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "outputVolume", let v = change?[.newKey] as? Float {
            DispatchQueue.main.async { self.volume = v }
        }
    }

    // MARK: Public API

    /// Запуск або «продовжити» з урахуванням обраних каналів
    func playTest(leftOn: Bool, rightOn: Bool) {
        guard leftOn || rightOn else { return }   // якщо обидва вимкнені — не стартуємо
        preparePlaybackSession()
        configureEngineIfNeeded()
        startLoopIfNeeded()
        updateRouting(leftOn: leftOn, rightOn: rightOn)
        isPlaying = true
    }

    /// Миттєво оновлюємо гучність каналів
    func updateRouting(leftOn: Bool, rightOn: Bool) {
        left.volume  = leftOn  ? 1.0 : 0.0
        right.volume = rightOn ? 1.0 : 0.0
        // якщо обидва вимкнули — вважаємо, що «не грає» (кнопка покаже Start)
        //if !leftOn && !rightOn { isPlaying = false }
    }

    func pause() {
        left.pause()
        right.pause()
        isPlaying = false
        // scheduled лишається true → буфер збережений, play() відновить миттєво
    }

    func stop() {
        left.stop()
        right.stop()
        scheduled = false
        isPlaying = false
    }

    // MARK: Engine / audio
    private func configureEngineIfNeeded() {
        guard !engineStarted else { return }
        engine.attach(left)
        engine.attach(right)

        left.pan  = -1.0
        right.pan = +1.0

        engine.connect(left,  to: engine.mainMixerNode, format: nil)
        engine.connect(right, to: engine.mainMixerNode, format: nil)
        do {
            try engine.start()
            engineStarted = true
        } catch { print("Engine start error:", error) }
    }

    private func loadLoopBuffer() {
        if let url = Bundle.main.url(forResource: "pianino", withExtension: "wav"),
           let file = try? AVAudioFile(forReading: url) {
            loopBuffer = file.makeEntireFileBuffer()
        } else {
            loopBuffer = Self.makeSineBuffer(freq: 1000, seconds: 1.0)
        }
    }

    private func startLoopIfNeeded() {
        guard let buf = loopBuffer else { return }
        if !scheduled {
            left.scheduleBuffer(buf, at: nil, options: [.loops], completionHandler: nil)
            right.scheduleBuffer(buf, at: nil, options: [.loops], completionHandler: nil)
            scheduled = true
        }
        if !left.isPlaying { left.play() }
        if !right.isPlaying { right.play() }
    }

    // Helpers
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

private extension AVAudioFile {
    func makeEntireFileBuffer() -> AVAudioPCMBuffer? {
        guard let buf = AVAudioPCMBuffer(pcmFormat: processingFormat,
                                         frameCapacity: AVAudioFrameCount(length)) else { return nil }
        do { try read(into: buf); return buf } catch { return nil }
    }
}
