//
//  VibroViewModel.swift
//  WaterEject
//
//  Created by Ruslan Liulka on 12.08.2025.
//

import Foundation

final class VibroViewModel: ObservableObject {
    
    @Published var vibroMode: VibroModel = .waves
    @Published var intensity: IntensityLevel = .medium
}
