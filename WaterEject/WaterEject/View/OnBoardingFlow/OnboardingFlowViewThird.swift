//
//  OnboardingFlowViewThird.swift
//  WaterEject
//
//  Created by Ruslan Liulka on 27.09.2025.
//

import SwiftUI

struct OnboardingFlowViewThree: View {
    //@Binding var isActive: Bool  // Для Coordinator, щоб закривати flow
    @AppStorage("hasSeenOnboarding") var hasSeenOnboarding: Bool = false
    @AppStorage("onb_last_shown_ts") private var onbLastShownTS: Double = 0
    @State private var pickedDevice: OnboardDeviceModel? = nil
    @State private var currentStep: OnboardingStepThree = .device
    @EnvironmentObject var coordinator: AppCoordinator
    @Environment(\.dismiss) private var dismiss   // ← додай

    
    var body: some View {
        ZStack {
            Group {
                switch currentStep {
                case .device:
                    DeviceOnboardNew(
                    onDeviceSelect: { model in
                        pickedDevice = model            // ← зберегли вибір
                        currentStep = .start            // ← переходимо далі
                    },
                    action: { goToNextStep() }
                )
                    
                case .start:
                    StartOnboardView(
                        action: { goToNextStep() },
                        device: pickedDevice               // ← підставляємо у стартовий екран
                    )
                case .test: TestOnboardNew(action: { goToNextStep()})
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
        if let nextIndex = OnboardingStepThree.allCases.firstIndex(of: currentStep)?.advanced(by: 1),
           nextIndex < OnboardingStepThree.allCases.count {
            currentStep = OnboardingStepThree.allCases[nextIndex]
        }
    }
    
    func finishOnboarding() {
        Telemetry.shared.onboardingFinish()
        hasSeenOnboarding = true
        dismiss()
        coordinator.showMainTabbar()
        
    }
}
