//
//  PaywallView.swift
//  WaterEject
//
//  Created by Ruslan Liulka on 06.08.2025.
//
import SwiftUI


struct PaywallView: View {
    let onFinish: () -> Void

    var body: some View {
        VStack {
            // ... Твій інтерфейс paywall ...

            Button("Continue") {
                // тут або після покупки підписки, або просто для демо:
                onFinish()
            }
        }
        .padding()
    }
}

