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
    @State private var currentStep: OnboardingStep = .hook
    @EnvironmentObject var coordinator: AppCoordinator
    
    var body: some View {
        ZStack {
            Group {
                switch currentStep {
                case .hook:     HookView()
                case .urgency:  UrgencyView()
                case .solution: SolutionView()
                //case .tests:    TestsView()
                case .paywall:  PaywallFirstView(onFinish: finishOnboarding)
                }
            }

            
            
            
            VStack {
                
                Spacer()
                if currentStep != .paywall {
                                            
                        Button {
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
                        .padding(.horizontal, 24)
                        .padding(.bottom, 26)
                    }
                    
                }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
            
            

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
 
    }
}

