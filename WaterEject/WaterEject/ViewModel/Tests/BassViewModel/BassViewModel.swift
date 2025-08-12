//
//  BassViewModel.swift
//  WaterEject
//
//  Created by Ruslan Liulka on 12.08.2025.
//

import SwiftUI
import AVFoundation

final class BassViewModel: NSObject, ObservableObject, AVAudioPlayerDelegate {
    struct Clip: Identifiable, Hashable {
        let id = UUID()
        let title: String
        let file: String   // ім’я .wav у бандлі без розширення
    }

    // 4 кліпи, які треба прослухати
    @Published var clips: [Clip] = [
        .init(title: "Audio 1", file: "first"),
        .init(title: "Audio 2", file: "second"),
        .init(title: "Audio 3", file: "third"),
        .init(title: "Audio 4", file: "fourth"),
    ]

    // які кліпи вже завершено
    @Published private(set) var finished: Set<Clip> = []

    // який кліп зараз грає
    @Published private(set) var playing: Clip?

    var allDone: Bool { finished.count == clips.count }

    private var player: AVAudioPlayer?

    func togglePlay(_ clip: Clip) {
        // якщо вже грає цей самий — зупиняємо
        if playing == clip {
            stop()
            return
        }
        // якщо грає інший — зупиняємо і стартуємо новий
        stop()
        start(clip)
    }

    private func start(_ clip: Clip) {
        guard let url = Bundle.main.url(forResource: clip.file, withExtension: "wav") else {
            print("Missing \(clip.file).wav")
            return
        }
        do {
            let p = try AVAudioPlayer(contentsOf: url)
            p.delegate = self
            p.prepareToPlay()
            p.play()
            self.player = p
            self.playing = clip
        } catch {
            print("Player error: \(error)")
        }
    }

    func stop() {
        player?.stop()
        player = nil
        playing = nil
    }

    // коли трек дограв — позначаємо як завершений
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        if let clip = playing {
            finished.insert(clip)
        }
        playing = nil
        self.player = nil
    }

    // утиліти для View
    func isFinished(_ clip: Clip) -> Bool { finished.contains(clip) }
    func isPlaying(_ clip: Clip) -> Bool { playing == clip }
}
