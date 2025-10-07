//
//  OnboardingFlowViewThird.swift
//  WaterEject
//
//  Created by Ruslan Liulka on 27.09.2025.
//

//import SwiftUI
//
//struct OnboardingFlowViewThree: View {
//    //@Binding var isActive: Bool  // Для Coordinator, щоб закривати flow
//    @AppStorage("hasSeenOnboarding") var hasSeenOnboarding: Bool = false
//    @AppStorage("onb_last_shown_ts") private var onbLastShownTS: Double = 0
//    @State private var pickedDevice: OnboardDeviceModel? = nil
//    @State private var currentStep: OnboardingStepThree = .device
//    @EnvironmentObject var coordinator: AppCoordinator
//    @Environment(\.dismiss) private var dismiss   // ← додай
//    
//
//    var body: some View {
//
//        
//        
//        ZStack {
//            
//            CrossfadeBackgroundThree(step: currentStep)
//                .ignoresSafeArea()
//            
//            switch currentStep {
//                
//            case .device:
//                DeviceOnboardNew(
//                    onDeviceSelect: { model in
//                        pickedDevice = model
//                        goToNextStep()
//                    },
//                    action: { }
//                )
//
//                
//            case .start:
//                StartOnboardView(
//                    action: { goToNextStep() },
//                    device: pickedDevice
//                )
//
//                
//            case .test:
//                TestOnboardNew(action: { goToNextStep() })
//
//                
//            case .women:
//                WomenOnboardView(action: { goToNextStep() })
//
//                
//            case .paywall:
//                
//                withAnimation(.easeInOut(duration: 0.6)) {        // узгоджено з фоном
//                    PaywallThirdView(onFinish: { finishOnboarding() })
//                        .transition(.asymmetric(
//                           insertion: .opacity,
//                           removal:   .opacity.combined(with: .move(edge: .leading))
//                        ))
//                }
//
//
//            }
//        }
//        
//        .task {
//            onbLastShownTS = Date().timeIntervalSince1970
//            Telemetry.shared.onboardingStart()
//            
//        }
//    }
//
//    
//    func goToNextStep() {
//        if let nextIndex = OnboardingStepThree.allCases.firstIndex(of: currentStep)?.advanced(by: 1),
//           nextIndex < OnboardingStepThree.allCases.count {
//
//
//            currentStep = OnboardingStepThree.allCases[nextIndex]
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
//
//
//private struct CrossfadeBackgroundThree: View {
//    let step: OnboardingStepThree
//
//    @ViewBuilder
//    private func bg(for s: OnboardingStepThree) -> some View {
//        switch s {
//        case .device:
//            LinearGradient(colors: [Color.white,
//                                    Color(red: 201/255, green: 214/255, blue: 238/255)],
//                           startPoint: .top, endPoint: .bottom)
//        case .start:
//            LinearGradient(colors: [Color(red: 94/255, green: 148/255, blue: 255/255),
//                                    Color(red: 56/255, green: 114/255, blue: 229/255)],
//                           startPoint: .top, endPoint: .bottom)
//        case .test:
//            LinearGradient(colors: [Color.white,
//                                    Color(red: 201/255, green: 214/255, blue: 238/255)],
//                           startPoint: .top, endPoint: .bottom)
//        case .women:
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
//        bg(for: step)
//            .id(step)                                     // нова ідентичність — тригер для transition
//            .transition(.opacity)                         // чистий кросфейд
//            .animation(.easeInOut(duration: 0.6), value: step)
//            .ignoresSafeArea()
//            .compositingGroup()                           // інколи прибирає мерехтіння градієнтів
//    }
//}
//


import SwiftUI

struct OnboardingFlowViewThree: View {
    @AppStorage("hasSeenOnboarding") var hasSeenOnboarding = false
    @AppStorage("onb_last_shown_ts") private var onbLastShownTS: Double = 0

    @State private var currentStep: OnboardingStepThree = .device
    @State private var prevStep: OnboardingStepThree? = nil          // ← старий екран (фон)
    @State private var incomingStep: OnboardingStepThree? = nil      // ← новий екран (оверлей)
    @State private var overlayX: CGFloat = 0                       // ← офсет оверлея
    @State private var pickedDevice: OnboardDeviceModel? = nil
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
    private func goTo(_ step: OnboardingStepThree, forward: Bool) {
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
        if let idx = OnboardingStepThree.allCases.firstIndex(of: currentStep),
           idx + 1 < OnboardingStepThree.allCases.count {
            goTo(OnboardingStepThree.allCases[idx + 1], forward: true)
        }
    }

    // MARK: - Рендер екрана та фону
    @ViewBuilder
    private func screen(for step: OnboardingStepThree, startAnimations: Bool = true, staticDisplay: Bool = false) -> some View {
        switch step {
        case .device:
            DeviceOnboardNew(
                               onDeviceSelect: { model in
                                   pickedDevice = model
                                   goTo(.start, forward: true)
//                                   goToNextStep()
                               },
                               action: { }
                           )
           
        case .start:
            StartOnboardView(action: { goTo(.test, forward: true) }, device: pickedDevice, startAnimations: startAnimations, staticDisplay: staticDisplay)
            
        case .test:
            TestOnboardNew(action: { goTo(.women, forward: true) }, startAnimations: startAnimations, staticDisplay: staticDisplay)
        case .women:
            WomenOnboardView(action: { goTo(.paywall, forward: true) }, startAnimations: startAnimations, staticDisplay: staticDisplay)
        case .paywall:
            PaywallThirdView(onFinish: finishOnboarding)
        }
    }

    @ViewBuilder
    private func background(for s: OnboardingStepThree) -> some View {
        switch s {
        case .start:
            LinearGradient(colors: [Color(red: 94/255, green: 148/255, blue: 1),
                                    Color(red: 56/255, green: 114/255, blue: 229/255)],
                           startPoint: .top, endPoint: .bottom)
        case .women, .test, .device:
            LinearGradient(colors: [.white,
                                    Color(red: 201/255, green: 214/255, blue: 238/255)],
                           startPoint: .top, endPoint: .bottom)
        case .paywall:
            Color.black
        }
    }
}
