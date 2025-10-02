//
//  OnboardingFlowViewTwo.swift
//  WaterEject
//
//  Created by Ruslan Liulka on 27.09.2025.
//

import SwiftUI

// анімований модифікатор: прозорість + зсув по Y + блюр
struct BlurMoveModifier: ViewModifier, Animatable {
    var y: CGFloat
    var blur: CGFloat
    var opacity: Double

    var animatableData: AnimatablePair<CGFloat, AnimatablePair<CGFloat, Double>> {
        get { AnimatablePair(y, AnimatablePair(blur, opacity)) }
        set {
            y = newValue.first
            blur = newValue.second.first
            opacity = newValue.second.second
        }
    }

    func body(content: Content) -> some View {
        content
            .opacity(opacity)
            .offset(y: y)
            .blur(radius: blur)
    }
}

extension AnyTransition {
    static var blurLift: AnyTransition {
        .asymmetric(
            insertion: .modifier(
                active:   BlurMoveModifier(y: 24,  blur: 8, opacity: 0),
                identity: BlurMoveModifier(y: 0,   blur: 0, opacity: 1)
            ),
            removal: .modifier(
                active:   BlurMoveModifier(y: -16, blur: 6, opacity: 0),
                identity: BlurMoveModifier(y: 0,   blur: 0, opacity: 1)
            )
        )
    }
}


struct OnboardingFlowViewTwo: View {
    //@Binding var isActive: Bool  // Для Coordinator, щоб закривати flow
    @AppStorage("hasSeenOnboarding") var hasSeenOnboarding: Bool = false
    @AppStorage("onb_last_shown_ts") private var onbLastShownTS: Double = 0
    @State private var currentStep: OnboardingStepTwo = .start
    @EnvironmentObject var coordinator: AppCoordinator
    @Environment(\.dismiss) private var dismiss   // ← додай
    
//    private var depthTransition: AnyTransition {
//        .asymmetric(
//            insertion: .scale(scale: 0.96).combined(with: .opacity),
//            removal:   .scale(scale: 1.02).combined(with: .opacity)
//        )
//    }
//
//    
    var body: some View {
        ZStack {

            CrossfadeBackgroundTwo(step: currentStep)
            
            Group {
                switch currentStep {
                case .start:
                    StartOnboardView(action: { goToNextStep() })
//                        .transition(.blurLift)
                case .women:
                    WomenOnboardView(action: { goToNextStep() })
//                        .transition(.blurLift)
                case .wallet:
                    SaveOnboardNew(action: { goToNextStep() })
//                        .transition(.blurLift)
                case .paywall:
                    withAnimation(.easeInOut(duration: 0.6)) {        // узгоджено з фоном
                        PaywallThirdView(onFinish: { finishOnboarding() })
                            .transition(.asymmetric(
                               insertion: .opacity,
                               removal:   .opacity.combined(with: .move(edge: .leading))
                            ))
                    }

//                        .transition(.blurLift)
                }
            }
                
            
        }
//        .animation(.easeInOut(duration: 0.6), value: currentStep)
//                .animation(.snappy(duration: 0.4), value: currentStep)
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
        if let nextIndex = OnboardingStepTwo.allCases.firstIndex(of: currentStep)?.advanced(by: 1),
           nextIndex < OnboardingStepTwo.allCases.count {


            
            currentStep = OnboardingStepTwo.allCases[nextIndex]
            
        }
    }
    
    func finishOnboarding() {
        Telemetry.shared.onboardingFinish()
        hasSeenOnboarding = true
        dismiss()
        coordinator.showMainTabbar()
        
    }
}

/// Фон, що плавно міняється між кроками (градієнт/картинка — на твій смак)
//private struct CrossfadeBackgroundTwo: View {
//    let step: OnboardingStepTwo
//
//    @ViewBuilder
//    private func bg(for s: OnboardingStepTwo) -> some View {
//        switch s {
//        case .start:
//            LinearGradient(colors: [Color(red: 94/255, green: 148/255, blue: 255/255),
//                                    Color(red: 56/255, green: 114/255, blue: 229/255)],
//                           startPoint: .top, endPoint: .bottom)
//        case .women:
//            LinearGradient(colors: [Color.white,
//                                    Color(red: 201/255, green: 214/255, blue: 238/255)],
//                           startPoint: .top, endPoint: .bottom)
//        case .wallet:
//            LinearGradient(colors: [Color.white,
//                                    Color(red: 201/255, green: 214/255, blue: 238/255)],
//                           startPoint: .top, endPoint: .bottom)
//        case .paywall:
//            LinearGradient(colors: [Color.black, Color.black],
//                           startPoint: .top, endPoint: .bottom)
//        }
//    }
//
//    var body: some View {
//        ZStack {
//            ForEach(OnboardingStepTwo.allCases, id: \.self) { s in
//                bg(for: s)
//                    .opacity(s == step ? 1 : 0)
////                    .animation(.easeInOut(duration: 0.6), value: step)
//            }
//        }
//        .ignoresSafeArea()
//    }
//}

private struct CrossfadeBackgroundTwo: View {
    let step: OnboardingStepTwo

    @ViewBuilder
    private func bg(for s: OnboardingStepTwo) -> some View {
        switch s {
        case .start:
            LinearGradient(colors: [Color(red: 94/255, green: 148/255, blue: 1),
                                    Color(red: 56/255, green: 114/255, blue: 229/255)],
                           startPoint: .top, endPoint: .bottom)
        case .women, .wallet:
            LinearGradient(colors: [.white,
                                    Color(red: 201/255, green: 214/255, blue: 238/255)],
                           startPoint: .top, endPoint: .bottom)
        case .paywall:
            LinearGradient(colors: [.black, .black],
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

