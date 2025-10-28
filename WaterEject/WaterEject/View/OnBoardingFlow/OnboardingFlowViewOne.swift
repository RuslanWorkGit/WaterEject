//
//  OnboardingFlowViewOne.swift
//  WaterEject
//
//  Created by Ruslan Liulka on 26.09.2025.
//

import SwiftUI

struct OnboardingFlowViewOne: View {
    private let flowId = "onboard_3_1_steps"
    private let onboardId = OnboardTag.v31.rawValue
    
    @AppStorage("hasSeenOnboarding") var hasSeenOnboarding = false
    //@AppStorage("onb_last_shown_ts") private var onbLastShownTS: Double = 0

    @State private var currentStep: OnboardingStepOne = .start
    @State private var prevStep: OnboardingStepOne? = nil          // ← старий екран (фон)
    @State private var incomingStep: OnboardingStepOne? = nil      // ← новий екран (оверлей)
    @State private var overlayX: CGFloat = 0                       // ← офсет оверлея
    @State private var isAnimating = false
    @State private var isForward = true
    
    @State private var stepsVisited: [String] = []
    

    @EnvironmentObject var coordinator: AppCoordinator
    @Environment(\.dismiss) private var dismiss
    
    
    
    @State private var childAnimate = false
    private let slideDuration: Double = 0.5
    
    
    private func appendStep(_ step: OnboardingStepOne) {
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
                //onbLastShownTS = Date().timeIntervalSince1970
                //Telemetry.shared.onboardFlowMark(.v31)
                Telemetry.shared.onbFlowStart(flowId: flowId)
                Telemetry.shared.onbScreenView(flowId: flowId, screenId: screenId(for: currentStep))
                
                appendStep(currentStep)
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
            if step != .paywall {
//                       incomingStep = nil
                Telemetry.shared.onbScreenView(flowId: flowId, screenId: screenId(for: step))
                
                appendStep(step)
                persist(tag: .v31)
            } else {
                PaywallGate.shared.currentContext = .onboarding
            }

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
        if let idx = OnboardingStepOne.allCases.firstIndex(of: currentStep),
           idx + 1 < OnboardingStepOne.allCases.count {
            goTo(OnboardingStepOne.allCases[idx + 1], forward: true)
        }
    }
    
    // MARK: - Screen IDs для аналітики
    private func screenId(for step: OnboardingStepOne) -> String {
        switch step {
        case .start:  return "step_1"
        case .wallet: return "step_2"
        case .women:  return "step_3"
        case .paywall:return "paywall"
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

            PaywallThirdView(
                    onFinish: finishOnboarding,
                    onboardId: onboardId,
                    startDelay: slideDuration + 0.00,   // 0.55 s
                    summaryTag: .v31,
                    stepsVisited: stepsVisited
                    
                )
            .onAppear {
                    Telemetry.shared.onbScreenView(flowId: flowId, screenId: "paywall")
                    paywallShown = true        // <-- тут, а не вище
                    persist(tag: .v31)      // якщо зберігаєш прогрес
                
            }
        }
    }

}
