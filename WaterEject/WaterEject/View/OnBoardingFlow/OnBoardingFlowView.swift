//
//  OnBoardingFlowView.swift
//  WaterEject
//
//  Created by Ruslan Liulka on 06.08.2025.
//
import SwiftUI

struct OnboardingFlowView: View {
    @Binding var isActive: Bool  // Для Coordinator, щоб закривати flow
    @AppStorage("hasSeenOnboarding") var hasSeenOnboarding: Bool = false
    @State private var currentStep: OnboardingStep = .hook
    @EnvironmentObject var coordinator: AppCoordinator
    
    var body: some View {
        ZStack {
            
            switch currentStep {
            case .hook:     HookView()
            case .urgency:  UrgencyView()
            case .solution: SolutionView()
            case .tests:    TestsView()
            case .paywall:  PaywallView(onFinish: finishOnboarding)
            }
            
            Spacer()
            if currentStep != .paywall {
                Button("Continue") {
                    goToNextStep()
                }
                .buttonStyle(.borderedProminent)
                .padding(.bottom, 32)
            }
        }
        .transition(.slide)
        .animation(.easeInOut, value: currentStep)
    }
    
    func goToNextStep() {
        if let nextIndex = OnboardingStep.allCases.firstIndex(of: currentStep)?.advanced(by: 1),
           nextIndex < OnboardingStep.allCases.count {
            currentStep = OnboardingStep.allCases[nextIndex]
        }
    }
    
    func finishOnboarding() {
        hasSeenOnboarding = true
        coordinator.showMainTabbar()
        isActive = false // Coordinator прибирає onboarding і показує HomeView
    }
}

