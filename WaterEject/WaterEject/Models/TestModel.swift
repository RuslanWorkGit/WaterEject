//
//  TestModel.swift
//  WaterEject
//
//  Created by Ruslan Liulka on 08.08.2025.
//

enum TestMode: String, CaseIterable, Identifiable, Hashable {
    case stereo
    case bass
    case micro
    case vibro
    case noise


    var id: String { rawValue }
    
    var testName: String {
        switch self {
        case .stereo: return "Stereo"
        case .bass: return "Bass"
        case .micro: return "Micro"
        case .vibro: return "Vibro"
        case .noise: return "Noise"
        }
    }
    
    var imageName: String {
        switch self {
        case .stereo: return "Stereo"
        case .bass: return "Bass"
        case .micro: return "Micro"
        case .vibro: return "Bass"
        case .noise: return "Noise"
        }
    }
}
