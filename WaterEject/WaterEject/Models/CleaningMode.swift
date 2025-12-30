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


import Foundation

enum NewCleaningMode: String, CaseIterable, Identifiable {
    case waterRemoval
        case deepWaterClean
        case speakerCheck
        case intermediateCleaning
        case dustResidueClean
        case soundBalanceRestore
        case finalDeepClean



    var id: String { rawValue }
    
    static let plan: [NewCleaningMode] = [
            .waterRemoval,
            .deepWaterClean,
            .speakerCheck,
            .intermediateCleaning,
            .dustResidueClean,
            .soundBalanceRestore,
            .finalDeepClean
        ]

    
    static func mode(forDay day: Int) -> NewCleaningMode {
        let idx = max(0, min(day - 1, plan.count - 1))
        return plan[idx]
    }

    
    var modeName: String {
        switch self {
        case .waterRemoval: return "Water Removal"
        case .deepWaterClean:        return "Deep Water Clean"
                case .speakerCheck:          return "Speaker Check"
                case .intermediateCleaning:  return "Intermediate Cleaning"
                case .dustResidueClean:      return "Dust & Residue Clean"
                case .soundBalanceRestore:   return "Sound Balance Restore"
                case .finalDeepClean:        return "Final Deep Clean"
        }
    }

    var explainText: String {
        switch self {
        case .waterRemoval: return "Use basic sound frequencies to quickly remove visible water and dust from the speakers"
        case .deepWaterClean:
                   return "Targets water trapped deeper inside the speaker mesh. Helps prevent sound distortion caused by remaining moisture"
               case .speakerCheck:
                   return "Plays test tones to check clarity, balance, and volume. Detect issues early before they affect sound quality"
               case .intermediateCleaning:
                   return "Uses mid-range frequencies for gentle maintenance cleaning. Keeps speakers clear after initial water removal"
               case .dustResidueClean:
                   return "Helps loosen dust and small particles left after moisture dries. Improves airflow and overall sound clarity"
               case .soundBalanceRestore:
                   return "Stabilizes speaker output after multiple cleaning sessions. Designed to normalize sound performance"
               case .finalDeepClean:
                   return "Completes the cleaning cycle with a full multi-frequency pass. Leaves your speakers clean, dry, and ready for everyday use"

        }
    }
    
    var tags: [String] {
            switch self {
            case .waterRemoval:         return ["#Clean", "#LowFrequency"]
            case .deepWaterClean:       return ["#MultiFrequency", "#Expel"]
            case .speakerCheck:         return ["#HighFrequency", "#Test"]
            case .intermediateCleaning: return ["#Maintain"]
            case .dustResidueClean:     return ["#Clear", "#BalancedFrequency"]
            case .soundBalanceRestore:  return ["#Optimize", "#Balance"]
            case .finalDeepClean:       return ["#FullClean", "#Finish"]
            }
        }
    
    var durationSeconds: Int {
            switch self {
            case .waterRemoval:         return 60
            case .deepWaterClean:       return 83
            case .speakerCheck:         return 30
            case .intermediateCleaning: return 59
            case .dustResidueClean:     return 65
            case .soundBalanceRestore:  return 45
            case .finalDeepClean:       return 90
            }
        }
    
    var durationText: String { "\(durationSeconds) seconds" }
    
    var iconAssetName: String {
            switch self {
            case .waterRemoval:         return "NewWaterDrop"
            case .deepWaterClean:       return "IconDeepWater"       // TODO: заміни на свій asset
            case .speakerCheck:         return "IconSpeakerCheck"    // TODO
            case .intermediateCleaning: return "IconIntermediate"    // TODO
            case .dustResidueClean:     return "IconDust"            // TODO
            case .soundBalanceRestore:  return "IconBalance"         // TODO
            case .finalDeepClean:       return "IconFinal"           // TODO
            }
        }
    


}

