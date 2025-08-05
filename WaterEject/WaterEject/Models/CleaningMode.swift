//
//  CleaningMode.swift
//  WaterEject
//
//  Created by Ruslan Liulka on 05.08.2025.
//
import Foundation

enum CleaningMode: String, CaseIterable, Identifiable {
    case sonicPulse
    case nanoShake
    case dynamicEject
    case hydroGuard


    var id: String { rawValue }

    /// Назва іконки/зображення (має відповідати імені у твоїх Assets)
    var modeName: String {
        switch self {
        case .sonicPulse: return "🔥 SonicPulse™ Clean"
        case .nanoShake: return "NanoShake™ Frequency Modulation"
        case .dynamicEject: return "Dynamic Eject Curve v3.4"
        case .hydroGuard: return "HydroGuard™ Pre-Sweep"
        }
    }
    
    var explainText: String {
        switch self {
        case .sonicPulse: return "vibration cleaning (the most popular)"
        case .nanoShake: return "standart"
        case .dynamicEject: return "new firmware of the regime"
        case .hydroGuard: return "speaker grid preparation"
        }
    }
    


}
