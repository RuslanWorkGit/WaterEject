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

struct NewFirstBlackYearlyOnboardingFlowView: View {
    let flowKey: String
    let onFinish: (() -> Void)?

    init(flowKey: String = "generic_flow2", onFinish: (() -> Void)? = nil) {
        self.flowKey = flowKey
        self.onFinish = onFinish
    }

    var body: some View {
        NewCustomOnboardingFlowView(
            kind: .firstBlackYearly,
            flowId: "onboard_new_first_2_step_black_yearly",
            flowKey: flowKey,
            onFinish: onFinish
        )
    }
}

struct NewSecondBlackOnboardingFlowView: View {
    let flowKey: String
    let onFinish: (() -> Void)?

    init(flowKey: String = "generic_flow2", onFinish: (() -> Void)? = nil) {
        self.flowKey = flowKey
        self.onFinish = onFinish
    }

    var body: some View {
        NewCustomOnboardingFlowView(
            kind: .secondBlack,
            flowId: "onboard_new_second_3_step_black",
            flowKey: flowKey,
            onFinish: onFinish
        )
    }
}

struct NewThirdBlackOnboardingFlowView: View {
    let flowKey: String
    let onFinish: (() -> Void)?

    init(flowKey: String = "generic_flow2", onFinish: (() -> Void)? = nil) {
        self.flowKey = flowKey
        self.onFinish = onFinish
    }

    var body: some View {
        NewCustomOnboardingFlowView(
            kind: .thirdBlack,
            flowId: "onboard_new_third_2_step_black",
            flowKey: flowKey,
            onFinish: onFinish
        )
    }
}

struct NewFourthWhiteOnboardingFlowView: View {
    let flowKey: String
    let onFinish: (() -> Void)?

    init(flowKey: String = "generic_flow2", onFinish: (() -> Void)? = nil) {
        self.flowKey = flowKey
        self.onFinish = onFinish
    }

    var body: some View {
        NewCustomOnboardingFlowView(
            kind: .fourthWhite,
            flowId: "onboard_new_fourth_3_step_white",
            flowKey: flowKey,
            onFinish: onFinish
        )
    }
}

struct NewFifthWhiteOnboardingFlowView: View {
    let flowKey: String
    let onFinish: (() -> Void)?

    init(flowKey: String = "generic_flow2", onFinish: (() -> Void)? = nil) {
        self.flowKey = flowKey
        self.onFinish = onFinish
    }

    var body: some View {
        NewCustomOnboardingFlowView(
            kind: .fifthWhite,
            flowId: "onboard_new_fifth_3_step_white",
            flowKey: flowKey,
            onFinish: onFinish
        )
    }
}

struct NewSixthBlackOnboardingFlowView: View {
    let flowKey: String
    let onFinish: (() -> Void)?

    init(flowKey: String = "generic_flow2", onFinish: (() -> Void)? = nil) {
        self.flowKey = flowKey
        self.onFinish = onFinish
    }

    var body: some View {
        NewCustomOnboardingFlowView(
            kind: .sixthBlack,
            flowId: "onboard_new_sixth_2_step_black",
            flowKey: flowKey,
            onFinish: onFinish
        )
    }
}

private struct NewCustomOnboardingFlowView: View {
    @EnvironmentObject private var coordinator: AppCoordinator

    let kind: NewCustomOnboardingFlowKind
    let flowId: String
    let flowKey: String
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
    @State private var onboardId = OnboardTag.new21.rawValue
    @State private var resolvedBrand: String?

    private let paywallId = "paywall_v_2.0"

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
                case .firstBlackYearly:
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
                }

            case .stepTwo:
                switch kind {
                case .firstBlackYearly:
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
                }

            case .stepThree:
                switch kind {
                case .secondBlack:
                    OnboardingNewSecondViewThird(index: index, action: continueFromCurrentStep)
                case .fourthWhite:
                    OnboardingNewFourthViewThree(index: index, action: continueFromCurrentStep)
                case .fifthWhite:
                    OnboardingNewFifthViewThree(index: index, action: continueFromCurrentStep)
                case .firstBlackYearly, .thirdBlack, .sixthBlack:
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
        case .firstBlackYearly:
            NewBlackPaywallThird(
                index: index,
                action: finishFromPaywall,
                onboardId: onboardId,
                summaryTag: onboardTag,
                stepsVisited: stepsForPaywallSummary(),
                paywallId: paywallId
            )

        case .secondBlack:
            NewBlackPaywallSecond(
                onFinish: finishFromPaywall,
                onboardId: onboardId,
                summaryTag: onboardTag,
                stepsVisited: stepsForPaywallSummary(),
                paywallId: paywallId
            )

        case .thirdBlack:
            NewBlackPaywall(
                onFinish: finishFromPaywall,
                onboardId: onboardId,
                summaryTag: onboardTag,
                stepsVisited: stepsForPaywallSummary(),
                paywallId: paywallId
            )

        case .fourthWhite, .fifthWhite:
            NewWhitePaywall(
                onFinish: finishFromPaywall,
                onboardId: onboardId,
                summaryTag: onboardTag,
                stepsVisited: stepsForPaywallSummary(),
                paywallId: paywallId
            )

        case .sixthBlack:
            NewBlackPaywallFourth(
                index: index,
                action: finishFromPaywall,
                onboardId: onboardId,
                summaryTag: onboardTag,
                stepsVisited: stepsForPaywallSummary(),
                paywallId: paywallId
            )
        }
    }

    private func startFlowIfNeeded() {
        guard !didStart else { return }

        let context = resolveOnboardingContext()
        onboardTag = context.tag
        onboardId = context.onboardId
        resolvedBrand = context.brand

        let configuredSteps = NewCustomOnboardingVisibleScreens.resolve(
            flowKey: flowKey,
            flowId: flowId,
            defaultSteps: kind.defaultSteps
        )
        visibleSteps = configuredSteps
        rootStep = configuredSteps.first ?? .paywall

        Telemetry.shared.setPresentedOnboardingContext(
            brand: context.brand,
            onboardId: context.tag.rawValue,
            flowKey: flowKey,
            flowId: flowId,
            brandedFlow: context.isBranded ? flowKey : nil
        )
        Telemetry.shared.sceneDidBecomeActive(onboardId: context.onboardId)
        Telemetry.shared.funnelOnboardStart(onboardId: context.onboardId)
        Telemetry.shared.onboardStarted(onboardId: context.onboardId)
        Telemetry.shared.setPresentedOnboardingContext(
            brand: context.brand,
            onboardId: context.tag.rawValue,
            flowKey: flowKey,
            flowId: flowId,
            brandedFlow: context.isBranded ? flowKey : nil
        )
        Telemetry.shared.onbFlowStart(flowId: flowId)
        OnboardTag.saveAsLast(context.tag)

        didStart = true

        if let firstStep = configuredSteps.first {
            logOnboardingStart(step: firstStep)
            trackStepAppear(firstStep)
        }
    }

    private func continueFromCurrentStep() {
        guard let currentStep = currentStep(),
              let nextStep = nextVisibleStep(after: currentStep) else {
            return
        }

        Analytics.logEvent("onboarding_step_action", parameters: [
            "flow_id": flowId,
            "step_id": currentStep.analyticsId,
            "action": "continue",
            "variant": onboardId
        ])

        if nextStep == .paywall {
            preloadOnboardingPaywall(onboardId: onboardId)
        }

        path.append(nextStep)
    }

    private func trackStepAppear(_ step: NewCustomOnboardingStep) {
        guard didStart else { return }

        appendVisitedStep(step.analyticsId)

        if !loggedStepViews.contains(step) {
            Analytics.logEvent("onboarding_step_view", parameters: [
                "flow_id": flowId,
                "step_id": step.analyticsId,
                "variant": onboardId
            ])
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
            if let resolvedBrand, !resolvedBrand.isEmpty {
                UserDefaults.standard.set(resolvedBrand, forKey: "onboarding_last_brand_v1")
            }
        } else {
            persistSession()
        }
    }

    private func finishFromPaywall() {
        guard !didFinish else { return }
        didFinish = true

        Analytics.logEvent("onboarding_finish", parameters: [
            "flow_id": flowId,
            "step_id": NewCustomOnboardingStep.paywall.analyticsId,
            "variant": onboardId
        ])

        Analytics.logEvent("onboarding_complete", parameters: [
            "flow_id": flowId,
            "step_id": NewCustomOnboardingStep.paywall.analyticsId,
            "variant": onboardId
        ])

        Telemetry.shared.clearActiveOnboarding()
        coordinator.onboardingDidFinish()
        onFinish?()
    }

    private func logOnboardingStart(step: NewCustomOnboardingStep) {
        Analytics.logEvent("onboarding_start", parameters: [
            "flow_id": flowId,
            "step_id": step.analyticsId,
            "variant": onboardId
        ])
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

    private func resolveOnboardingContext() -> NewCustomOnboardingContext {
        let isBranded = flowKey.hasPrefix("branded_")
        let tag: OnboardTag = isBranded ? .branded2 : .new21
        let brand = isBranded ? NewCustomOnboardingBrandResolver.resolve(from: coordinator, flowKey: flowKey) : nil
        let resolvedOnboardId = Telemetry.shared.resolveOnboardId(tag.rawValue, brand: brand) ?? tag.rawValue

        return NewCustomOnboardingContext(
            tag: tag,
            onboardId: resolvedOnboardId,
            brand: brand,
            isBranded: isBranded
        )
    }
}

private enum NewCustomOnboardingFlowKind {
    case firstBlackYearly
    case secondBlack
    case thirdBlack
    case fourthWhite
    case fifthWhite
    case sixthBlack

    var defaultSteps: [NewCustomOnboardingStep] {
        switch self {
        case .firstBlackYearly, .thirdBlack, .sixthBlack:
            return [.stepOne, .stepTwo, .paywall]
        case .secondBlack, .fourthWhite, .fifthWhite:
            return [.stepOne, .stepTwo, .stepThree, .paywall]
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

private struct NewCustomOnboardingContext {
    let tag: OnboardTag
    let onboardId: String
    let brand: String?
    let isBranded: Bool
}

private enum NewCustomOnboardingBrandResolver {
    static func resolve(from coordinator: AppCoordinator, flowKey: String) -> String {
        if let onboardingBrand = stringProperty(named: "onboardingBrand", in: coordinator) {
            return onboardingBrand
        }

        if let brand = stringProperty(named: "brand", in: coordinator) {
            return brand
        }

        if let contextBrand = Telemetry.shared.presentedOnboardingContext()?.brand,
           !contextBrand.isEmpty {
            return contextBrand
        }

        let keyBrand = flowKey
            .replacingOccurrences(of: "branded_", with: "")
            .split(separator: "_")
            .first
            .map(String.init)

        return keyBrand?.isEmpty == false ? keyBrand!.lowercased() : "generic"
    }

    private static func stringProperty(named name: String, in object: Any) -> String? {
        for child in Mirror(reflecting: object).children where child.label == name {
            if let value = child.value as? String,
               !value.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                return value.lowercased()
            }
        }
        return nil
    }
}

private enum NewCustomOnboardingVisibleScreens {
    private static let remoteConfigKey = "new_custom_onboarding_visible_screens_json"
    private static let localJSONKey = "new_custom_onboarding_visible_screens_json"
    private static let localListPrefix = "new_custom_onboarding_visible_screens_"

    static func resolve(
        flowKey: String,
        flowId: String,
        defaultSteps: [NewCustomOnboardingStep]
    ) -> [NewCustomOnboardingStep] {
        let allowed = Set(defaultSteps.map(\.configId))

        if let localList = UserDefaults.standard.string(forKey: localListPrefix + flowKey),
           let steps = steps(from: localList, defaultSteps: defaultSteps, allowed: allowed) {
            return steps
        }

        if let steps = stepsFromJSON(
            UserDefaults.standard.string(forKey: localJSONKey),
            flowKey: flowKey,
            flowId: flowId,
            defaultSteps: defaultSteps,
            allowed: allowed
        ) {
            return steps
        }

        let remoteJSON = RemoteConfig.remoteConfig()[remoteConfigKey].stringValue
        if let steps = stepsFromJSON(
            remoteJSON,
            flowKey: flowKey,
            flowId: flowId,
            defaultSteps: defaultSteps,
            allowed: allowed
        ) {
            return steps
        }

        return defaultSteps
    }

    private static func stepsFromJSON(
        _ json: String?,
        flowKey: String,
        flowId: String,
        defaultSteps: [NewCustomOnboardingStep],
        allowed: Set<String>
    ) -> [NewCustomOnboardingStep]? {
        guard let json,
              !json.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
              let data = json.data(using: .utf8),
              let config = try? JSONDecoder().decode(NewCustomOnboardingVisibleConfig.self, from: data) else {
            return nil
        }

        let flow = config.flows[flowKey] ?? config.flows[flowId]
        guard let ids = flow?.visibleScreens ?? flow?.screens else { return nil }
        return steps(from: ids, defaultSteps: defaultSteps, allowed: allowed)
    }

    private static func steps(
        from csv: String,
        defaultSteps: [NewCustomOnboardingStep],
        allowed: Set<String>
    ) -> [NewCustomOnboardingStep]? {
        let ids = csv
            .split(separator: ",")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
        return steps(from: ids, defaultSteps: defaultSteps, allowed: allowed)
    }

    private static func steps(
        from ids: [String],
        defaultSteps: [NewCustomOnboardingStep],
        allowed: Set<String>
    ) -> [NewCustomOnboardingStep]? {
        let requested = Set(ids.filter { allowed.contains($0) })
        guard !requested.isEmpty else { return nil }

        let steps = defaultSteps.filter { requested.contains($0.configId) }
        return steps.isEmpty ? nil : steps
    }
}

private struct NewCustomOnboardingVisibleConfig: Decodable {
    let flows: [String: NewCustomOnboardingVisibleFlow]
}

private struct NewCustomOnboardingVisibleFlow: Decodable {
    let visibleScreens: [String]?
    let screens: [String]?
}
