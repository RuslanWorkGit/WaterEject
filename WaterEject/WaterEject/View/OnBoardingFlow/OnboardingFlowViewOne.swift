//
//  OnboardingFlowViewOne.swift
//  WaterEject
//
//  Created by Ruslan Liulka on 26.09.2025.
//

import SwiftUI

struct OnboardingFlowViewOne: View {
    //@Binding var isActive: Bool  // Для Coordinator, щоб закривати flow
    @AppStorage("hasSeenOnboarding") var hasSeenOnboarding: Bool = false
    @AppStorage("onb_last_shown_ts") private var onbLastShownTS: Double = 0
    @State private var currentStep: OnboardingStepOne = .start
    @EnvironmentObject var coordinator: AppCoordinator
    @Environment(\.dismiss) private var dismiss   // ← додай

    
    var body: some View {
        ZStack {
            Group {
                switch currentStep {
                case .start:     StartOnboardView(action: { goToNextStep() })
                case .wallet:  SaveOnboardNew(action: { goToNextStep() })
                case .women: WomenOnboardView(action: { goToNextStep() })
                case .paywall:
                    PaywallThirdView(onFinish: { finishOnboarding() })
                }
            }
                
            
        }
        
        .transition(.slide)
        .animation(.easeInOut, value: currentStep)
        .task {
            onbLastShownTS = Date().timeIntervalSince1970
            Telemetry.shared.onboardingStart()
        }
        .onAppear {
            //Telemetry.shared.onboardingScreenMarker(step: currentStep)
        }
        .onChange(of: currentStep) { oldStep, newStep in

            //Telemetry.shared.onboardingScreenMarker(step: newStep)
            
            if newStep == .paywall {
                // джерело експожера пейволу — онбординг
                Telemetry.shared.paywallExposure(source: "onboarding")
            }
        }
        
    }
    
    func goToNextStep() {
        if let nextIndex = OnboardingStepOne.allCases.firstIndex(of: currentStep)?.advanced(by: 1),
           nextIndex < OnboardingStepOne.allCases.count {
            currentStep = OnboardingStepOne.allCases[nextIndex]
        }
    }
    
    func finishOnboarding() {
        Telemetry.shared.onboardingFinish()
        hasSeenOnboarding = true
        dismiss()
        coordinator.showMainTabbar()
        
    }
}
