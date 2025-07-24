//
//  AudioManager.swift
//  WaterEject
//
//  Created by Ruslan Liulka on 24.07.2025.
//

import AVFoundation

class AudioManager {
    private var engine: AVAudioEngine?
    private var playerNode: AVAudioPlayerNode?
    private var sweepTimer: Timer?
    
    func play(frequency: Double = 165.0, duration: TimeInterval = 3.0, channel: String = "both") {
        stop()
        
        let sampleRate = 44100
        let frameCount = AVAudioFrameCount(sampleRate * Int(duration))
        let format = AVAudioFormat(standardFormatWithSampleRate: Double(sampleRate), channels: 2)!
        let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: frameCount)!
        buffer.frameLength = frameCount
        
        let theta = 2.0 * Double.pi * frequency / Double(sampleRate)
        for i in 0..<Int(frameCount) {
            let sample = Float(sin(theta * Double(i)))
            switch channel {
            case "left":
                buffer.floatChannelData!.pointee[i] = sample      // Left channel
                buffer.floatChannelData!.advanced(by: 1).pointee[i] = 0.0  // Right channel
            case "right":
                buffer.floatChannelData!.pointee[i] = 0.0
                buffer.floatChannelData!.advanced(by: 1).pointee[i] = sample
            default:
                buffer.floatChannelData!.pointee[i] = sample
                buffer.floatChannelData!.advanced(by: 1).pointee[i] = sample
            }
        }
        
        engine = AVAudioEngine()
        playerNode = AVAudioPlayerNode()
        engine?.attach(playerNode!)
        engine?.connect(playerNode!, to: engine!.mainMixerNode, format: format)
        try? engine?.start()
        playerNode?.scheduleBuffer(buffer, at: nil, options: .interrupts, completionHandler: nil)
        playerNode?.play()
    }
    
    func playSweep(startFreq: Double = 20, endFreq: Double = 20000, duration: TimeInterval = 8.0, channel: String = "both") {
        stop()
        
        let sampleRate = 44100
        let frameCount = AVAudioFrameCount(sampleRate * Int(duration))
        let format = AVAudioFormat(standardFormatWithSampleRate: Double(sampleRate), channels: 2)!
        let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: frameCount)!
        buffer.frameLength = frameCount
        
        // Sweep (logarithmic)
        for i in 0..<Int(frameCount) {
            let t = Double(i) / Double(sampleRate)
            let sweepFreq = startFreq * pow(endFreq/startFreq, t / duration)
            let sample = Float(sin(2.0 * Double.pi * sweepFreq * t))
            switch channel {
            case "left":
                buffer.floatChannelData!.pointee[i] = sample
                buffer.floatChannelData!.advanced(by: 1).pointee[i] = 0.0
            case "right":
                buffer.floatChannelData!.pointee[i] = 0.0
                buffer.floatChannelData!.advanced(by: 1).pointee[i] = sample
            default:
                buffer.floatChannelData!.pointee[i] = sample
                buffer.floatChannelData!.advanced(by: 1).pointee[i] = sample
            }
        }
        
        engine = AVAudioEngine()
        playerNode = AVAudioPlayerNode()
        engine?.attach(playerNode!)
        engine?.connect(playerNode!, to: engine!.mainMixerNode, format: format)
        try? engine?.start()
        playerNode?.scheduleBuffer(buffer, at: nil, options: .interrupts, completionHandler: nil)
        playerNode?.play()
    }
    
    func playBurst(frequency: Double = 1000.0, duration: TimeInterval = 0.5, channel: String = "both") {
        stop() // Зупиняємо попереднє відтворення
        
        let sampleRate = 44100.0 // Використовуємо Double для точності
        let frameCount = AVAudioFrameCount(sampleRate * duration) // Без Int(duration)
        guard frameCount > 0 else {
            print("Error: Invalid frame count. Duration: \(duration), Calculated frames: \(sampleRate * duration)")
            return
        }
        
        guard let format = AVAudioFormat(standardFormatWithSampleRate: sampleRate, channels: 2) else {
            print("Error: Failed to create audio format")
            return
        }
        
        guard let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: frameCount) else {
            print("Error: Failed to create PCM buffer")
            return
        }
        buffer.frameLength = frameCount
        
        let leftChannel = buffer.floatChannelData![0]
        let rightChannel = buffer.floatChannelData![1]
        let theta = 2.0 * Double.pi * frequency / sampleRate
        
        for i in 0..<Int(frameCount) {
            let fadeLength = min(Int(sampleRate * 0.01), Int(frameCount) / 2)
            var envelope: Float = 1.0
            if i < fadeLength {
                envelope = Float(i) / Float(fadeLength)
            } else if i > Int(frameCount) - fadeLength {
                envelope = Float(Int(frameCount) - i) / Float(fadeLength)
            }
            let sample = envelope * Float(sin(theta * Double(i)))
            switch channel {
            case "left":
                leftChannel[i] = sample
                rightChannel[i] = 0.0
            case "right":
                leftChannel[i] = 0.0
                rightChannel[i] = sample
            default:
                leftChannel[i] = sample
                rightChannel[i] = sample
            }
        }
        
        engine = AVAudioEngine()
        playerNode = AVAudioPlayerNode()
        guard let engine = engine, let playerNode = playerNode else {
            print("Error: Failed to initialize engine or player node")
            return
        }
        
        engine.attach(playerNode)
        engine.connect(playerNode, to: engine.mainMixerNode, format: format)
        
        do {
            try engine.start()
        } catch {
            print("Error starting audio engine: \(error)")
            return
        }
        
        playerNode.scheduleBuffer(buffer, at: nil, options: .interrupts) {
            print("Burst finished playing")
        }
        
        playerNode.play()
    }
    
    func playBurstAndSweep(startFreq: Double = 50.0, endFreq: Double = 20000.0, burstDuration: TimeInterval = 0.5, sweepDuration: TimeInterval = 4.0, cycles: Int = 3, channel: String = "both") {
        stop()
        
        let sampleRate = 44100.0
        var currentCycle = 0
        
        func playNextCycle() {
            guard currentCycle < cycles else {
                print("Burst and Sweep finished")
                stop()
                return
            }
            
            // Спочатку відтворюємо імпульс
            playBurst(frequency: 1000.0, duration: burstDuration, channel: channel)
            
            // Після імпульсу запускаємо свип
            DispatchQueue.main.asyncAfter(deadline: .now() + burstDuration + 0.1) {
                self.playSweep(startFreq: startFreq, endFreq: endFreq, duration: sweepDuration, channel: channel)
                
                // Плануємо наступний цикл після завершення свипу
                DispatchQueue.main.asyncAfter(deadline: .now() + sweepDuration + 0.1) {
                    currentCycle += 1
                    playNextCycle()
                }
            }
        }
        
        playNextCycle()
    }
    
    // Метод із низькочастотними імпульсами
    func playLowFreqBursts(frequency: Double = 80.0, burstDuration: TimeInterval = 0.3, pauseDuration: TimeInterval = 0.2, cycles: Int = 5, channel: String = "both") {
        stop()
        
        let sampleRate = 44100.0
        let frameCount = AVAudioFrameCount(sampleRate * burstDuration)
        guard frameCount > 0 else {
            print("Error: Invalid frame count. Duration: \(burstDuration), Calculated frames: \(sampleRate * burstDuration)")
            return
        }
        
        guard let format = AVAudioFormat(standardFormatWithSampleRate: sampleRate, channels: 2) else {
            print("Error: Failed to create audio format")
            return
        }
        
        guard let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: frameCount) else {
            print("Error: Failed to create PCM buffer")
            return
        }
        buffer.frameLength = frameCount
        
        let leftChannel = buffer.floatChannelData![0]
        let rightChannel = buffer.floatChannelData![1]
        let theta = 2.0 * Double.pi * frequency / sampleRate
        
        for i in 0..<Int(frameCount) {
            let fadeLength = min(Int(sampleRate * 0.01), Int(frameCount) / 2)
            var envelope: Float = 1.0
            if i < fadeLength {
                envelope = Float(i) / Float(fadeLength)
            } else if i > Int(frameCount) - fadeLength {
                envelope = Float(Int(frameCount) - i) / Float(fadeLength)
            }
            let sample = envelope * Float(sin(theta * Double(i)))
            switch channel {
            case "left":
                leftChannel[i] = sample
                rightChannel[i] = 0.0
            case "right":
                leftChannel[i] = 0.0
                rightChannel[i] = sample
            default:
                leftChannel[i] = sample
                rightChannel[i] = sample
            }
        }
        
        engine = AVAudioEngine()
        playerNode = AVAudioPlayerNode()
        guard let engine = engine, let playerNode = playerNode else {
            print("Error: Failed to initialize engine or player node")
            return
        }
        
        engine.attach(playerNode)
        engine.connect(playerNode, to: engine.mainMixerNode, format: format)
        
        do {
            try engine.start()
        } catch {
            print("Error starting audio engine: \(error)")
            return
        }
        
        var currentCycle = 0
        
        func playNextBurst() {
            guard currentCycle < cycles else {
                print("Low frequency bursts finished")
                stop()
                return
            }
            
            playerNode.scheduleBuffer(buffer, at: nil, options: .interrupts) {
                print("Burst \(currentCycle + 1) finished")
                DispatchQueue.main.asyncAfter(deadline: .now() + pauseDuration) {
                    currentCycle += 1
                    playNextBurst()
                }
            }
            playerNode.play()
        }
        
        playNextBurst()
    }
    
    
    
    // Новий метод: багато вібрацій із випадковими частотами
    func playMultiVibration(minFreq: Double = 50.0, maxFreq: Double = 2000.0, burstDuration: TimeInterval = 0.1, pauseDuration: TimeInterval = 0.05, totalDuration: TimeInterval = 10.0, channel: String = "both") {
        stop()
        
        let sampleRate = 44100.0
        let frameCount = AVAudioFrameCount(sampleRate * burstDuration)
        guard frameCount > 0 else {
            print("Error: Invalid frame count. Burst duration: \(burstDuration), Calculated frames: \(sampleRate * burstDuration)")
            return
        }
        
        guard let format = AVAudioFormat(standardFormatWithSampleRate: sampleRate, channels: 2) else {
            print("Error: Failed to create audio format")
            return
        }
        
        engine = AVAudioEngine()
        playerNode = AVAudioPlayerNode()
        guard let engine = engine, let playerNode = playerNode else {
            print("Error: Failed to initialize engine or player node")
            return
        }
        
        engine.attach(playerNode)
        engine.connect(playerNode, to: engine.mainMixerNode, format: format)
        
        do {
            try engine.start()
        } catch {
            print("Error starting audio engine: \(error)")
            return
        }
        
        var elapsedTime: TimeInterval = 0.0
        var burstCount = 0
        
        func playNextVibration() {
            guard elapsedTime < totalDuration else {
                print("Multi-vibration sequence finished after \(burstCount) bursts")
                stop()
                return
            }
            
            // Генеруємо випадкову частоту
            let frequency = minFreq + (maxFreq - minFreq) * Double.random(in: 0...1)
            
            // Створюємо буфер для імпульсу
            guard let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: frameCount) else {
                print("Error: Failed to create PCM buffer")
                return
            }
            buffer.frameLength = frameCount
            
            let leftChannel = buffer.floatChannelData![0]
            let rightChannel = buffer.floatChannelData![1]
            let theta = 2.0 * Double.pi * frequency / sampleRate
            
            for i in 0..<Int(frameCount) {
                let fadeLength = min(Int(sampleRate * 0.005), Int(frameCount) / 2)
                var envelope: Float = 1.0
                if i < fadeLength {
                    envelope = Float(i) / Float(fadeLength)
                } else if i > Int(frameCount) - fadeLength {
                    envelope = Float(Int(frameCount) - i) / Float(fadeLength)
                }
                let sample = envelope * Float(sin(theta * Double(i)))
                switch channel {
                case "left":
                    leftChannel[i] = sample
                    rightChannel[i] = 0.0
                case "right":
                    leftChannel[i] = 0.0
                    rightChannel[i] = sample
                default:
                    leftChannel[i] = sample
                    rightChannel[i] = sample
                }
            }
            
            // Відтворюємо імпульс
            playerNode.scheduleBuffer(buffer, at: nil, options: .interrupts) {
                burstCount += 1
                elapsedTime += burstDuration + pauseDuration
                DispatchQueue.main.asyncAfter(deadline: .now() + pauseDuration) {
                    playNextVibration()
                }
            }
            playerNode.play()
        }
        
        playNextVibration()
    }
    
    func playCustomWaterEjectSequence(channel: String = "both") {
            stop()
            
            let totalDuration: TimeInterval = 30.0
            let phase1Duration: TimeInterval = 10.0 // Низькочастотні імпульси
            let phase2Duration: TimeInterval = 10.0 // Частотний свип
            let phase3Duration: TimeInterval = 10.0 // Швидкі вібрації
            
            // Налаштування аудіо-сесії
            let audioSession = AVAudioSession.sharedInstance()
            do {
                try audioSession.setCategory(.playback, mode: .default, options: [])
                try audioSession.setActive(true)
            } catch {
                print("Error configuring audio session: \(error)")
                return
            }
            
            // Фаза 1: Низькочастотні імпульси
            playLowFreqBursts(frequency: 80.0, burstDuration: 0.3, pauseDuration: 0.2, cycles: Int(phase1Duration / (0.3 + 0.2)), channel: channel)
            
            // Фаза 2: Частотний свип
            DispatchQueue.main.asyncAfter(deadline: .now() + phase1Duration) {
                self.playSweep(startFreq: 50.0, endFreq: 20000.0, duration: phase2Duration, channel: channel)
                
                // Фаза 3: Швидкі вібрації
                DispatchQueue.main.asyncAfter(deadline: .now() + phase2Duration) {
                    self.playMultiVibration(minFreq: 50.0, maxFreq: 2000.0, burstDuration: 0.1, pauseDuration: 0.05, totalDuration: phase3Duration, channel: channel)
                    
                    // Завершення
                    DispatchQueue.main.asyncAfter(deadline: .now() + phase3Duration) {
                        print("Custom water eject sequence finished")
                        self.stop()
                    }
                }
            }
        }
    
    
    func stop() {
        playerNode?.stop()
        engine?.stop()
        sweepTimer?.invalidate()
        sweepTimer = nil
    }
    
}
