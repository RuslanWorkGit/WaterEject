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
    @State private var timer: Timer? = nil
    @State private var start: String?
    @State private var countdown: Int = 25
    
    func startTimer() {
        stopTimer()
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            if self.countdown > 0 {
                self.countdown -= 1
            }
            if self.countdown == 0 {
                self.stopTimer()
                self.startCleaning = false
                self.countdown = 25
            }
        }
    }

    func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
}
