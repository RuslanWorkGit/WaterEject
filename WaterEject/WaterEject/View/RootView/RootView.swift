//
//  RootView.swift
//  WaterEject
//
//  Created by Ruslan Liulka on 06.08.2025.
//

import SwiftUI

struct RootView: View {
    
    @EnvironmentObject var coordinator: AppCoordinator

    var body: some View {
        
        switch coordinator.currentScreen {
        case .paywall:
            PaywallView()
        case .onboarding:
            OnboardingFlowView()
        case .mainTabbar:
            HomeView()
        }
    }
}
