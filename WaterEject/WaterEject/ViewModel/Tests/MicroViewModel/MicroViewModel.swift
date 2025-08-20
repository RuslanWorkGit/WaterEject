////
////  MicroViewModel.swift
////  WaterEject
////
////  Created by Ruslan Liulka on 12.08.2025.
////
//

import AVFoundation
import Combine

final class MicroViewModel: NSObject, ObservableObject, AVAudioPlayerDelegate {
    // UI/state
    @Published var isRecording = false
    @Published var isPaused = false
    @Published var showSheet = false
    @Published var canContinue = false
    
    
    @Published var recordings: [Recording] = []
    @Published var currentlyPlaying: Recording? = nil
    @Published var elapsed: TimeInterval = 0
    
    // audio
    private let engine = AVAudioEngine()
    private let session = AVAudioSession.sharedInstance()
    private var file: AVAudioFile?
    private var outputURL: URL?
    private var player: AVAudioPlayer?
    private var elapsedTimer: Timer?
    
    // 👉 налаштування хвилі
    private let barCount = 90
    private let totalDuration: TimeInterval = 20
    private var bucketDuration: TimeInterval { totalDuration / Double(barCount) } // ~0.333c
    
    @Published var liveSamples: [Float] = []   // рівно 60 елементів
    
    // 👉 агрегатор поточного «біну»
    private var bucketIndex = 0
    private var bucketSum: Float = 0
    private var bucketN: Int = 0
    
    
    // MARK: - Шлях до теки Recordings
    private var recordingsFolderURL: URL {
        let doc = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        return doc.appendingPathComponent("Recordings", isDirectory: true)
    }
    
    private func ensureRecordingsFolder() {
        let url = recordingsFolderURL
        if !FileManager.default.fileExists(atPath: url.path) {
            try? FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
        }
    }
    
    // MARK: - Публічне API
    /// Виклич у .task / onAppear екрана
    @MainActor
    func loadRecordings() async {
        ensureRecordingsFolder()
        
        let urls = (try? FileManager.default.contentsOfDirectory(at: recordingsFolderURL, includingPropertiesForKeys: [.creationDateKey], options: [.skipsHiddenFiles])) ?? []
        
        // залишимо тільки .caf (або додай свої розширення)
        let audioURLs = urls.filter { $0.pathExtension.lowercased() == "caf" }
        
        // Зчитуємо метадані асинхронно
        var items: [Recording] = []
        for url in audioURLs {
            let asset = AVURLAsset(url: url)
            let duration = (try? await asset.load(.duration))?.seconds ?? 0
            let values = try? url.resourceValues(forKeys: [.creationDateKey])
            let created = values?.creationDate ?? Date(timeIntervalSince1970: 0)
            
            let rec = Recording(url: url, duration: duration, createdAt: created, title: url.deletingPathExtension().lastPathComponent)
            items.append(rec)
        }
        
        // Сортуємо нові згори
        items.sort { $0.createdAt > $1.createdAt }
        
        // Оновлюємо UI
        recordings = items
        canContinue = !items.isEmpty
    }
    
    // MARK: - Permissions
    func requestPermission() async -> Bool {
        await withCheckedContinuation { cont in
            if #available(iOS 17, *) {
                AVAudioApplication.requestRecordPermission { allowed in
                    cont.resume(returning: allowed)
                }
            } else {
                session.requestRecordPermission { allowed in
                    cont.resume(returning: allowed)
                }
            }
        }
    }
    
    // MARK: - Record
    func startRecording() async {
        guard await requestPermission() else { return }
        ensureRecordingsFolder()
        
        do {
            try session.setCategory(.playAndRecord, mode: .measurement, options: [.defaultToSpeaker, .allowBluetooth])
            try session.setActive(true)
            
            let format = engine.inputNode.inputFormat(forBus: 0)
            
            // файл у нашій теці
            let filename = "rec_\(Int(Date().timeIntervalSince1970)).caf"
            let url = recordingsFolderURL.appendingPathComponent(filename)
            outputURL = url
            file = try AVAudioFile(forWriting: url, settings: format.settings)
            
            engine.inputNode.installTap(onBus: 0, bufferSize: 2048, format: format) { [weak self] buffer, _ in
                guard let self else { return }
                try? self.file?.write(from: buffer)
                let level = Self.rms(from: buffer)
                DispatchQueue.main.async { self.push(level) }
            }
            
            try engine.start()
            await MainActor.run {
                isRecording = true
                isPaused = false
                elapsed = 0
                // 👉 підготовка хвилі
                liveSamples = Array(repeating: 0, count: barCount)
                bucketIndex = 0
                bucketSum = 0
                bucketN = 0
                startElapsedTimer()
            }
        } catch {
            print("Record start error:", error)
        }
    }
    
    func pauseRecording() {
        guard isRecording, !isPaused else { return }
        engine.pause()
        isPaused = true
        stopElapsedTimer()
        currentlyPlaying = nil
    }
    
    func resumeRecording() {
        guard isRecording, isPaused else { return }
        do {
            try engine.start()
            isPaused = false
            startElapsedTimer()
        } catch {
            print("Resume err:", error)
        }
    }
    
    /// save: true — зберегти і додати у список
    func stopRecording(save: Bool = true) {
        engine.inputNode.removeTap(onBus: 0)
        engine.stop()
        isRecording = false
        isPaused = false
        stopElapsedTimer()
        try? session.setActive(false, options: .notifyOthersOnDeactivation)
        
        guard save, let url = outputURL else { return }
        
        
        // 👉 фіналізуємо останній бін
        let avg = bucketN > 0 ? bucketSum / Float(bucketN) : 0
        if bucketIndex < barCount { liveSamples[bucketIndex] = avg }
        
        // 👉 нормалізуємо та зберігаємо в json поруч із аудіо
        var normalized = liveSamples
        if let m = normalized.max(), m > 0 { normalized = normalized.map { $0 / m } }
        do { try WaveformLoader.saveStoredSamples(normalized, forAudioURL: url) } catch {
            print("Save waveform error:", error)
        }
        
        
        Task {
            let asset = AVURLAsset(url: url)
            let duration = (try? await asset.load(.duration))?.seconds ?? 0
            let rec = Recording(url: url, duration: duration, createdAt: Date(),
                                title: url.deletingPathExtension().lastPathComponent)
            await MainActor.run {
                recordings.insert(rec, at: 0)
                canContinue = true
            }
        }
    }
    
    // MARK: - Delete
    @MainActor
    func deleteRecording(_ rec: Recording) {
        do {
            try FileManager.default.removeItem(at: rec.url)
        } catch {
            print("Delete error:", error)
        }
        if let idx = recordings.firstIndex(of: rec) {
            recordings.remove(at: idx)
        }
        if currentlyPlaying == rec {
            player?.stop()
            currentlyPlaying = nil
        }
        canContinue = !recordings.isEmpty
    }
    
    // MARK: - Player
    func play(url: URL) {
        
        if engine.isRunning {
                engine.inputNode.removeTap(onBus: 0)
                engine.stop()
            }
        // зупинити, якщо вже щось грає
        if let p = player, p.isPlaying {
            p.stop()
        }
        do {
            // 1) Готую сесію під ВІДТВОРЕННЯ:
            //    • .playback = грає навіть у беззвучному режимі
            //    • .allowAirPlay/.allowBluetooth (за бажанням)
            try session.setActive(false) // безпечно перевстановити категорію
                   try session.setCategory(.playback, mode: .default, options: []) // БЕЗ .allowBluetooth/.allowAirPlay
                   try session.setActive(true)
            
            // 2) Створюю плеєр
            let p = try AVAudioPlayer(contentsOf: url)
            p.delegate = self
            p.numberOfLoops = 0
            p.pan = 0                      // центр → обидва канали
            p.prepareToPlay()
            p.play()
            
            player = p
            currentlyPlaying = recordings.first(where: { $0.url == url })
        } catch {
            print("Play error:", error)
        }
    }
    
    func pausePlayback() {
        player?.pause()
    }
    
    // делегат — коли доріграв, скинути стан
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        DispatchQueue.main.async {
            self.currentlyPlaying = nil
            do { try self.session.setActive(false, options: .notifyOthersOnDeactivation) } catch { }
        }
    }
    
    // MARK: - Sheet helpers
    func openSheetAndStart() {
        showSheet = true
        Task { await startRecording() }
    }
    func closeSheet() {
        showSheet = false
    }
    
    
    
    // MARK: - Wave helpers
    private func startElapsedTimer() {
        elapsedTimer?.invalidate()
        elapsedTimer = Timer.scheduledTimer(withTimeInterval: 0.2, repeats: true) { [weak self] _ in
            guard let self else { return }
            self.elapsed += 0.2
            // Ліміт 20с запису
            if self.elapsed >= 20 {
                self.stopRecording(save: true)
            }
        }
    }
    private func stopElapsedTimer() {
        elapsedTimer?.invalidate()
        elapsedTimer = nil
    }
    
    private func push(_ v: Float) {
        let clamped = min(1, max(0, v))
        bucketSum += clamped
        bucketN += 1
        
        // індекс біну за поточним часом
        let idx = min(Int(elapsed / bucketDuration), barCount - 1)
        // коли перейшли у наступний бін — фіксуємо середнє попереднього
        while bucketIndex < idx {
            let avg = bucketN > 0 ? bucketSum / Float(bucketN) : 0
            liveSamples[bucketIndex] = avg
            bucketIndex += 1
            bucketSum = 0
            bucketN = 0
        }
    }
    
    private static func rms(from buffer: AVAudioPCMBuffer) -> Float {
        guard let ptr = buffer.floatChannelData?[0] else { return 0 }
        let n = Int(buffer.frameLength)
        if n == 0 { return 0 }
        var sum: Float = 0
        for i in 0..<n { sum += ptr[i]*ptr[i] }
        let rms = sqrt(sum / Float(n))
        return min(1, max(0, rms * 4))
    }
    
    var lastRecordedURL: URL? { outputURL }
}
