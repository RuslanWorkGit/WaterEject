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
//    var modeName: String {
//        switch self {
//        case .sonicPulse: return "🔥 SonicPulse™ Clean"
//        case .nanoShake: return "NanoShake™ Frequency Modulation"
//        case .dynamicEject: return "Dynamic Eject Curve v3.4"
//        case .hydroGuard: return "HydroGuard™ Pre-Sweep"
//
//        }
//    }
    
    var modeName: String {
        switch self {
        case .sonicPulse: return "Quick Clean / Default"
        case .nanoShake: return "Standard Clean / Most used"
        case .dynamicEject: return "Deep Clean"
        case .hydroGuard: return "Pre-Clean"

        }
    }
    
//    var explainText: String {
//        switch self {
//        case .sonicPulse: return "vibration cleaning (the most popular)"
//        case .nanoShake: return "standart"
//        case .dynamicEject: return "new firmware of the regime"
//        case .hydroGuard: return "speaker grid preparation"
//
//        }
//    }
    var explainText: String {
        switch self {
        case .sonicPulse: return "For everyday speaker cleaning"
        case .nanoShake: return "Balanced mode for regular use"
        case .dynamicEject: return "Strong sound pulses for heavy moisture"
        case .hydroGuard: return "Prepares the speaker before cleaning"

        }
    }
    


}

extension CleaningMode {
    var analyticsValue: String {
        switch self {
        case .sonicPulse:  return "sonic_pulse"
        case .nanoShake:   return "nano_shake"
        case .dynamicEject:return "dynamic_eject"
        case .hydroGuard:  return "hydro_guard"
        }

    }
}
