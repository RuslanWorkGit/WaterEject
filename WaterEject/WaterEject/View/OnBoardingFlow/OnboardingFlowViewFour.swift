//
//  OnboardingFlowViewFour.swift
//  WaterEject
//
//  Created by Ruslan Liulka on 06.11.2025.
//

//
//  OnboardingFlowViewOne.swift
//  WaterEject
//
//  Created by Ruslan Liulka on 26.09.2025.
//

import SwiftUI

struct OnboardingFlowViewFour: View {
    private let flowId = "onboard_4_steps"
    private let onboardId = OnboardTag.v41.rawValue
    
    @AppStorage("hasSeenOnboarding") var hasSeenOnboarding = false
    //@AppStorage("onb_last_shown_ts") private var onbLastShownTS: Double = 0

    @State private var currentStep: OnboardingStepFour = .stepOne
    @State private var prevStep: OnboardingStepFour? = nil          // ← старий екран (фон)
    @State private var incomingStep: OnboardingStepFour? = nil      // ← новий екран (оверлей)
    @State private var overlayX: CGFloat = 0                       // ← офсет оверлея
    @State private var isAnimating = false
    @State private var isForward = true
    
    @State private var stepsVisited: [String] = []
    

    @EnvironmentObject var coordinator: AppCoordinator
    @Environment(\.dismiss) private var dismiss
    
    
    
    @State private var childAnimate = false
    private let slideDuration: Double = 0.5
    
    
    private func appendStep(_ step: OnboardingStepFour) {
        let id = screenId(for: step)
        if stepsVisited.last != id { stepsVisited.append(id) }
    }
    
    @State private var paywallShown = false

    private func persist(tag: OnboardTag) {
        OnboardingSessionStore.shared.save(tag: tag, steps: stepsVisited, paywallShown: paywallShown)
        OnboardTag.saveAsLast(tag)
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
                //Telemetry.shared.onboardFlowMark(.v41)
                
                Telemetry.shared.funnelOnboardStart(onboardId: onboardId)
                
                Telemetry.shared.onboardStarted(onboardId: onboardId)
                
                Telemetry.shared.onbFlowStart(flowId: flowId)
                Telemetry.shared.onbScreenView(flowId: flowId, screenId: screenId(for: currentStep))
                
                appendStep(currentStep)
            }
        }
        .onAppear {
            Telemetry.shared.sceneDidBecomeActive(onboardId: onboardId)
        }
    }

    // MARK: - Навігація
    private func goTo(_ step: OnboardingStepFour, forward: Bool) {
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
            
            Telemetry.shared.onbScreenView(flowId: flowId, screenId: screenId(for: step))
            
            if step != .paywall {
//                       incomingStep = nil
                // Telemetry.shared.onbScreenView(flowId: flowId, screenId: screenId(for: step))
                
                appendStep(step)
                persist(tag: .v41)
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
        if let idx = OnboardingStepFour.allCases.firstIndex(of: currentStep),
           idx + 1 < OnboardingStepFour.allCases.count {
            goTo(OnboardingStepFour.allCases[idx + 1], forward: true)
        }
    }
    
    // MARK: - Screen IDs для аналітики
    private func screenId(for step: OnboardingStepFour) -> String {
        
        switch step {
        case .stepOne:
            return "step_1"
        case .stepTwo:
            return "step_2"
        case .stepThree:
            return "step_3"
        case .stepFour:
            return "step_4"
        case .stepFive:
            return "step_5"
        case .stepSix:
            return "step_6"
        case .paywall:
            return "paywall"
        }

    }

    // MARK: - Рендер екрана та фону
    @ViewBuilder
    private func screen(for step: OnboardingStepFour, startAnimations: Bool = true, staticDisplay: Bool = false) -> some View {
        switch step {
        case .stepOne:
            OnboardFourthFirstView(action: { goTo(.stepTwo, forward: true) })
            
        case .stepTwo:

            OnboardFourthSecondView(action: { goTo(.stepThree, forward: true) })
        case .stepThree:
            OnboardFourthThirdView(action: { goTo(.stepFour, forward: true) })
        case .stepFour:

            OnboardFourthFourhtView(action: { goTo(.stepFive, forward: true) })
        case .stepFive:

            OnboardFourthFifthView(action: { goTo(.stepSix, forward: true) })
        case .stepSix:

            OnboardFourthSixthView(action: { goTo(.paywall, forward: true) })
        case .paywall:

//            PaywallThirdView(
//                    onFinish: finishOnboarding,
//                    onboardId: onboardId,
//                    startDelay: slideDuration + 0.1,   // 0.55 s
//                    summaryTag: .v41,
//                    stepsVisited: stepsVisited
//                    
//                )
            
            PaywallAB.shared
                   .onboardingPaywallView(
                       for: .v41,                       // тег онборду (Onbord_v_3.3)
                       onFinish: finishOnboarding,
                       startDelay: slideDuration + 0.0,
                       stepsVisited: stepsVisited
                   )
                   .onAppear {
                       paywallShown = true
                       persist(tag: .v41)
                   }
            
//            PaywallFourView(
//                    onFinish: finishOnboarding,
//                    onboardId: onboardId,
//                    startDelay: slideDuration + 0.1,   // 0.55 s
//                    summaryTag: .v41,
//                    stepsVisited: stepsVisited
//                    
//                )
//            
//            .onAppear {
//                    //Telemetry.shared.onbScreenView(flowId: flowId, screenId: "paywall")
//                    paywallShown = true        // <-- тут, а не вище
//                    persist(tag: .v41)      // якщо зберігаєш прогрес
//                
//            }
        }
    }

}
