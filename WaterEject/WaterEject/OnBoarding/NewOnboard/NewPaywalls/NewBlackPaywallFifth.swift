//
//  NewBlackPaywallFifth.swift
//  WaterEject
//
//  Created by Ruslan Liulka on 09.05.2026.
//


import SwiftUI
import FirebaseAnalytics
import RevenueCat

struct NewBlackPaywallFifth: View {
    @StateObject private var viewModel = NewPaywallViewModel()
    @State private var sessionId = UUID().uuidString
    @State private var didLogOpen = false
    @State private var didLogChoosePlan = false

    @EnvironmentObject private var paywallGate: PaywallGate

    let index: Int
    let action: () -> Void
    let onboardId: String?
    let summaryTag: OnboardTag?
    let stepsVisited: [String]?

    private let telemetryVariant = PaywallVariant.fourth.rawValue
    private let telemetryPaywallId: String

    private var annualPrice: String {
        if let price = viewModel.pricePerPeriod[.annual], !price.isEmpty {
            return price
        }

        if let onlyPrice = viewModel.onlyPrice[.annual], !onlyPrice.isEmpty {
            return onlyPrice.replacingOccurrences(of: "for ", with: "")
        }

        return "$29.99"
    }

    init(
        index: Int,
        action: @escaping () -> Void,
        onboardId: String? = nil,
        summaryTag: OnboardTag? = nil,
        stepsVisited: [String]? = nil,
        paywallId: String = "paywall_new_black_5"
    ) {
        self.index = index
        self.action = action
        self.onboardId = onboardId
        self.summaryTag = summaryTag
        self.stepsVisited = stepsVisited
        self.telemetryPaywallId = paywallId
    }

    private func handleCTA() {
        viewModel.selectedPlan = .annual
        let resolvedOnboardId = onboardId ?? OnboardTag.lastFromUserDefaults()?.rawValue ?? "unknown"
        let entry = entryPoint()

        if !didLogChoosePlan {
            Telemetry.shared.funnelPlanChosen(
                onboardId: resolvedOnboardId,
                plan: NewPaywallPlan.annual.analyticsValue,
                selectionMethod: "default_on_continue"
            )
            didLogChoosePlan = true
        }

        Telemetry.shared.paywallCTATap(
            variant: telemetryVariant,
            entryPoint: entry,
            plan: NewPaywallPlan.annual.analyticsValue,
            onboardId: onboardId,
            paywallId: telemetryPaywallId
        )

        Telemetry.shared.funnelGoToPurchase(
            onboardId: resolvedOnboardId,
            plan: NewPaywallPlan.annual.analyticsValue
        )

        Task {
            let result = await viewModel.buyWithRevenueCat(
                plan: .annual,
                variant: telemetryVariant,
                entryPoint: entry,
                sessionId: sessionId,
                onboardId: onboardId,
                paywallId: telemetryPaywallId
            )

            if result.isSuccess {
                logOnboardSummary(.success)
                action()
            } else {
                logOnboardSummary(.error)
            }
        }
    }

    private func entryPoint() -> String {
        paywallGate.currentContext?.rawValue ?? "onboarding"
    }

    private func logOpenIfNeeded() {
        guard !didLogOpen else { return }

        Telemetry.shared.configurePaywallPresentation(
            paywallId: telemetryPaywallId,
            variant: telemetryVariant,
            entryPoint: entryPoint(),
            purchaseSource: Telemetry.shared.resolvedPurchaseSource(for: paywallGate.currentContext),
            onboardId: onboardId ?? OnboardTag.lastFromUserDefaults()?.rawValue
        )
        Telemetry.shared.onboardPaywallOpen(
            variant: telemetryVariant,
            entryPoint: entryPoint(),
            onboardId: onboardId ?? OnboardTag.lastFromUserDefaults()?.rawValue,
            paywallId: telemetryPaywallId,
            paywallKey: telemetryPaywallId,
            displayedPlans: ["annual"],
            defaultPlan: "annual"
        )
        didLogOpen = true
    }

    private func logOnboardSummary(_ status: PaywallStatus) {
        guard let summaryTag else { return }

        Telemetry.shared.onbFlowSummary(
            onboard: summaryTag,
            steps: stepsVisited ?? [],
            paywallId: telemetryPaywallId,
            plan: status == .success ? NewPaywallPlan.annual.analyticsValue : nil,
            status: status,
            variant: telemetryVariant,
            entryPoint: entryPoint()
        )
        OnboardingSessionStore.shared.clear()
    }

    var body: some View {



//        OnboardNewFirstForm(ctaTitle:String(localized: "Continue"), ctaAction: handleCTA, pages: 2, pageIndex: index, fixedWidth: 260) {
        OnboardThirdForm(ctaTitle:String(localized: "Get Lifetime Access"), ctaAction: handleCTA, pages: 3, pageIndex: index, fixedWidth: 260) {
//            Color(red: 255 / 255, green: 255 / 255, blue: 255 / 255)
//                .ignoresSafeArea()

//            Image("paywallPhotoNewWhiteMan")
//                .resizable()
//                .scaledToFit()
//                //.scaleEffect(0.9)
//                .ignoresSafeArea()

            VStack(spacing: 10) {
                Spacer()

                ZStack(alignment: .bottom) {




                }

                Text("Start Cleaning and Playing")
                    .font(.custom("Montserrat-SemiBold", size: 24))
                    .foregroundStyle(.black)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 16)


                Text("\(annualPrice) (Pay once - use forever)")
                    .font(.custom("Montserrat-SemiBold", size: 18))
                    .foregroundStyle(.black.opacity(1))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)


            }

        }

        .background(
            ZStack(alignment: .top) {

                Color(red: 255 / 255, green: 255 / 255, blue: 255 / 255)
                    .ignoresSafeArea()

                Image("paywallPhotoNewWhiteMan")
                    .resizable()
                    .scaledToFit()
                    //.scaleEffect(0.9)
                    .ignoresSafeArea()

                    //.scaleEffect(1.05)
            }
                .ignoresSafeArea()
        )
        .onAppear {
            viewModel.selectedPlan = .annual
            logOpenIfNeeded()
            Task { await viewModel.loadPricing(paywallKey: telemetryPaywallId) }
        }

    }
}


#Preview {
    NewBlackPaywallFifth(index: 2) {
        print("1")
    }
    .environmentObject(PaywallGate.shared)
}
