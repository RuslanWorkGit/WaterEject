//
//  CleanerView.swift
//  WaterEject
//
//  Created by Ruslan Liulka on 24.07.2025.
//

import SwiftUI

struct CleanerView: View {
    @StateObject private var viewModel = CleanerViewModel()
    
    var body: some View {
        VStack(spacing: 30) {
            
            Button("Left") { viewModel.playLeft() }
                .buttonStyle(.borderedProminent)
            Button("Right") { viewModel.playRight() }
                .buttonStyle(.borderedProminent)
            Button("Both") { viewModel.playBoth() }
                .buttonStyle(.bordered)
            Button("Sweep (20Hz–20kHz)") {
                viewModel.playSweep()
            }
            .buttonStyle(.bordered)
            .foregroundColor(.orange)
            Button("Burst (1000Hz, 150ms)") { viewModel.playBurst() }
                .buttonStyle(.bordered)
                .foregroundColor(.red)
            Button("Burst + Sweep") { viewModel.playBurstAndSweep() }
                .buttonStyle(.bordered)
                .foregroundColor(.purple)
            Button("Low Freq Bursts (80Hz)") { viewModel.playLowFreqBursts() }
                .buttonStyle(.bordered)
                .foregroundColor(.blue)
            
            Button("Multi Vibration (50–2000Hz)") { viewModel.playMultiVibration() }
                .buttonStyle(.bordered)
                .foregroundColor(.green)
            
            Button("Custom Water Eject (30s)") { viewModel.playCustomWaterEjectSequence() }
                            .buttonStyle(.bordered)
                            .foregroundColor(.cyan)
        }
        .padding(40)
        .onDisappear {
            viewModel.stop()
        }
    }
}
