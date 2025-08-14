//
//  VibroModel.swift
//  WaterEject
//
//  Created by Ruslan Liulka on 12.08.2025.
//

enum VibroModel: String, CaseIterable, Identifiable, Hashable {
    case waves
    case heart
    case volcano
    case push



    var id: String { rawValue }
    
    var testName: String {
        switch self {
        case .waves: return "Waves"
        case .heart: return "Heart"
        case .volcano: return "Volcano"
        case .push: return "Push"
        }
    }
    
    var imageName: String {
        switch self {
        case .waves: return "water.waves"
        case .heart: return "waveform.path.ecg"
        case .volcano: return "dot.radiowaves.left.and.right"
        case .push: return "heat.waves"
        }
    }
}

// MARK: - Intensity model

enum IntensityLevel: String, CaseIterable, Identifiable {
    case soft, medium, hard
    var id: String { rawValue }

    var title: String {
        switch self {
        case .soft:   return "Soft"
        case .medium: return "Medium"
        case .hard:   return "Hard"
        }
    }
}

