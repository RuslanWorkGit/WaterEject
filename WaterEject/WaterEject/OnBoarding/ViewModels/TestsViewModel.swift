//
//  TestsViewModel.swift
//  WaterEject
//
//  Created by Ruslan Liulka on 07.08.2025.
//

import Foundation

class TestsViewModel: ObservableObject {
    @Published var checked: [String: Bool] = [
        "Stereo": false,
        "Bass": false,
        "Micro": false,
        "Vibro": false,
        "Noise": false
    ]
    
    func toggle(_ test: String) {
        checked[test]?.toggle()
        // Далі можна зробити аналітику, чи що треба
    }
}
