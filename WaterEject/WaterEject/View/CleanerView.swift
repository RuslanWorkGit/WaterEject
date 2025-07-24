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
            Text("Чищення навушників").font(.title2).padding()
            Button("Left") { viewModel.playLeft() }
                .buttonStyle(.borderedProminent)
            Button("Right") { viewModel.playRight() }
                .buttonStyle(.borderedProminent)
            Button("Both") { viewModel.playBoth() }
                .buttonStyle(.bordered)
        }
        .padding(40)
        .onDisappear {
            viewModel.stop()
        }
    }
}
