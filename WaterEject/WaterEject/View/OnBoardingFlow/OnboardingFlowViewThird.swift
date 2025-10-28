//
//  OnboardingFlowViewThird.swift
//  WaterEject
//
//  Created by Ruslan Liulka on 27.09.2025.
//


import SwiftUI

struct OnboardingFlowViewThree: View {
    private let flowId = "onboard_3_3_steps"
    private let onboardId = OnboardTag.v33.rawValue
    
    @AppStorage("hasSeenOnboarding") var hasSeenOnboarding = false
    //@AppStorage("onb_last_shown_ts") private var onbLastShownTS: Double = 0

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
    
    @State private var stepsVisited: [String] = []
    private func appendStep(_ step: OnboardingStepThree) {
        let id = screenId(for: step)
        if stepsVisited.last != id { stepsVisited.append(id) }
    }
    
    @State private var paywallShown = false

    private func persist(tag: OnboardTag) {
        OnboardingSessionStore.shared.save(tag: tag, steps: stepsVisited, paywallShown: paywallShown)
    }


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
                //onbLastShownTS = Date().timeIntervalSince1970
               // Telemetry.shared.onboardFlowMark(.v33)
                Telemetry.shared.onbFlowStart(flowId: flowId)
                Telemetry.shared.onbScreenView(flowId: flowId, screenId: screenId(for: currentStep))
                
                appendStep(currentStep)
            }
        }
    }
    
    // MARK: - Screen IDs для аналітики
    private func screenId(for step: OnboardingStepThree) -> String {
        switch step {
        case .device: return "step_1"
        case .start:  return "step_2"
        case .test: return "step_3"
        case .women:  return "step_4"
        case .paywall:return "paywall"
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
//            incomingStep = nil
//            isAnimating = false
            if step != .paywall {
                       incomingStep = nil
                
                Telemetry.shared.onbScreenView(flowId: flowId, screenId: screenId(for: step))
                    appendStep(step)
                persist(tag: .v33)
                   }
                   isAnimating = false
        }
    }

    private func finishOnboarding() {
        Telemetry.shared.onboardingFinish()
        //hasSeenOnboarding = true
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
//            PaywallThirdView(onFinish: finishOnboarding, onboardId: onboardId)

            PaywallThirdView(
                    onFinish: finishOnboarding,
                    onboardId: onboardId,
                    startDelay: slideDuration + 0.00,   // 0.55 s
                    summaryTag: .v33,                 // Onbord_v_3.3
                    stepsVisited: stepsVisited
                )
            .onAppear {
                    Telemetry.shared.onbScreenView(flowId: flowId, screenId: "paywall")
                    paywallShown = true        // <-- тут, а не вище
                    persist(tag: .v33)      // якщо зберігаєш прогрес
                
            }
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
