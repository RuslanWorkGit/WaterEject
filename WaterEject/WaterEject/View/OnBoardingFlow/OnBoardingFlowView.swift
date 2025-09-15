//
//  OnBoardingFlowView.swift
//  WaterEject
//
//  Created by Ruslan Liulka on 06.08.2025.
//
import SwiftUI

struct OnboardingFlowView: View {
    //@Binding var isActive: Bool  // Для Coordinator, щоб закривати flow
    @AppStorage("hasSeenOnboarding") var hasSeenOnboarding: Bool = false
    @AppStorage("onb_last_shown_ts") private var onbLastShownTS: Double = 0
    @State private var currentStep: OnboardingStep = .hook
    @EnvironmentObject var coordinator: AppCoordinator
    
    var body: some View {
        ZStack {
            Group {
                switch currentStep {
                case .hook:     HookView()
                case .urgency:  UrgencyView()
                case .solution: SolutionView()
                case .tests:    TestsView()
                case .paywall:
                    PaywallAB.shared.assignedPaywallView(onFinish: finishOnboarding)
                }
            }
            
            
            
            
            VStack {
                
                Spacer()
                if currentStep != .paywall {
                    
                    Button {
                        Telemetry.shared.onboardingContinue(step: currentStep)
                        goToNextStep()
                    } label: {
                        Text("Continue")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(Color.white)
                        
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                        
                            .background(Color(red: 81 / 255, green: 132 / 255, blue: 234 / 255))
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                        
                    }
                    .padding(.horizontal, 36)
                    .padding(.bottom, 26)
                }
                
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
            
            
            
        }
        
        .transition(.slide)
        .animation(.easeInOut, value: currentStep)
        .task {
            onbLastShownTS = Date().timeIntervalSince1970
            Telemetry.shared.onboardingStart()
        }
        .onAppear {
            Telemetry.shared.onboardingScreenMarker(step: currentStep)
        }
        .onChange(of: currentStep) { oldStep, newStep in

            Telemetry.shared.onboardingScreenMarker(step: newStep)
            
            if newStep == .paywall {
                // джерело експожера пейволу — онбординг
                Telemetry.shared.paywallExposure(source: "onboarding")
            }
        }
        
    }
    
    func goToNextStep() {
        if let nextIndex = OnboardingStep.allCases.firstIndex(of: currentStep)?.advanced(by: 1),
           nextIndex < OnboardingStep.allCases.count {
            currentStep = OnboardingStep.allCases[nextIndex]
        }
    }
    
    func finishOnboarding() {
        Telemetry.shared.onboardingFinish()
        hasSeenOnboarding = true
        coordinator.showMainTabbar()
        
    }
}

enum OnboardingConfig {
    static var cooldownHours: Double {
        // приймаємо і Number, і String
        if let n = Bundle.main.object(forInfoDictionaryKey: "ONBOARDING_COOLDOWN_HOURS") as? NSNumber {
            return n.doubleValue
        }
        if let s = Bundle.main.object(forInfoDictionaryKey: "ONBOARDING_COOLDOWN_HOURS") as? String,
           let v = Double(s) { return v }
        return 24 // дефолт
    }
    static var cooldown: TimeInterval { cooldownHours * 3600 }
}

