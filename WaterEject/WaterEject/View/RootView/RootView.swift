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
    @EnvironmentObject var paywallGate: PaywallGate

    var body: some View {
        switch coordinator.currentScreen {
        case .paywall:
            PaywallAB.shared
                .assignedPaywallView(onFinish: {
                    coordinator.showMainTabbar()       // ✅ закрили пейвол → таббар
                })
                .onAppear { paywallGate.currentContext = .startViewAuto }
        case .onboarding:
            OnboardingFlowView()
        case .mainTabbar:
            TabBarView()
        }
    }
}
