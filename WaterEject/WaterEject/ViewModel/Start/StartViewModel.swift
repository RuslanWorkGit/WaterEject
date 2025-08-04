//
//  StartViewModel.swift
//  WaterEject
//
//  Created by Ruslan Liulka on 04.08.2025.
//

import Foundation
import SwiftUI

final class StartViewModel: ObservableObject {
    
    @Published var startCleaning: Bool = false
    @Published var countdown: Int = 25
    
    private var timer: Timer?
    
    func startTimer() {
        stopTimer()
        countdown = 25
        startCleaning = true
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            if self.countdown > 0 {
                self.countdown -= 1
            }
            if self.countdown == 0 {
                self.stopTimer()
            }
        }
    }
    
    func stopTimer() {
        timer?.invalidate()
        timer = nil
        startCleaning = false
        countdown = 25
    }
}
