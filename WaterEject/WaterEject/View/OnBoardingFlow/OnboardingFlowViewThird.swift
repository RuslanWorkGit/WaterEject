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
            
            CrossfadeBackgroundThree(step: currentStep)
                .ignoresSafeArea()
            
            switch currentStep {
                
            case .device:
                DeviceOnboardNew(
                    onDeviceSelect: { model in
                        pickedDevice = model
                        goToNextStep()
                    },
                    action: { }
                )

                
            case .start:
                StartOnboardView(
                    action: { goToNextStep() },
                    device: pickedDevice
                )

                
            case .test:
                TestOnboardNew(action: { goToNextStep() })

                
            case .women:
                WomenOnboardView(action: { goToNextStep() })

                
            case .paywall:
                PaywallThirdView(onFinish: { finishOnboarding() })

            }
        }
        
        .task {
            onbLastShownTS = Date().timeIntervalSince1970
            Telemetry.shared.onboardingStart()
            
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



private struct CrossfadeBackgroundThree: View {
    let step: OnboardingStepThree

    @ViewBuilder
    private func bg(for s: OnboardingStepThree) -> some View {
        switch s {
        case .device:
            LinearGradient(colors: [Color.white,
                                    Color(red: 201/255, green: 214/255, blue: 238/255)],
                           startPoint: .top, endPoint: .bottom)
        case .start:
            LinearGradient(colors: [Color(red: 94/255, green: 148/255, blue: 255/255),
                                    Color(red: 56/255, green: 114/255, blue: 229/255)],
                           startPoint: .top, endPoint: .bottom)
        case .test:
            LinearGradient(colors: [Color.white,
                                    Color(red: 201/255, green: 214/255, blue: 238/255)],
                           startPoint: .top, endPoint: .bottom)
        case .women:
            LinearGradient(colors: [Color.white,
                                    Color(red: 201/255, green: 214/255, blue: 238/255)],
                           startPoint: .top, endPoint: .bottom)
        case .paywall:
            LinearGradient(colors: [Color.black, Color.black],
                           startPoint: .top, endPoint: .bottom)
        }
    }

    var body: some View {
        bg(for: step)
            .id(step)                                     // нова ідентичність — тригер для transition
            .transition(.opacity)                         // чистий кросфейд
            .animation(.easeInOut(duration: 0.6), value: step)
            .ignoresSafeArea()
            .compositingGroup()                           // інколи прибирає мерехтіння градієнтів
    }
}
