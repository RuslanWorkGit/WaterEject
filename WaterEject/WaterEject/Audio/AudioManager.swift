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
    private var player: AVAudioPlayer?
    
    func playWav(named name: String) {
        guard let url = Bundle.main.url(forResource: name, withExtension: "wav") else {
            print("Не знайдено файл \(name).wav")
            return
        }
        do {
            player = try AVAudioPlayer(contentsOf: url)
            player?.prepareToPlay()
            player?.play()
            
            // Зупинити після 25 секунд
            DispatchQueue.main.asyncAfter(deadline: .now() + 25) { [weak self] in
                self?.player?.stop()
            }
        } catch {
            print("Помилка відтворення: \(error)")
        }
    }
    
    func stop() {
        sweepTimer?.invalidate()
        sweepTimer = nil
        
        player?.stop()
        player = nil
        
        playerNode?.stop()
        playerNode = nil
        
        engine?.stop()
        engine?.reset()
        engine = nil
    }
    
}

import AVFoundation

class AudioSequencePlayer: NSObject, AVAudioPlayerDelegate {
    private var players: [AVAudioPlayer] = []
    private var timer: Timer?
    private var currentIndex = 0
    private var soundNames: [String] = []
    
    func playSequence(soundNames: [String], duration: TimeInterval = 5.0) {
        stop()
        self.soundNames = soundNames
        currentIndex = 0
        playNext(duration: duration)
    }
    
    private func playNext(duration: TimeInterval) {
        guard currentIndex < soundNames.count else {
            stop() // повне очищення після завершення
            return
        }
        guard let url = Bundle.main.url(forResource: soundNames[currentIndex], withExtension: "wav") else {
            currentIndex += 1
            playNext(duration: duration)
            return
        }
        do {
            let p = try AVAudioPlayer(contentsOf: url)
            p.delegate = self
            p.prepareToPlay()
            p.play()
            players.append(p)
            
            timer?.invalidate()
            let t = Timer.scheduledTimer(withTimeInterval: duration, repeats: false) { [weak self, weak p] _ in
                p?.stop()
                self?.currentIndex += 1
                self?.playNext(duration: duration)
            }
            RunLoop.main.add(t, forMode: .common) // щоб не «зависав» під час жестів/скролу
            timer = t
        } catch {
            currentIndex += 1
            playNext(duration: duration)
        }
    }
    
    func stop() {
        timer?.invalidate()
        timer = nil
        players.forEach { $0.stop() }
        players.removeAll()
        soundNames.removeAll()
        currentIndex = 0
    }
}

