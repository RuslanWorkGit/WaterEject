//
//  RootView.swift
//  WaterEject
//
//  Created by Ruslan Liulka on 06.08.2025.
//

import SwiftUI

struct RootView: View {
    @AppStorage("hasSeenOnboarding") var hasSeenOnboarding: Bool = false
    @EnvironmentObject var coordinator: AppCoordinator

    var body: some View {
        switch coordinator.currentScreen {
        case .paywall:
            // PaywallFirstView() — якщо хочеш прямий перехід, але зазвичай онбординг веде до paywall
            EmptyView()
        case .onboarding:
            OnboardingFlowView()
        case .mainTabbar:
            TabBarView()
        }
    }
}
