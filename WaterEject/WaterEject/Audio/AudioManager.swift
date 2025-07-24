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

    func stop() {
        playerNode?.stop()
        engine?.stop()
    }
}
