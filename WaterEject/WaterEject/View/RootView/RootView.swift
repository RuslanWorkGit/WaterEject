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
        Group {
            switch coordinator.currentScreen {
            case .boot:
                // Можна поставити свій SplashView/лого/чорний фон
                Color.black.ignoresSafeArea()
            case .paywall:
                PaywallAB.shared
                    .assignedPaywallView(onFinish: {
                        coordinator.showMainTabbar()       // ✅ закрили пейвол → таббар
                    })
                    .onAppear { paywallGate.currentContext = .startViewAuto }
            case .onboarding:
                //            OnboardingFlowView()
                
                OnboardingAB.shared
                    .assignedOnboardingView() // ← ось тут
                    .onAppear {
                        // Якщо потрібен RC для свіжих часток:
                        OnboardingAB.shared.fetchRemoteConfig()
                    }
            case .mainTabbar:
                TabBarView()
            }
        }
        .onAppear {
            if let s = OnboardingSessionStore.shared.load() {
                        Telemetry.shared.onbFlowSummary(
                            onboard: s.tag,
                            steps: s.steps,
                            paywallId: s.paywallShown ? "paywall_v_3.0" : "none",
                            status: .abandon,
                            reason: "relaunch"
                        )
                        OnboardingSessionStore.shared.clear()
                    }
        }
        .animation(nil, value: coordinator.currentScreen)
    }
}
