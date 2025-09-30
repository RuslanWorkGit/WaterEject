////
////  OnboardingFlowViewOne.swift
////  WaterEject
////
////  Created by Ruslan Liulka on 26.09.2025.
////
//
//import SwiftUI
//
//// 3D flip-ефект
//struct FlipEffect: ViewModifier, Animatable {
//    var angle: Double
//    var axis: (x: CGFloat, y: CGFloat, z: CGFloat) = (0, 1, 0)
//    var perspective: CGFloat = 0.6
//
//    var animatableData: Double {
//        get { angle }
//        set { angle = newValue }
//    }
//
//    func body(content: Content) -> some View {
//        content
//            .rotation3DEffect(.degrees(angle), axis: axis, perspective: perspective)
//            // коли “спина” — робимо невидимим
//            .opacity((angle > 90 || angle < -90) ? 0 : 1)
//    }
//}
//
//
//extension AnyTransition {
//    static var flipFromRight: AnyTransition {
//        .modifier(
//            active: FlipEffect(angle: -90, axis: (0, 1, 0)),
//            identity: FlipEffect(angle: 0,    axis: (0, 1, 0))
//        )
//    }
//    static var flipFromLeft: AnyTransition {
//        .modifier(
//            active: FlipEffect(angle: 90, axis: (0, 1, 0)),
//            identity: FlipEffect(angle: 0,  axis: (0, 1, 0))
//        )
//    }
//}
//
//
//struct OnboardingFlowViewOne: View {
//    //@Binding var isActive: Bool  // Для Coordinator, щоб закривати flow
//    @AppStorage("hasSeenOnboarding") var hasSeenOnboarding: Bool = false
//    @AppStorage("onb_last_shown_ts") private var onbLastShownTS: Double = 0
//    @State private var currentStep: OnboardingStepOne = .start
//    @EnvironmentObject var coordinator: AppCoordinator
//    @Environment(\.dismiss) private var dismiss   // ← додай
//    
//    @State private var isForward = true
//
//    private var flipTransition: AnyTransition {
//        isForward ? .flipFromRight : .flipFromLeft
//    }
//
//    
//    var body: some View {
//        ZStack {
//            Group {
//                switch currentStep {
//                case .start:
//                    StartOnboardView(action: { goToNextStep() })
//                        .transition(flipTransition)
//                case .wallet:
//                    SaveOnboardNew(action: { goToNextStep() })
//                        .transition(flipTransition)
//                case .women:
//                    WomenOnboardView(action: { goToNextStep() })
//                        .transition(flipTransition)
//                case .paywall:
//                    PaywallThirdView(onFinish: { finishOnboarding() })
//                        .transition(flipTransition)
//                }
//            }
//                
//            
//        }
//        
//        
//        .animation(.spring(response: 0.5, dampingFraction: 0.82), value: currentStep)
//        .task {
//            onbLastShownTS = Date().timeIntervalSince1970
//            Telemetry.shared.onboardingStart()
//        }
//        .onAppear {
//            //Telemetry.shared.onboardingScreenMarker(step: currentStep)
//        }
//        .onChange(of: currentStep) { oldStep, newStep in
//
//            //Telemetry.shared.onboardingScreenMarker(step: newStep)
//            
//            if newStep == .paywall {
//                // джерело експожера пейволу — онбординг
//                Telemetry.shared.paywallExposure(source: "onboarding")
//            }
//        }
//        
//    }
//    
//    func goToNextStep() {
//        isForward = true
//        if let nextIndex = OnboardingStepOne.allCases.firstIndex(of: currentStep)?.advanced(by: 1),
//           nextIndex < OnboardingStepOne.allCases.count {
//            currentStep = OnboardingStepOne.allCases[nextIndex]
//        }
//    }
//    
//    func finishOnboarding() {
//        Telemetry.shared.onboardingFinish()
//        hasSeenOnboarding = true
//        dismiss()
//        coordinator.showMainTabbar()
//        
//    }
//}

// OnboardingFlowViewOne.swift

import SwiftUI

struct OnboardingFlowViewOne: View {
    @AppStorage("hasSeenOnboarding") var hasSeenOnboarding = false
    @AppStorage("onb_last_shown_ts") private var onbLastShownTS: Double = 0
    @State private var currentStep: OnboardingStepOne = .start
    @EnvironmentObject var coordinator: AppCoordinator
    @Environment(\.dismiss) private var dismiss

    // ⬇︎ як на макеті: новий екран в'їжджає справа, старий — гасне
    private let contentTransition = AnyTransition
        .asymmetric(insertion: .move(edge: .trailing).combined(with: .opacity),
                    removal:   .move(edge: .leading))

    var body: some View {
        ZStack {
            // 1) Фон: м’який крос-фейд між бекграундами для кроків
//            CrossfadeBackground(step: currentStep)
//                .ignoresSafeArea()
            
            CrossfadeBackgroundOne(step: currentStep)

            // 2) Контент кроків з анімаційним переходом
            switch currentStep {
            case .start:
                StartOnboardView(action: goToNextStep)
                    .transition(contentTransition)

            case .wallet:
                SaveOnboardNew(action: goToNextStep)
                    .transition(contentTransition)

            case .women:
                WomenOnboardView(action: goToNextStep)
                    .transition(contentTransition)

            case .paywall:
                PaywallThirdView(onFinish: finishOnboarding)
                    .transition(contentTransition)
            }
        }
        // м’яка, “не різка” крива як на відео/скріншоті
        .animation(.easeInOut(duration: 0.8), value: currentStep)
        .task {
            onbLastShownTS = Date().timeIntervalSince1970
            Telemetry.shared.onboardingStart()
        }
    }

    // MARK: - Навігація
    private func goToNextStep() {
        if let i = OnboardingStepOne.allCases.firstIndex(of: currentStep),
           i + 1 < OnboardingStepOne.allCases.count {
            currentStep = OnboardingStepOne.allCases[i + 1]
        }
    }

    private func finishOnboarding() {
        Telemetry.shared.onboardingFinish()
        hasSeenOnboarding = true
        dismiss()
        coordinator.showMainTabbar()
    }
}

/// Фон, що плавно міняється між кроками (градієнт/картинка — на твій смак)
private struct CrossfadeBackgroundOne: View {
    let step: OnboardingStepOne

    @ViewBuilder
    private func bg(for s: OnboardingStepOne) -> some View {
        switch s {
        case .start:
            LinearGradient(colors: [Color(red: 94/255, green: 148/255, blue: 255/255),
                                    Color(red: 56/255, green: 114/255, blue: 229/255)],
                           startPoint: .top, endPoint: .bottom)
        case .women:
            LinearGradient(colors: [Color.white,
                                    Color(red: 201/255, green: 214/255, blue: 238/255)],
                           startPoint: .top, endPoint: .bottom)
        case .wallet:
            LinearGradient(colors: [Color.white,
                                    Color(red: 201/255, green: 214/255, blue: 238/255)],
                           startPoint: .top, endPoint: .bottom)
        case .paywall:
            LinearGradient(colors: [Color.black, Color.black],
                           startPoint: .top, endPoint: .bottom)
        }
    }

    var body: some View {
        ZStack {
            ForEach(OnboardingStepOne.allCases, id: \.self) { s in
                bg(for: s)
                    .opacity(s == step ? 1 : 0)
                    .animation(.easeInOut(duration: 0.6), value: step)
            }
        }
        .ignoresSafeArea()
    }
}


///// Плавний перехід фонів між кроками
//struct CrossfadeBackground<S: Hashable>: View {
//    let step: S
//
//    // Поверни View-фон для конкретного кроку (зображення або градієнт)
//    @ViewBuilder private func background(for step: OnboardingStepOne) -> some View {
//        switch step as? OnboardingStepOne {
//        case .some(.start):
//            // приклад: градієнт
//            LinearGradient(colors: [Color.white,
//                                    Color(red: 201/255, green: 214/255, blue: 238/255)],
//                           startPoint: .top, endPoint: .bottom)
//
//        case .some(.wallet):
//            LinearGradient(colors: [Color.white,
//                                    Color(red: 201/255, green: 214/255, blue: 238/255)],
//                           startPoint: .top, endPoint: .bottom)
//
//        case .some(.women):
//            LinearGradient(colors: [Color.white,
//                                    Color(red: 201/255, green: 214/255, blue: 238/255)],
//                           startPoint: .top, endPoint: .bottom)
//
//        case .some(.paywall):
//            LinearGradient(colors: [.black.opacity(0.9), .gray.opacity(0.6)],
//                           startPoint: .top, endPoint: .bottom)
//
//        default:
//            Color.black // запасний
//        }
//    }
//
//    var body: some View {
//        ZStack {
//            // Малюємо всі варіанти фонів, але видимий лише активний
//            ForEach(OnboardingStepOne.allCases, id: \.self) { st in
//                background(for: st)
//                    .opacity(st == step as! OnboardingStepOne ? 1 : 0)
//                    .animation(.easeInOut(duration: 0.6), value: step)
//            }
//        }
//    }
//}
