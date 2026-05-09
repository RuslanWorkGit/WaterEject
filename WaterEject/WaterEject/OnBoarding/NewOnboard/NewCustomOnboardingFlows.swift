//
//  NewCustomOnboardingFlows.swift
//  WaterEject
//
//  Created by OpenAI on 07.05.2026.
//

import SwiftUI
import FirebaseAnalytics
import FirebaseRemoteConfig
import RevenueCat

struct NewFirstBlackAnnualOnboardingFlowView: View {
    let flowKey: String
    let assignment: OnboardingAssignment?
    let onFinish: (() -> Void)?

    init(flowKey: String = "new_onb_1", assignment: OnboardingAssignment? = nil, onFinish: (() -> Void)? = nil) {
        self.flowKey = flowKey
        self.assignment = assignment
        self.onFinish = onFinish
    }

    var body: some View {
        NewCustomOnboardingFlowView(
            kind: .firstBlackAnnual,
            flowId: "new_onb_1",
            flowKey: flowKey,
            assignment: assignment,
            onFinish: onFinish
        )
    }
}

struct NewSecondBlackOnboardingFlowView: View {
    let flowKey: String
    let assignment: OnboardingAssignment?
    let onFinish: (() -> Void)?

    init(flowKey: String = "new_onb_2", assignment: OnboardingAssignment? = nil, onFinish: (() -> Void)? = nil) {
        self.flowKey = flowKey
        self.assignment = assignment
        self.onFinish = onFinish
    }

    var body: some View {
        NewCustomOnboardingFlowView(
            kind: .secondBlack,
            flowId: "new_onb_2",
            flowKey: flowKey,
            assignment: assignment,
            onFinish: onFinish
        )
    }
}

struct NewThirdBlackOnboardingFlowView: View {
    let flowKey: String
    let assignment: OnboardingAssignment?
    let onFinish: (() -> Void)?

    init(flowKey: String = "new_onb_3", assignment: OnboardingAssignment? = nil, onFinish: (() -> Void)? = nil) {
        self.flowKey = flowKey
        self.assignment = assignment
        self.onFinish = onFinish
    }

    var body: some View {
        NewCustomOnboardingFlowView(
            kind: .thirdBlack,
            flowId: "new_onb_3",
            flowKey: flowKey,
            assignment: assignment,
            onFinish: onFinish
        )
    }
}

struct NewFourthWhiteOnboardingFlowView: View {
    let flowKey: String
    let assignment: OnboardingAssignment?
    let onFinish: (() -> Void)?

    init(flowKey: String = "new_onb_4", assignment: OnboardingAssignment? = nil, onFinish: (() -> Void)? = nil) {
        self.flowKey = flowKey
        self.assignment = assignment
        self.onFinish = onFinish
    }

    var body: some View {
        NewCustomOnboardingFlowView(
            kind: .fourthWhite,
            flowId: "new_onb_4",
            flowKey: flowKey,
            assignment: assignment,
            onFinish: onFinish
        )
    }
}

struct NewFifthWhiteOnboardingFlowView: View {
    let flowKey: String
    let assignment: OnboardingAssignment?
    let onFinish: (() -> Void)?

    init(flowKey: String = "new_onb_5", assignment: OnboardingAssignment? = nil, onFinish: (() -> Void)? = nil) {
        self.flowKey = flowKey
        self.assignment = assignment
        self.onFinish = onFinish
    }

    var body: some View {
        NewCustomOnboardingFlowView(
            kind: .fifthWhite,
            flowId: "new_onb_5",
            flowKey: flowKey,
            assignment: assignment,
            onFinish: onFinish
        )
    }
}

struct NewSixthBlackOnboardingFlowView: View {
    let flowKey: String
    let assignment: OnboardingAssignment?
    let onFinish: (() -> Void)?

    init(flowKey: String = "new_onb_6", assignment: OnboardingAssignment? = nil, onFinish: (() -> Void)? = nil) {
        self.flowKey = flowKey
        self.assignment = assignment
        self.onFinish = onFinish
    }

    var body: some View {
        NewCustomOnboardingFlowView(
            kind: .sixthBlack,
            flowId: "new_onb_6",
            flowKey: flowKey,
            assignment: assignment,
            onFinish: onFinish
        )
    }
}

struct NewSeventhBlackOnboardingFlowView: View {
    let flowKey: String
    let assignment: OnboardingAssignment?
    let onFinish: (() -> Void)?

    init(flowKey: String = "new_onb_7", assignment: OnboardingAssignment? = nil, onFinish: (() -> Void)? = nil) {
        self.flowKey = flowKey
        self.assignment = assignment
        self.onFinish = onFinish
    }

    var body: some View {
        NewCustomOnboardingFlowView(
            kind: .seventhBlack,
            flowId: "new_onb_7",
            flowKey: flowKey,
            assignment: assignment,
            onFinish: onFinish
        )
    }
}

private struct NewCustomOnboardingFlowView: View {
    @EnvironmentObject private var coordinator: AppCoordinator

    let kind: NewCustomOnboardingFlowKind
    let flowId: String
    let flowKey: String
    let assignment: OnboardingAssignment?
    let onFinish: (() -> Void)?

    @State private var rootStep: NewCustomOnboardingStep?
    @State private var path: [NewCustomOnboardingStep] = []
    @State private var visibleSteps: [NewCustomOnboardingStep] = []
    @State private var stepsVisited: [String] = []
    @State private var loggedStepViews: Set<NewCustomOnboardingStep> = []
    @State private var didStart = false
    @State private var didFinish = false
    @State private var paywallShown = false
    @State private var onboardTag: OnboardTag = .new21
    @State private var onboardId = "new_onb_1"
    @State private var activeAssignment: OnboardingAssignment?

    var body: some View {
        Group {
            if let rootStep {
                NavigationStack(path: $path) {
                    screen(for: rootStep)
                        .navigationDestination(for: NewCustomOnboardingStep.self) { step in
                            screen(for: step)
                        }
                }
            } else {
                Color.black.ignoresSafeArea()
            }
        }
        .onAppear {
            startFlowIfNeeded()
        }
    }

    @ViewBuilder
    private func screen(for step: NewCustomOnboardingStep) -> some View {
        let index = pageIndex(for: step)

        Group {
            switch step {
            case .stepOne:
                switch kind {
                case .firstBlackAnnual:
                    OnboardingNewFirstViewOne(index: index, action: continueFromCurrentStep)
                case .secondBlack:
                    OnboardingNewSecondViewOne(index: index, action: continueFromCurrentStep)
                case .thirdBlack:
                    OnboardingNewThirdViewOne(index: index, action: continueFromCurrentStep)
                case .fourthWhite:
                    OnboardingNewFourthViewOne(index: index, action: continueFromCurrentStep)
                case .fifthWhite:
                    OnboardingNewFifthViewOne(index: index, action: continueFromCurrentStep)
                case .sixthBlack:
                    OnboardingNewSixthViewOne(index: index, action: continueFromCurrentStep)
                case .seventhBlack:
                    OnboardingNewSeventhViewOne(index: index, action: continueFromCurrentStep)
                }

            case .stepTwo:
                switch kind {
                case .firstBlackAnnual:
                    OnboardingNewFirstViewTwo(index: index, action: continueFromCurrentStep)
                case .secondBlack:
                    OnboardingNewSecondViewTwo(index: index, action: continueFromCurrentStep)
                case .thirdBlack:
                    OnboardingNewThirdViewTwo(index: index, action: continueFromCurrentStep)
                case .fourthWhite:
                    OnboardingNewFourthViewTwo(index: index, action: continueFromCurrentStep)
                case .fifthWhite:
                    OnboardingNewFifthViewTwo(index: index, action: continueFromCurrentStep)
                case .sixthBlack:
                    OnboardingNewSixthViewTwo(index: index, action: continueFromCurrentStep)
                case .seventhBlack:
                    OnboardingNewSeventhViewTwo(index: index, action: continueFromCurrentStep)
                }

            case .stepThree:
                switch kind {
                case .secondBlack:
                    OnboardingNewSecondViewThird(index: index, action: continueFromCurrentStep)
                case .fourthWhite:
                    OnboardingNewFourthViewThree(index: index, action: continueFromCurrentStep)
                case .fifthWhite:
                    OnboardingNewFifthViewThree(index: index, action: continueFromCurrentStep)
                case .firstBlackAnnual, .thirdBlack, .sixthBlack, .seventhBlack:
                    EmptyView()
                }

            case .paywall:
                paywallView(index: index)
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .navigationBar)
        .onAppear {
            trackStepAppear(step)
        }
    }

    @ViewBuilder
    private func paywallView(index: Int) -> some View {
        switch kind {
        case .firstBlackAnnual:
            NewBlackPaywallThird(
                index: index,
                action: finishFromPaywall,
                onboardId: onboardId,
                summaryTag: onboardTag,
                stepsVisited: stepsForPaywallSummary(),
                paywallId: kind.paywallId
            )

        case .secondBlack:
            NewBlackPaywallSecond(
                onFinish: finishFromPaywall,
                onboardId: onboardId,
                summaryTag: onboardTag,
                stepsVisited: stepsForPaywallSummary(),
                paywallId: kind.paywallId
            )

        case .thirdBlack:
            NewBlackPaywall(
                onFinish: finishFromPaywall,
                onboardId: onboardId,
                summaryTag: onboardTag,
                stepsVisited: stepsForPaywallSummary(),
                paywallId: kind.paywallId
            )

        case .fourthWhite, .fifthWhite:
            NewWhitePaywall(
                onFinish: finishFromPaywall,
                onboardId: onboardId,
                summaryTag: onboardTag,
                stepsVisited: stepsForPaywallSummary(),
                paywallId: kind.paywallId
            )

        case .sixthBlack:
            NewBlackPaywallFourth(
                index: index,
                action: finishFromPaywall,
                onboardId: onboardId,
                summaryTag: onboardTag,
                stepsVisited: stepsForPaywallSummary(),
                paywallId: kind.paywallId
            )

        case .seventhBlack:
            NewBlackPaywallFifth(
                index: index,
                action: finishFromPaywall,
                onboardId: onboardId,
                summaryTag: onboardTag,
                stepsVisited: stepsForPaywallSummary(),
                paywallId: kind.paywallId
            )
        }
    }

    private func startFlowIfNeeded() {
        guard !didStart else { return }

        let resolvedAssignment = assignment ?? OnboardingControlProvider.shared.currentAssignment(
            userId: OnboardingControlProvider.shared.stableUserId()
        )
        activeAssignment = resolvedAssignment
        onboardTag = .new21
        onboardId = flowId

        let configuredSteps = NewCustomOnboardingVisibleScreens.resolve(
            flowId: flowId,
            defaultSteps: kind.defaultSteps
        )
        visibleSteps = configuredSteps
        rootStep = configuredSteps.first

        Telemetry.shared.setPresentedOnboardingContext(
            brand: nil,
            onboardId: flowId,
            flowKey: flowKey,
            flowId: flowId,
            brandedFlow: nil,
            onbExperimentId: resolvedAssignment.experimentId,
            onbVariantId: flowId,
            onbBucket: String(resolvedAssignment.bucket)
        )
        Telemetry.shared.sceneDidBecomeActive(onboardId: flowId)
        Telemetry.shared.funnelOnboardStart(onboardId: flowId)
        Telemetry.shared.onboardStarted(onboardId: flowId)
        Telemetry.shared.setPresentedOnboardingContext(
            brand: nil,
            onboardId: flowId,
            flowKey: flowKey,
            flowId: flowId,
            brandedFlow: nil,
            onbExperimentId: resolvedAssignment.experimentId,
            onbVariantId: flowId,
            onbBucket: String(resolvedAssignment.bucket)
        )
        Telemetry.shared.onbFlowStart(flowId: flowId)
        OnboardTag.saveAsLast(.new21)

        didStart = true

        if let firstStep = configuredSteps.first {
            logOnboardingStart(step: firstStep)
            trackStepAppear(firstStep)
        } else {
            finishOnboarding(stepId: "complete")
        }
    }

    private func continueFromCurrentStep() {
        guard let currentStep = currentStep() else {
            return
        }

        Analytics.logEvent("onboarding_step_action", parameters: analyticsParams([
            "flow_id": flowId,
            "step_id": currentStep.analyticsId,
            "action": "continue",
            "variant": flowId
        ]))

        guard let nextStep = nextVisibleStep(after: currentStep) else {
            finishOnboarding(stepId: currentStep.analyticsId)
            return
        }

        if nextStep == .paywall {
            preloadOnboardingPaywall(onboardId: onboardId)
        }

        path.append(nextStep)
    }

    private func trackStepAppear(_ step: NewCustomOnboardingStep) {
        guard didStart else { return }

        appendVisitedStep(step.analyticsId)

        if !loggedStepViews.contains(step) {
            Analytics.logEvent("onboarding_step_view", parameters: analyticsParams([
                "flow_id": flowId,
                "step_id": step.analyticsId,
                "variant": flowId
            ]))
            loggedStepViews.insert(step)
        }

        Telemetry.shared.setActiveOnboarding(
            flowId: flowId,
            stepId: step.analyticsId,
            screenId: step.analyticsId
        )

        if step == .paywall {
            paywallShown = true
            persistSession()
            OnboardTag.saveAsLast(onboardTag)
        } else {
            persistSession()
        }
    }

    private func finishFromPaywall() {
        finishOnboarding(stepId: NewCustomOnboardingStep.paywall.analyticsId)
    }

    private func finishOnboarding(stepId: String) {
        guard !didFinish else { return }
        didFinish = true

        Analytics.logEvent("onboarding_finish", parameters: analyticsParams([
            "flow_id": flowId,
            "step_id": stepId,
            "variant": flowId
        ]))

        Analytics.logEvent("onboarding_complete", parameters: analyticsParams([
            "flow_id": flowId,
            "step_id": stepId,
            "variant": flowId
        ]))

        Telemetry.shared.clearActiveOnboarding()
        coordinator.onboardingDidFinish()
        onFinish?()
    }

    private func logOnboardingStart(step: NewCustomOnboardingStep) {
        Analytics.logEvent("onboarding_start", parameters: analyticsParams([
            "flow_id": flowId,
            "step_id": step.analyticsId,
            "variant": flowId
        ]))
    }

    private func persistSession() {
        OnboardingSessionStore.shared.save(
            tag: onboardTag,
            steps: stepsVisited,
            paywallShown: paywallShown
        )
    }

    private func appendVisitedStep(_ stepId: String) {
        guard stepsVisited.last != stepId else { return }
        stepsVisited.append(stepId)
    }

    private func stepsForPaywallSummary() -> [String] {
        var steps = stepsVisited
        if steps.last != NewCustomOnboardingStep.paywall.analyticsId {
            steps.append(NewCustomOnboardingStep.paywall.analyticsId)
        }
        return steps
    }

    private func currentStep() -> NewCustomOnboardingStep? {
        path.last ?? rootStep
    }

    private func nextVisibleStep(after step: NewCustomOnboardingStep) -> NewCustomOnboardingStep? {
        guard let index = visibleSteps.firstIndex(of: step) else { return nil }
        let nextIndex = visibleSteps.index(after: index)
        guard visibleSteps.indices.contains(nextIndex) else { return nil }
        return visibleSteps[nextIndex]
    }

    private func pageIndex(for step: NewCustomOnboardingStep) -> Int {
        let visibleContentSteps = visibleSteps.filter { $0 != .paywall }
        return visibleContentSteps.firstIndex(of: step) ?? visibleContentSteps.count
    }

    private func preloadOnboardingPaywall(onboardId: String) {
        Task {
            _ = try? await Purchases.shared.offerings()
        }
    }

    private func analyticsParams(_ params: [String: Any]) -> [String: Any] {
        var enriched = params
        if let activeAssignment {
            enriched["experiment_id"] = activeAssignment.experimentId
            enriched["bucket"] = activeAssignment.bucket
            enriched["tier"] = activeAssignment.tier
        }
        return enriched
    }
}

private enum NewCustomOnboardingFlowKind {
    case firstBlackAnnual
    case secondBlack
    case thirdBlack
    case fourthWhite
    case fifthWhite
    case sixthBlack
    case seventhBlack

    var defaultSteps: [NewCustomOnboardingStep] {
        switch self {
        case .firstBlackAnnual, .thirdBlack, .sixthBlack, .seventhBlack:
            return [.stepOne, .stepTwo, .paywall]
        case .secondBlack, .fourthWhite, .fifthWhite:
            return [.stepOne, .stepTwo, .stepThree, .paywall]
        }
    }

    var paywallId: String {
        switch self {
        case .firstBlackAnnual:
            return "paywall_new_black_3"
        case .secondBlack:
            return "paywall_new_black_2"
        case .thirdBlack:
            return "paywall_new_black_1"
        case .fourthWhite, .fifthWhite:
            return "paywall_new_white_1"
        case .sixthBlack:
            return "paywall_new_black_4"
        case .seventhBlack:
            return "paywall_new_black_5"
        }
    }
}

private enum NewCustomOnboardingStep: String, Hashable, CaseIterable {
    case stepOne
    case stepTwo
    case stepThree
    case paywall

    var configId: String {
        switch self {
        case .stepOne: return "step1"
        case .stepTwo: return "step2"
        case .stepThree: return "step3"
        case .paywall: return "paywall"
        }
    }

    var analyticsId: String {
        switch self {
        case .stepOne: return "step_1"
        case .stepTwo: return "step_2"
        case .stepThree: return "step_3"
        case .paywall: return "paywall"
        }
    }
}

private enum NewCustomOnboardingVisibleScreens {
    static func resolve(
        flowId: String,
        defaultSteps: [NewCustomOnboardingStep]
    ) -> [NewCustomOnboardingStep] {
        let allowed = Set(defaultSteps.map(\.configId))
        let controlScreens = OnboardingControlProvider.shared.visibleScreens(for: flowId)
        if let steps = steps(from: controlScreens, defaultSteps: defaultSteps, allowed: allowed) {
            return steps
        }

        return defaultSteps
    }

    private static func steps(
        from ids: [String],
        defaultSteps: [NewCustomOnboardingStep],
        allowed: Set<String>
    ) -> [NewCustomOnboardingStep]? {
        let requested = Set(ids.filter { allowed.contains($0) })

        let steps = defaultSteps.filter { requested.contains($0.configId) }
        return steps
    }
}
