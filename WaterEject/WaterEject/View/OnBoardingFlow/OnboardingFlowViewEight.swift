




import SwiftUI
import FirebaseAnalytics

struct OnboardingFlowViewEight: View {
    let someAction: () -> ()
    let controlFlowId: String?
    let assignment: OnboardingAssignment?

    private let flowId = "onboard_8_1_steps"
    private let onboardId = OnboardTag.v8.rawValue
    
    @AppStorage("hasSeenOnboarding") var hasSeenOnboarding = false
    //@AppStorage("onb_last_shown_ts") private var onbLastShownTS: Double = 0

    @State private var currentStep: OnboardingStepEight = .stepOne
    @State private var path: [OnboardingStepEight] = []
    @StateObject private var reviewsCarouselModel = ReviewsCarouselModel()
    
    @State private var topCardIndex: Int = 0
    @State private var colorIndex: Int = 0
    
    @State private var stepsVisited: [String] = []
    

    @EnvironmentObject var coordinator: AppCoordinator
    @Environment(\.dismiss) private var dismiss
    
    
    
    @State private var modesExpandedIndex: Int = 0

    init(
        someAction: @escaping () -> (),
        controlFlowId: String? = nil,
        assignment: OnboardingAssignment? = nil
    ) {
        self.someAction = someAction
        self.controlFlowId = controlFlowId
        self.assignment = assignment
    }
    
    
    private func appendStep(_ step: OnboardingStepEight) {
        let id = screenId(for: step)
        if stepsVisited.last != id { stepsVisited.append(id) }
    }
    
    @State private var paywallShown = false

    private func persist(tag: OnboardTag) {
        OnboardingSessionStore.shared.save(tag: tag, steps: stepsVisited, paywallShown: paywallShown)
        OnboardTag.saveAsLast(tag)
    }

    var body: some View {
        NavigationStack(path: $path) {
            screen(for: .stepOne)
                .navigationBarBackButtonHidden(true)
                .navigationDestination(for: OnboardingStepEight.self) { step in
                    screen(for: step)
                        .navigationBarBackButtonHidden(true)
                }
            .task {
                
                Telemetry.shared.funnelOnboardStart(onboardId: analyticsOnboardId)
                
                Telemetry.shared.onboardStarted(onboardId: analyticsOnboardId)
                
                Telemetry.shared.onbFlowStart(flowId: analyticsFlowId)
                logControlStart(currentStep)
                Telemetry.shared.onbScreenView(flowId: analyticsFlowId, screenId: screenId(for: currentStep))
                logControlStepView(currentStep)
                
                appendStep(currentStep)
            }
            .onChange(of: path) { newPath in
                currentStep = newPath.last ?? .stepOne
            }
        }
        .onAppear {
            Telemetry.shared.sceneDidBecomeActive(onboardId: analyticsOnboardId)
        }
    }

    // MARK: - Навігація
    private func goTo(_ step: OnboardingStepEight, forward: Bool) {
        guard step != currentStep else { return }
        logControlStepAction(currentStep, action: "continue")

        currentStep = step
        path.append(step)

        Telemetry.shared.onbScreenView(flowId: analyticsFlowId, screenId: screenId(for: step))
        logControlStepView(step)

        if step != .paywall {
            appendStep(step)
            persist(tag: .v8)
        } else {
            PaywallGate.shared.currentContext = .onboarding
        }
    }

    private func finishOnboarding() {
        logControlComplete(stepId: "paywall")
        Telemetry.shared.onboardingFinish()
        //hasSeenOnboarding = true
        someAction()
        //dismiss()
        coordinator.showMainTabbar()
    }
    

    // Виклики з дочірніх екранів
    private func goToNextStep() {
        if let idx = OnboardingStepEight.allCases.firstIndex(of: currentStep),
           idx + 1 < OnboardingStepEight.allCases.count {
            goTo(OnboardingStepEight.allCases[idx + 1], forward: true)
        }
    }
    
    // MARK: - Screen IDs для аналітики
    private func screenId(for step: OnboardingStepEight) -> String {
        
        switch step {
        case .stepOne:
            return "step_1"
        case .stepTwo:
            return "step_2"
        case .stepThree:
            return "step_3"
        case .stepFour:
            return "step_4"
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
        enriched["assigned_paywall_key"] = PaywallAB.shared.assignedOnboardingPaywallKey(for: .v8)
        if let assignment {
            enriched["experiment_id"] = assignment.experimentId
            enriched["bucket"] = assignment.bucket
            enriched["tier"] = assignment.tier
        }
        return enriched
    }

    private func logControlStepView(_ step: OnboardingStepEight) {
        guard shouldLogControlEvents else { return }
        let stepId = screenId(for: step)
        Analytics.logEvent("onboarding_step_view", parameters: controlParams([
            "flow_id": analyticsFlowId,
            "step_id": stepId,
            "variant": analyticsFlowId
        ]))
        Telemetry.shared.setActiveOnboarding(flowId: analyticsFlowId, stepId: stepId, screenId: stepId)
    }

    private func logControlStart(_ step: OnboardingStepEight) {
        guard shouldLogControlEvents else { return }
        Analytics.logEvent("onboarding_start", parameters: controlParams([
            "flow_id": analyticsFlowId,
            "step_id": screenId(for: step),
            "variant": analyticsFlowId
        ]))
    }

    private func logControlStepAction(_ step: OnboardingStepEight, action: String) {
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
    private func screen(for step: OnboardingStepEight, startAnimations: Bool = true, staticDisplay: Bool = false) -> some View {
        switch step {
        case .stepOne:
            //StartOnboardView(action: { goTo(.wallet, forward: true) }, startAnimations: startAnimations, staticDisplay: staticDisplay)
            
            WaterDropsView(index: 0, action: { goTo(.stepTwo, forward: true) })
            
            //OnboardFourthFirstView(action: { goTo(.paywall, forward: true) })
        case .stepTwo:
            BlueLinesView(index: 1, action: { goTo(.stepThree, forward: true) })
        case .stepThree:
//            MeetOneView(index: 2, action: { goTo(.stepFour, forward: true) }, expandedIndex: $modesExpandedIndex )
            FirstWelcomeView(action: { goTo(.stepFour, forward: true) }, textButton: "Continue")
                .environmentObject(reviewsCarouselModel)
        case .stepFour:
            MeetView(index: 3, action: { goTo(.paywall, forward: true) })
        
        case .paywall:
            
            PaywallAB.shared
                   .onboardingPaywallView(
                       for: .v8,                       
                       onFinish: finishOnboarding,
                       startDelay: 0.0,
                       stepsVisited: stepsVisited,
                       startAnimations: true,
                       onboardIdOverride: controlFlowId
                   )
                   .onAppear {
                       paywallShown = true
                       persist(tag: .v8)
                   }

//            PaywallFourView(
//                    onFinish: finishOnboarding,
//                    onboardId: onboardId,
//                    startDelay: slideDuration + 0.1,   // 0.55 s
//                    summaryTag: .v8,
//                    stepsVisited: stepsVisited
//                    
//                )
//            .onAppear {
//                    //Telemetry.shared.onbScreenView(flowId: flowId, screenId: "paywall")
//                    paywallShown = true        // <-- тут, а не вище
//                    persist(tag: .v8)      // якщо зберігаєш прогрес
//                
//            }
        }
    }

}
