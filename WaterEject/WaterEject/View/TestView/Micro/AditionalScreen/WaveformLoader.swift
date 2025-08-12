//
//  WaveformLoader.swift
//  WaterEject
//
//  Created by Ruslan Liulka on 12.08.2025.
//

import AVFoundation

enum WaveformLoader {
    /// Повертає масив 0...1 для побудови хвилі зі звуку у `url`
    static func loadSamples(url: URL, targetSamples: Int = 80) async throws -> [Float] {
        let file = try AVAudioFile(forReading: url)
        let format = file.processingFormat
        let frameCount = UInt32(file.length)
        guard let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: frameCount) else {
            return []
        }
        try file.read(into: buffer)
        guard let ch = buffer.floatChannelData?[0] else { return [] }
        let n = Int(buffer.frameLength)

        // даунсемпл: ділимо на "вікна" і беремо середнє абсолютне
        let window = max(1, n / targetSamples)
        var out: [Float] = []
        out.reserveCapacity(targetSamples)

        var i = 0
        while i < n {
            let end = min(n, i + window)
            var sum: Float = 0
            var cnt: Int = 0
            var j = i
            while j < end {
                sum += abs(ch[j])
                cnt += 1
                j += 1
            }
            out.append(cnt > 0 ? (sum / Float(cnt)) : 0)
            i += window
        }

        // Нормалізація
        if let maxv = out.max(), maxv > 0 {
            out = out.map { $0 / maxv }
        }
        return out
    }
}
