//////
//////  OnboardingFlowViewOne.swift
//////  WaterEject
//////
//////  Created by Ruslan Liulka on 26.09.2025.
//
//// OnboardingFlowViewOne.swift
//
//import SwiftUI
//
//struct OnboardingFlowViewOne: View {
//    @AppStorage("hasSeenOnboarding") var hasSeenOnboarding = false
//    @AppStorage("onb_last_shown_ts") private var onbLastShownTS: Double = 0
//    //@State private var currentStep: OnboardingStepOne = .start
//    @EnvironmentObject var coordinator: AppCoordinator
//    @Environment(\.dismiss) private var dismiss
//
//    @State private var currentStep: OnboardingStepOne = .start
//    @State private var prevStep: OnboardingStepOne? = nil          // ← старий екран (фон)
//    @State private var incomingStep: OnboardingStepOne? = nil      // ← новий екран (оверлей)
//    @State private var overlayX: CGFloat = 0                       // ← офсет оверлея
//    @State private var isAnimating = false
//    @State private var isForward = true
//    var body: some View {
////        ZStack {
////            // 1) Фон: м’який крос-фейд між бекграундами для кроків
//////            CrossfadeBackground(step: currentStep)
//////                .ignoresSafeArea()
////            
////            CrossfadeBackgroundOne(step: currentStep)
////
////            // 2) Контент кроків з анімаційним переходом
////
////            Group {
////                switch currentStep {
////                case .start:
////                    StartOnboardView(action: goToNextStep)
////                        .transition(stepTransition)
////
////                case .wallet:
////                    SaveOnboardNew(action: goToNextStep)
////                        .transition(stepTransition)
////                case .women:
////                    WomenOnboardView(action: goToNextStep)
////                        .transition(stepTransition)
////
////                case .paywall:
////                    
////                    withAnimation(.easeInOut(duration: 0.6)) {        // узгоджено з фоном
////                        PaywallThirdView(onFinish: finishOnboarding)
////                            .transition(stepTransition)
////                    }
////
////                }
////            }
////            // м’який перехід між екранами
////
////            
////        }
//        ZStack {
//                    // постійний фон під контентом
////                    CrossfadeBackgroundOne(step: currentStep)
//
//            background(for: currentStep)
//                            .ignoresSafeArea()
//            
//                    // контент екранів з однаковим transition
//                    switch currentStep {
//                    case .start:
//                        StartOnboardView(action: { goTo(.wallet, forward: true) })
//                            .transition(overlaySlideTransition)
//                            .zIndex(z(for: .start))
//
//                    case .wallet:
//                        SaveOnboardNew(action: { goTo(.women, forward: true) })
//                            .transition(overlaySlideTransition)
//                            .zIndex(z(for: .wallet))
//
//                    case .women:
//                        WomenOnboardView(action: { goTo(.paywall, forward: true) })
//                            .transition(overlaySlideTransition)
//                            .zIndex(z(for: .women))
//
//                    case .paywall:
//                        PaywallThirdView(onFinish: finishOnboarding)
//                            .transition(overlaySlideTransition)
//                            .zIndex(z(for: .paywall))
//                    }
//                }
//
////        .animation(.snappy(duration: 0.7), value: currentStep)
//        .animation(.interactiveSpring(response: 0.5, dampingFraction: 0.9), value: currentStep)
//        .task {
//            onbLastShownTS = Date().timeIntervalSince1970
//            Telemetry.shared.onboardingStart()
//        }
//    }
//    
//    private func goTo(_ step: OnboardingStepOne, forward: Bool) {
//            isForward = forward
//            withAnimation { currentStep = step }
//        }
//    
//    private func z(for step: OnboardingStepOne) -> Double {
//        let order = OnboardingStepOne.allCases
//        let idx = Double(order.firstIndex(of: step) ?? 0)
//        return isForward ? idx : -idx
//    }
//
//    // MARK: - Навігація
//    private func goToNextStep() {
//        if let i = OnboardingStepOne.allCases.firstIndex(of: currentStep),
//           i + 1 < OnboardingStepOne.allCases.count {
//            withAnimation(.easeInOut(duration: 0.6)) {           // ← Анімація ТІЛЬКИ тут
//                currentStep = OnboardingStepOne.allCases[i + 1]
//                       }
//            
//            if currentStep == .paywall {
//                            withAnimation(.easeInOut(duration: 0.6)) {           // ← Анімація ТІЛЬКИ тут
//                                currentStep = OnboardingStepOne.allCases[i + 1]
//                    }
//            }
//            
//            currentStep = OnboardingStepOne.allCases[i + 1]
//        }
//        
//
//    }
//
//    private func finishOnboarding() {
//        Telemetry.shared.onboardingFinish()
//        hasSeenOnboarding = true
//        dismiss()
//        coordinator.showMainTabbar()
//    }
//    
//    @ViewBuilder
//        private func background(for s: OnboardingStepOne) -> some View {
//            switch s {
//            case .start:
//                LinearGradient(colors: [Color(red: 94/255, green: 148/255, blue: 1),
//                                        Color(red: 56/255, green: 114/255, blue: 229/255)],
//                               startPoint: .top, endPoint: .bottom)
//            case .women, .wallet:
//                LinearGradient(colors: [.white,
//                                        Color(red: 201/255, green: 214/255, blue: 238/255)],
//                               startPoint: .top, endPoint: .bottom)
//            case .paywall:
//                Color.black
//            }
//        }
//}
//
///// Один шар фону з кросфейдом без ForEach
//private struct CrossfadeBackgroundOne: View {
//    let step: OnboardingStepOne
//
//    @ViewBuilder
//    private func bg(for s: OnboardingStepOne) -> some View {
//        switch s {
//        case .start:
//            LinearGradient(colors: [Color(red: 94/255, green: 148/255, blue: 1),
//                                    Color(red: 56/255, green: 114/255, blue: 229/255)],
//                           startPoint: .top, endPoint: .bottom)
//        case .women, .wallet:
//            LinearGradient(colors: [.white,
//                                    Color(red: 201/255, green: 214/255, blue: 238/255)],
//                           startPoint: .top, endPoint: .bottom)
//        case .paywall:
//            LinearGradient(colors: [.black, .black],
//                           startPoint: .top, endPoint: .bottom)
//        }
//    }
//
//    var body: some View {
//        bg(for: step)
//            .id(step)                                     // нова ідентичність — тригер для transition
//            //.transition(.opacity)                         // чистий кросфейд
//            //.animation(.easeInOut(duration: 2.6), value: step)
//            .ignoresSafeArea()
//            .compositingGroup()                           // інколи прибирає мерехтіння градієнтів
//    }
//}


import SwiftUI

struct OnboardingFlowViewOne: View {
    @AppStorage("hasSeenOnboarding") var hasSeenOnboarding = false
    @AppStorage("onb_last_shown_ts") private var onbLastShownTS: Double = 0

    @State private var currentStep: OnboardingStepOne = .start
    @State private var prevStep: OnboardingStepOne? = nil          // ← старий екран (фон)
    @State private var incomingStep: OnboardingStepOne? = nil      // ← новий екран (оверлей)
    @State private var overlayX: CGFloat = 0                       // ← офсет оверлея
    @State private var isAnimating = false
    @State private var isForward = true

    @EnvironmentObject var coordinator: AppCoordinator
    @Environment(\.dismiss) private var dismiss
    
    @State private var childAnimate = false
    private let slideDuration: Double = 0.5

    var body: some View {
        GeometryReader { geo in
            ZStack {
                // 1) Постійний фон по актуальному кроку
                background(for: currentStep).ignoresSafeArea()

                // 2) Старий екран — залишається на місці під час анімації
                if let p = prevStep {
                    screen(for: p, startAnimations: false, staticDisplay: true)
                        .id(p)
                        .frame(width: geo.size.width, height: geo.size.height)  // ✅ фіксуємо розмір
                        .zIndex(0)
                } else {
                    // якщо немає prevStep, показуємо поточний як базовий
                    screen(for: currentStep, startAnimations: true, staticDisplay: false)
                        .id(currentStep)
                        .frame(width: geo.size.width, height: geo.size.height)  // ✅
                        .zIndex(0)
                }

                // 3) Новий екран — в’їжджає зверху поверх старого
                if let inc = incomingStep {
                    screen(for: inc, startAnimations: childAnimate, staticDisplay: false)
                        .id(inc)
                        .frame(width: geo.size.width, height: geo.size.height)  // ✅
//                                        .ignoresSafeArea()
                        .offset(x: overlayX)         // ← тільки він рухається
                        .zIndex(1)
                        .onAppear {
                            // стартуємо за межами екрана справа/зліва
                            overlayX = (isForward ? 1 : -1) * geo.size.width
                            withAnimation(.easeInOut(duration: slideDuration)) {
                                            overlayX = 0
                                        }
                            DispatchQueue.main.asyncAfter(deadline: .now() + slideDuration) {
                                            childAnimate = true
                                        }
//                            withAnimation(.interactiveSpring(response: 0.5, dampingFraction: 0.9)) {
//                                overlayX = 0
//                            }
                        }
                }
            }
            .task {
                onbLastShownTS = Date().timeIntervalSince1970
                Telemetry.shared.onboardingStart()
            }
        }
    }

    // MARK: - Навігація
    private func goTo(_ step: OnboardingStepOne, forward: Bool) {
        guard !isAnimating, step != currentStep else { return }
        isAnimating = true
        isForward = forward
        childAnimate = false

        // фіксуємо старий і запускаємо оверлей
        prevStep = currentStep
        incomingStep = step

        // після короткої затримки (кінець пружини) — фіксуємо новий current і чистимо тимчасові
        //let delay = 0.7
        DispatchQueue.main.asyncAfter(deadline: .now() + slideDuration) {
            currentStep = step
            prevStep = nil
            incomingStep = nil
            isAnimating = false
        }
    }

    private func finishOnboarding() {
        Telemetry.shared.onboardingFinish()
        hasSeenOnboarding = true
        dismiss()
        coordinator.showMainTabbar()
    }

    // Виклики з дочірніх екранів
    private func goToNextStep() {
        if let idx = OnboardingStepOne.allCases.firstIndex(of: currentStep),
           idx + 1 < OnboardingStepOne.allCases.count {
            goTo(OnboardingStepOne.allCases[idx + 1], forward: true)
        }
    }

    // MARK: - Рендер екрана та фону
    @ViewBuilder
    private func screen(for step: OnboardingStepOne, startAnimations: Bool = true, staticDisplay: Bool = false) -> some View {
        switch step {
        case .start:
            StartOnboardView(action: { goTo(.wallet, forward: true) }, startAnimations: startAnimations, staticDisplay: staticDisplay)
            
        case .wallet:
            SaveOnboardNew(action: { goTo(.women, forward: true) }, startAnimations: startAnimations, staticDisplay: staticDisplay)
        case .women:
            WomenOnboardView(action: { goTo(.paywall, forward: true) }, startAnimations: startAnimations, staticDisplay: staticDisplay)
        case .paywall:
            PaywallThirdView(onFinish: finishOnboarding)
        }
    }

    @ViewBuilder
    private func background(for s: OnboardingStepOne) -> some View {
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
            Color.black
        }
    }
}
