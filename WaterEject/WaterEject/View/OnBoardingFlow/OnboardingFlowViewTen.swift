//
//  OnboardingFlowViewTen.swift
//  WaterEject
//
//  Created by Ruslan Liulka on 08.12.2025.
//

import SwiftUI
import FirebaseAnalytics

struct OnboardingFlowViewTen: View {
    let controlFlowId: String?
    let assignment: OnboardingAssignment?

    private let flowId = "onboard_10_1_steps"
    private let onboardId = OnboardTag.v10.rawValue
    
    @AppStorage("hasSeenOnboarding") var hasSeenOnboarding = false
    //@AppStorage("onb_last_shown_ts") private var onbLastShownTS: Double = 0

    @State private var currentStep: OnboardingStepTen = .stepOne
    @State private var prevStep: OnboardingStepTen? = nil          // ← старий екран (фон)
    @State private var incomingStep: OnboardingStepTen? = nil      // ← новий екран (оверлей)
    @State private var overlayX: CGFloat = 0                       // ← офсет оверлея
    @State private var isAnimating = false
    @State private var isForward = true
    
    @State private var stepsVisited: [String] = []
    

    @EnvironmentObject var coordinator: AppCoordinator
    @Environment(\.dismiss) private var dismiss
    
    @StateObject private var reviewsCarouselModel = ReviewsCarouselModel()
    
    @State private var childAnimate = false
    private let slideDuration: Double = 0.5

    init(controlFlowId: String? = nil, assignment: OnboardingAssignment? = nil) {
        self.controlFlowId = controlFlowId
        self.assignment = assignment
    }
    
    
    private func appendStep(_ step: OnboardingStepTen) {
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
                
                Telemetry.shared.funnelOnboardStart(onboardId: analyticsOnboardId)
                
                Telemetry.shared.onboardStarted(onboardId: analyticsOnboardId)
                
                Telemetry.shared.onbFlowStart(flowId: analyticsFlowId)
                logControlStart(currentStep)
                Telemetry.shared.onbScreenView(flowId: analyticsFlowId, screenId: screenId(for: currentStep))
                logControlStepView(currentStep)
                
                appendStep(currentStep)
            }
        }
        .onAppear {
            Telemetry.shared.sceneDidBecomeActive(onboardId: analyticsOnboardId)
        }
    }

    // MARK: - Навігація
    private func goTo(_ step: OnboardingStepTen, forward: Bool) {
        guard !isAnimating, step != currentStep else { return }
        logControlStepAction(currentStep, action: "continue")
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
            
            Telemetry.shared.onbScreenView(flowId: analyticsFlowId, screenId: screenId(for: step))
            logControlStepView(step)
            
            if step != .paywall {
//                       incomingStep = nil
                // Telemetry.shared.onbScreenView(flowId: flowId, screenId: screenId(for: step))
                
                appendStep(step)
                persist(tag: .v10)
            } else {
                PaywallGate.shared.currentContext = .onboarding
            }

        }
    }

    private func finishOnboarding() {
        logControlComplete(stepId: "paywall")
        Telemetry.shared.onboardingFinish()
        //hasSeenOnboarding = true
        dismiss()
        coordinator.showMainTabbar()
    }
    

    // Виклики з дочірніх екранів
    private func goToNextStep() {
        if let idx = OnboardingStepTen.allCases.firstIndex(of: currentStep),
           idx + 1 < OnboardingStepTen.allCases.count {
            goTo(OnboardingStepTen.allCases[idx + 1], forward: true)
        }
    }
    
    // MARK: - Screen IDs для аналітики
    private func screenId(for step: OnboardingStepTen) -> String {
        
        switch step {
        case .stepOne:
            return "step_1"
        case .stepTwo:
            return "step_2"
        case .stepThree:
            return "step_3"
        case .paywall:
            return "paywall"
        }

    }

    private var analyticsFlowId: String {
        controlFlowId ?? flowId
    }

    private var analyticsOnboardId: String {
        controlFlowId ?? onboardId
    }

    private var shouldLogControlEvents: Bool {
        controlFlowId != nil || assignment != nil
    }

    private func controlParams(_ params: [String: Any]) -> [String: Any] {
        var enriched = params
        if let assignment {
            enriched["experiment_id"] = assignment.experimentId
            enriched["bucket"] = assignment.bucket
            enriched["tier"] = assignment.tier
        }
        return enriched
    }

    private func logControlStart(_ step: OnboardingStepTen) {
        guard shouldLogControlEvents else { return }
        Analytics.logEvent("onboarding_start", parameters: controlParams([
            "flow_id": analyticsFlowId,
            "step_id": screenId(for: step),
            "variant": analyticsFlowId
        ]))
    }

    private func logControlStepView(_ step: OnboardingStepTen) {
        guard shouldLogControlEvents else { return }
        let stepId = screenId(for: step)
        Analytics.logEvent("onboarding_step_view", parameters: controlParams([
            "flow_id": analyticsFlowId,
            "step_id": stepId,
            "variant": analyticsFlowId
        ]))
        Telemetry.shared.setActiveOnboarding(flowId: analyticsFlowId, stepId: stepId, screenId: stepId)
    }

    private func logControlStepAction(_ step: OnboardingStepTen, action: String) {
        guard shouldLogControlEvents else { return }
        Analytics.logEvent("onboarding_step_action", parameters: controlParams([
            "flow_id": analyticsFlowId,
            "step_id": screenId(for: step),
            "action": action,
            "variant": analyticsFlowId
        ]))
    }

    private func logControlComplete(stepId: String) {
        guard shouldLogControlEvents else { return }
        Analytics.logEvent("onboarding_complete", parameters: controlParams([
            "flow_id": analyticsFlowId,
            "step_id": stepId,
            "variant": analyticsFlowId
        ]))
    }

    // MARK: - Рендер екрана та фону
    @ViewBuilder
    private func screen(for step: OnboardingStepTen, startAnimations: Bool = true, staticDisplay: Bool = false) -> some View {
        switch step {
        case .stepOne:
            SecondWomenView(action: { goTo(.stepTwo, forward: true) }, textButton: "Continue")
            
        case .stepTwo:


            FirstWelcomeView(action: { goTo(.stepThree, forward: true) }, textButton: "Continue")
                .environmentObject(reviewsCarouselModel)
        case .stepThree:
            ThirdWaveView(action: { goTo(.paywall, forward: true) }, textButton: "Continue")

        case .paywall:
            
//            PaywallAB.shared
//                   .onboardingPaywallView(
//                       for: .v41,                       // тег онборду (Onbord_v_3.3)
//                       onFinish: finishOnboarding,
//                       startDelay: slideDuration + 0.0,
//                       stepsVisited: stepsVisited
//                   )
//                   .onAppear {
//                       paywallShown = true
//                       persist(tag: .v41)
//                   }
            
            PaywallAB.shared
                   .onboardingPaywallView(
                       for: .v10,                      
                       onFinish: finishOnboarding,
                       startDelay: slideDuration + 0.0,
                       stepsVisited: stepsVisited,
                       onboardIdOverride: controlFlowId
                   )
                   .onAppear {
                       paywallShown = true
                       persist(tag: .v10)
                   }
            
//            PaywallFiveView(
//                    onFinish: finishOnboarding,
//                    onboardId: onboardId,
//                    startDelay: slideDuration + 0.1,   // 0.55 s
//                    summaryTag: .v10,
//                    stepsVisited: stepsVisited,
//                    startAnimations: startAnimations
//
//                )
//
//            .onAppear {
//                    //Telemetry.shared.onbScreenView(flowId: flowId, screenId: "paywall")
//                    paywallShown = true        // <-- тут, а не вище
//                    persist(tag: .v10)      // якщо зберігаєш прогрес
//
//            }
        }
    }

}
