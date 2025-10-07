//
//  OnboardingFlowViewTwo.swift
//  WaterEject
//
//  Created by Ruslan Liulka on 27.09.2025.
//

//import SwiftUI
//
//// анімований модифікатор: прозорість + зсув по Y + блюр
//struct BlurMoveModifier: ViewModifier, Animatable {
//    var y: CGFloat
//    var blur: CGFloat
//    var opacity: Double
//
//    var animatableData: AnimatablePair<CGFloat, AnimatablePair<CGFloat, Double>> {
//        get { AnimatablePair(y, AnimatablePair(blur, opacity)) }
//        set {
//            y = newValue.first
//            blur = newValue.second.first
//            opacity = newValue.second.second
//        }
//    }
//
//    func body(content: Content) -> some View {
//        content
//            .opacity(opacity)
//            .offset(y: y)
//            .blur(radius: blur)
//    }
//}
//
//extension AnyTransition {
//    static var blurLift: AnyTransition {
//        .asymmetric(
//            insertion: .modifier(
//                active:   BlurMoveModifier(y: 24,  blur: 8, opacity: 0),
//                identity: BlurMoveModifier(y: 0,   blur: 0, opacity: 1)
//            ),
//            removal: .modifier(
//                active:   BlurMoveModifier(y: -16, blur: 6, opacity: 0),
//                identity: BlurMoveModifier(y: 0,   blur: 0, opacity: 1)
//            )
//        )
//    }
//}
//
//
//struct OnboardingFlowViewTwo: View {
//    //@Binding var isActive: Bool  // Для Coordinator, щоб закривати flow
//    @AppStorage("hasSeenOnboarding") var hasSeenOnboarding: Bool = false
//    @AppStorage("onb_last_shown_ts") private var onbLastShownTS: Double = 0
//    @State private var currentStep: OnboardingStepTwo = .start
//    @EnvironmentObject var coordinator: AppCoordinator
//    @Environment(\.dismiss) private var dismiss   // ← додай
//    
////    private var depthTransition: AnyTransition {
////        .asymmetric(
////            insertion: .scale(scale: 0.96).combined(with: .opacity),
////            removal:   .scale(scale: 1.02).combined(with: .opacity)
////        )
////    }
////
////    
//    var body: some View {
//        ZStack {
//
//            CrossfadeBackgroundTwo(step: currentStep)
//            
//            Group {
//                switch currentStep {
//                case .start:
//                    StartOnboardView(action: { goToNextStep() })
////                        .transition(.blurLift)
//                case .women:
//                    WomenOnboardView(action: { goToNextStep() })
////                        .transition(.blurLift)
//                case .wallet:
//                    SaveOnboardNew(action: { goToNextStep() })
////                        .transition(.blurLift)
//                case .paywall:
//                    withAnimation(.easeInOut(duration: 0.6)) {        // узгоджено з фоном
//                        PaywallThirdView(onFinish: { finishOnboarding() })
//                            .transition(.asymmetric(
//                               insertion: .opacity,
//                               removal:   .opacity.combined(with: .move(edge: .leading))
//                            ))
//                    }
//
////                        .transition(.blurLift)
//                }
//            }
//                
//            
//        }
////        .animation(.easeInOut(duration: 0.6), value: currentStep)
////                .animation(.snappy(duration: 0.4), value: currentStep)
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
//        if let nextIndex = OnboardingStepTwo.allCases.firstIndex(of: currentStep)?.advanced(by: 1),
//           nextIndex < OnboardingStepTwo.allCases.count {
//
//
//            
//            currentStep = OnboardingStepTwo.allCases[nextIndex]
//            
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
//
//private struct CrossfadeBackgroundTwo: View {
//    let step: OnboardingStepTwo
//
//    @ViewBuilder
//    private func bg(for s: OnboardingStepTwo) -> some View {
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
//            .transition(.opacity)                         // чистий кросфейд
//            .animation(.easeInOut(duration: 0.6), value: step)
//            .ignoresSafeArea()
//            .compositingGroup()                           // інколи прибирає мерехтіння градієнтів
//    }
//}


import SwiftUI

struct OnboardingFlowViewTwo: View {
    @AppStorage("hasSeenOnboarding") var hasSeenOnboarding = false
    @AppStorage("onb_last_shown_ts") private var onbLastShownTS: Double = 0

    @State private var currentStep: OnboardingStepTwo = .start
    @State private var prevStep: OnboardingStepTwo? = nil          // ← старий екран (фон)
    @State private var incomingStep: OnboardingStepTwo? = nil      // ← новий екран (оверлей)
    @State private var overlayX: CGFloat = 0                       // ← офсет оверлея
    @State private var isAnimating = false
    @State private var isForward = true

    @EnvironmentObject var coordinator: AppCoordinator
    @Environment(\.dismiss) private var dismiss
    
    @State private var childAnimate = false
    private let slideDuration: Double = 0.6

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
//                                        .ignoresSafeArea()
                        .zIndex(0)
                } else {
                    // якщо немає prevStep, показуємо поточний як базовий
                    screen(for: currentStep, startAnimations: true, staticDisplay: false)
                        .id(currentStep)
                        .frame(width: geo.size.width, height: geo.size.height)  // ✅
//                                        .ignoresSafeArea()
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
    private func goTo(_ step: OnboardingStepTwo, forward: Bool) {
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
        if let idx = OnboardingStepTwo.allCases.firstIndex(of: currentStep),
           idx + 1 < OnboardingStepTwo.allCases.count {
            goTo(OnboardingStepTwo.allCases[idx + 1], forward: true)
        }
    }

    // MARK: - Рендер екрана та фону
    @ViewBuilder
    private func screen(for step: OnboardingStepTwo, startAnimations: Bool = true, staticDisplay: Bool = false) -> some View {
        switch step {
        case .start:
            StartOnboardView(action: { goTo(.women, forward: true) })
        case .women:
            WomenOnboardView(action: { goTo(.wallet, forward: true) })
        case .wallet:
            SaveOnboardNew(action: { goTo(.paywall, forward: true) }, startAnimations: startAnimations, staticDisplay: staticDisplay)
        case .paywall:
            PaywallThirdView(onFinish: finishOnboarding)
        }
    }

    @ViewBuilder
    private func background(for s: OnboardingStepTwo) -> some View {
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
