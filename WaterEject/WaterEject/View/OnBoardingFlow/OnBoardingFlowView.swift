//
//  OnBoardingFlowView.swift
//  WaterEject
//
//  Created by Ruslan Liulka on 06.08.2025.
//

import SwiftUI

struct OnboardingFlowView: View {
    
    @EnvironmentObject var coordinator: AppCoordinator
    @AppStorage("hasSeenOnboarding") var hasSeenOnboarding: Bool = false

    var body: some View {
        TabView {
            OnboardingPageView(title: "Welcome to TaskManager")
            OnboardingPageView(title: "Create tasks easily")
            OnboardingPageView(title: "Assign them to teammates", onDone: completeOnboarding)
        }
        .tabViewStyle(PageTabViewStyle())
    }

    func completeOnboarding() {
        hasSeenOnboarding = true
        coordinator.showMainTabbar()
    }
}
