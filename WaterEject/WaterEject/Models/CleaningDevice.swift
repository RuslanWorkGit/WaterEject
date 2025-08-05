//
//  CleaningDevice.swift
//  WaterEject
//
//  Created by Ruslan Liulka on 05.08.2025.
//
import Foundation

enum CleaningDevice: String, CaseIterable, Identifiable {
    case iPhone
    case airPodsPro
    case airPods
    case airPodsMax
    case speakers

    var id: String { rawValue }

    /// Назва іконки/зображення (має відповідати імені у твоїх Assets)
    var imageName: String {
        switch self {
        case .iPhone: return "devices"
        case .airPodsPro: return "airpodsPro"
        case .airPods: return "airpods"
        case .airPodsMax: return "airpodsMax"
        case .speakers: return "speaker"
        }
    }
    
    var bigImageName: String {
        switch self {
        case .iPhone: return "devicesBig"
        case .airPodsPro: return "airpodsProBig"
        case .airPods: return "airpodsBig"
        case .airPodsMax: return "airpodsMaxBig"
        case .speakers: return "speakerBig"
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

}
