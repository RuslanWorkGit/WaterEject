//
//  TestViewModel.swift
//  WaterEject
//
//  Created by Ruslan Liulka on 08.08.2025.
//


import Foundation

final class TestViewModel: ObservableObject {
    
    
    @Published var mode: TestMode = .stereo
    @Published var passedCount: Int = 0   // якщо рахуєш пройдені тести
    
    func goToNextStep() {
        if let i = TestMode.allCases.firstIndex(of: mode),
           i + 1 < TestMode.allCases.count {
            mode = TestMode.allCases[i + 1]
        }
    }
    
    
}
