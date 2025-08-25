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
        playerNode?.stop()
        engine?.stop()
        player?.stop()
        sweepTimer?.invalidate()
        sweepTimer = nil
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
        guard currentIndex < soundNames.count else { return }
        guard let url = Bundle.main.url(forResource: soundNames[currentIndex], withExtension: "wav") else {
            print("Файл не знайдено")
            currentIndex += 1
            playNext(duration: duration)
            return
        }
        do {
            let player = try AVAudioPlayer(contentsOf: url)
            players.append(player)
            player.delegate = self
            player.play()
            // Зупиняємо через 5 секунд, навіть якщо файл довший
            timer = Timer.scheduledTimer(withTimeInterval: duration, repeats: false) { [weak self] _ in
                player.stop()
                self?.currentIndex += 1
                self?.playNext(duration: duration)
            }
        } catch {
            print("Помилка відтворення: \(error)")
            currentIndex += 1
            playNext(duration: duration)
        }
    }
    
    func stop() {
        timer?.invalidate()
        players.forEach { $0.stop() }
        players.removeAll()
        currentIndex = 0
    }
}

