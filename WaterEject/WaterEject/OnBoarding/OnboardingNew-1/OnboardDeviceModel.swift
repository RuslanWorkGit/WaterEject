//
//  OnboardDeviceModel.swift
//  WaterEject
//
//  Created by Ruslan Liulka on 27.09.2025.
//

import Foundation

enum OnboardDeviceModel: String, CaseIterable, Hashable, Identifiable {
    case iPhone
    case airPodsPro
    case airPods
    case airPodsMax
    case speakers

    var id: String { rawValue }

    /// Назва іконки/зображення (має відповідати імені у твоїх Assets)
    var imageName: String {
        switch self {
        case .iPhone: return "IphoneNewOnboard"
        case .airPodsPro: return "IphoneNewOnboard"
        case .airPods: return "AirpodsNewOnboard"
        case .airPodsMax: return "IphoneNewOnboard"
        case .speakers: return "SpeakerNewOnboard"
        }
    }
    
    /// Текстова назва для кнопки/картки
    var displayName: String {
        switch self {
        case .iPhone: return "iPhone"
        case .airPodsPro: return "AirPods Pro"
        case .airPods: return "AirPods"
        case .airPodsMax: return "AirPods Max"
        case .speakers: return "Speakers"
        }
    }
    
    var onboardImage: String {
        switch self {
        case .iPhone: return "OnboardIphone"
        case .airPodsPro: return "OnboardAirpodsPro"
        case .airPods: return "OnboardAirpods"
        case .airPodsMax: return "OnboardAirpodsMax"
        case .speakers: return "OnboardSpeaker"
        }
    }
    
    

}
