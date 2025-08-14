//
//  VibroViewModel.swift
//  WaterEject
//
//  Created by Ruslan Liulka on 12.08.2025.
//

import Foundation
import SwiftUI
import CoreHaptics
import AudioToolbox

final class VibroViewModel: ObservableObject {
    
    @Published var vibroMode: VibroModel = .waves
    @Published var intensity: IntensityLevel = .medium
    @Published var completedModes: Set<VibroModel> = []
    
    private var engine: CHHapticEngine?
    private let supportsHaptics = CHHapticEngine.capabilitiesForHardware().supportsHaptics
    
    init() { createEngine() }
    
    private func createEngine() {
        guard supportsHaptics else { return }
        do {
            engine = try CHHapticEngine()
            engine?.resetHandler = { [weak self] in
                try? self?.engine?.start()
            }
            try engine?.start()
        } catch {
            print("Haptics init error: \(error)")
        }
    }
    
    func playVibro() {
        guard supportsHaptics else {
            AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
            markCompletedAndAdvance()
            return
        }
        do {
            try engine?.start()
            let pattern: CHHapticPattern
            switch vibroMode {
            case .waves:   pattern = try buildWaves()
            case .heart:   pattern = try buildPulses()
            case .volcano: pattern = try buildHeartbeat()
            case .push:    pattern = try buildRamp()
            }
            
            let player = try engine?.makePlayer(with: pattern)
            try player?.start(atTime: 0)
            
            // Успішно стартувало → ставимо чек і переключаємось
            markCompletedAndAdvance()
        } catch {
            print("Haptics play error: \(error)")
        }
    }
    
    private func markCompletedAndAdvance() {
        withAnimation { completedModes.insert(vibroMode) }
        
        // знайти наступний невиконаний; якщо всі — просто наступний по колу
        let all = Array(VibroModel.allCases)
        guard let i = all.firstIndex(of: vibroMode) else { return }
        
        if let nextUncompletedIndex = (1...all.count).first(where: { off in
            let j = (i + off) % all.count
            return !completedModes.contains(all[j])
        }).map({ (i + $0) % all.count }) {
            withAnimation { vibroMode = all[nextUncompletedIndex] }
        } else {
            // усі виконані — рухаємось по колу
            let next = (i + 1) % all.count
            withAnimation { vibroMode = all[next] }
        }
    }
    
    // MARK: - Patterns
    
    /// Один «хвильовий» безперервний поштовх з м’якою модуляцією
    private func buildWaves() throws -> CHHapticPattern {
        let duration = intensity.waveDuration
        let params = [
            CHHapticEventParameter(parameterID: .hapticIntensity, value: intensity.amp),
            CHHapticEventParameter(parameterID: .hapticSharpness, value: intensity.sharp)
        ]
        let event = CHHapticEvent(eventType: .hapticContinuous,
                                  parameters: params,
                                  relativeTime: 0,
                                  duration: duration)
        
        var curves: [CHHapticParameterCurve] = []
        if intensity != .soft {
            let cp: [CHHapticParameterCurve.ControlPoint] = [
                .init(relativeTime: 0,                 value: 0.2),
                .init(relativeTime: duration * 0.25,   value: 1.0),
                .init(relativeTime: duration * 0.5,    value: 0.4),
                .init(relativeTime: duration * 0.75,   value: 1.0),
                .init(relativeTime: duration,          value: 0.2),
            ]
            curves = [CHHapticParameterCurve(parameterID: .hapticIntensityControl,
                                             controlPoints: cp,
                                             relativeTime: 0)]
        }
        return try CHHapticPattern(events: [event], parameterCurves: curves)
    }
    
    /// Серія коротких імпульсів (чим вище інтенсивність — тим більше і швидше)
    private func buildPulses() throws -> CHHapticPattern {
        let count = intensity.pulseCount
        let interval = intensity.pulseInterval
        let events: [CHHapticEvent] = (0..<count).map { i in
            CHHapticEvent(
                eventType: .hapticTransient,
                parameters: [
                    CHHapticEventParameter(parameterID: .hapticIntensity, value: intensity.amp),
                    CHHapticEventParameter(parameterID: .hapticSharpness, value: intensity.sharp)
                ],
                relativeTime: TimeInterval(i) * interval
            )
        }
        return try CHHapticPattern(events: events, parameters: [])
    }
    
    /// «Серцебиття»: тук-тук + невеликий відпочинок
    private func buildHeartbeat() throws -> CHHapticPattern {
        let amp = intensity.amp
        let sharp = intensity.sharp
        
        let beat1 = CHHapticEvent(eventType: .hapticTransient,
                                  parameters: [
                                    CHHapticEventParameter(parameterID: .hapticIntensity, value: amp * 0.8),
                                    CHHapticEventParameter(parameterID: .hapticSharpness, value: sharp * 0.8)
                                  ],
                                  relativeTime: 0)
        let beat2 = CHHapticEvent(eventType: .hapticTransient,
                                  parameters: [
                                    CHHapticEventParameter(parameterID: .hapticIntensity, value: min(1.0, amp * 1.1)),
                                    CHHapticEventParameter(parameterID: .hapticSharpness, value: min(1.0, sharp * 1.1))
                                  ],
                                  relativeTime: 0.12)
        let rest = CHHapticEvent(eventType: .hapticContinuous,
                                 parameters: [
                                    CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.0001),
                                    CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.0001)
                                 ],
                                 relativeTime: 0.20,
                                 duration: (intensity == .hard ? 0.4 : intensity == .medium ? 0.3 : 0.25))
        return try CHHapticPattern(events: [beat1, beat2, rest], parameters: [])
    }
    
    /// Плавний наростаючий/спадаючий безперервний сигнал
    private func buildRamp() throws -> CHHapticPattern {
        let duration: TimeInterval = 1.0 + (intensity == .hard ? 0.4 : (intensity == .medium ? 0.2 : 0.0))
        let event = CHHapticEvent(eventType: .hapticContinuous,
                                  parameters: [
                                    CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.1),
                                    CHHapticEventParameter(parameterID: .hapticSharpness, value: intensity.sharp)
                                  ],
                                  relativeTime: 0,
                                  duration: duration)
        let curve = CHHapticParameterCurve(parameterID: .hapticIntensityControl,
                                           controlPoints: [
                                            .init(relativeTime: 0, value: 0.2),
                                            .init(relativeTime: duration * 0.5, value: intensity.amp),
                                            .init(relativeTime: duration, value: max(0.05, intensity.amp * 0.4))
                                           ],
                                           relativeTime: 0)
        return try CHHapticPattern(events: [event], parameterCurves: [curve])
    }
    
    /// 2–3 «стуки» підряд
    private func buildKnock() throws -> CHHapticPattern {
        let events: [CHHapticEvent] = [
            (0.00, 1.00), (0.08, 0.85), (0.16, 0.75)
        ].map { t, scale in
            CHHapticEvent(eventType: .hapticTransient,
                          parameters: [
                            CHHapticEventParameter(parameterID: .hapticIntensity, value: min(1.0, intensity.amp * Float(scale))),
                            CHHapticEventParameter(parameterID: .hapticSharpness, value: intensity.sharp)
                          ],
                          relativeTime: t)
        }
        return try CHHapticPattern(events: events, parameters: [])
    }
}

// MARK: - Інтенсивність → числові параметри

extension IntensityLevel {
    var amp: Float {
        switch self { case .soft: 0.30; case .medium: 0.60; case .hard: 1.00 }
    }
    var sharp: Float {
        switch self { case .soft: 0.20; case .medium: 0.50; case .hard: 0.90 }
    }
    var waveDuration: TimeInterval {
        switch self { case .soft: 0.35; case .medium: 0.60; case .hard: 0.90 }
    }
    var pulseCount: Int {
        switch self { case .soft: 3; case .medium: 5; case .hard: 7 }
    }
    var pulseInterval: TimeInterval {
        switch self { case .soft: 0.18; case .medium: 0.14; case .hard: 0.10 }
    }
    
}
