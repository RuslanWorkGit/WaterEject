//
//  NewBlackPaywallFourth.swift
//  WaterEject
//
//  Created by Ruslan Liulka on 07.05.2026.
//


import SwiftUI
import FirebaseAnalytics
import RevenueCat

struct NewBlackPaywallFourth: View {
    @StateObject private var viewModel = NewPaywallViewModel()
    @State private var sessionId = UUID().uuidString
    @State private var didLogChoosePlan = false

    let index: Int
    let action: () -> Void
    let onboardId: String?
    let summaryTag: OnboardTag?
    let stepsVisited: [String]?

    private let telemetryVariant = PaywallVariant.fourth.rawValue
    private let telemetryPaywallId: String

    init(
        index: Int,
        action: @escaping () -> Void,
        onboardId: String? = nil,
        summaryTag: OnboardTag? = nil,
        stepsVisited: [String]? = nil,
        paywallId: String = "paywall_v_black_4.0"
    ) {
        self.index = index
        self.action = action
        self.onboardId = onboardId
        self.summaryTag = summaryTag
        self.stepsVisited = stepsVisited
        self.telemetryPaywallId = paywallId
    }

    private func handleCTA() {
        viewModel.selectedPlan = .yearly
        let resolvedOnboardId = onboardId ?? OnboardTag.lastFromUserDefaults()?.rawValue ?? "unknown"

        if !didLogChoosePlan {
            Telemetry.shared.funnelPlanChosen(
                onboardId: resolvedOnboardId,
                plan: NewPaywallPlan.yearly.analyticsValue,
                selectionMethod: "default_on_continue"
            )
            didLogChoosePlan = true
        }

        Telemetry.shared.funnelGoToPurchase(
            onboardId: resolvedOnboardId,
            plan: NewPaywallPlan.yearly.analyticsValue
        )

        Task {
            let result = await viewModel.buyWithRevenueCat(
                plan: .yearly,
                variant: telemetryVariant,
                entryPoint: "onboarding",
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

    private func logOnboardSummary(_ status: PaywallStatus) {
        guard let summaryTag else { return }

        Telemetry.shared.onbFlowSummary(
            onboard: summaryTag,
            steps: stepsVisited ?? [],
            paywallId: telemetryPaywallId,
            plan: status == .success ? NewPaywallPlan.yearly.analyticsValue : nil,
            status: status,
            variant: telemetryVariant,
            entryPoint: "onboarding"
        )
        OnboardingSessionStore.shared.clear()
    }

    var body: some View {



//        OnboardNewFirstForm(ctaTitle:String(localized: "Continue"), ctaAction: handleCTA, pages: 2, pageIndex: index, fixedWidth: 260) {
        OnboardThirdForm(ctaTitle:String(localized: "Continue"), ctaAction: handleCTA, pages: 3, pageIndex: index, fixedWidth: 260) {
            Color(red: 0 / 255, green: 0 / 255, blue: 0 / 255)
                .ignoresSafeArea()

            Image("SecondOnboardBGTwo")
                .resizable()
                .scaledToFit()
                //.scaleEffect(0.9)
                .ignoresSafeArea()

            VStack(spacing: 10) {
                Spacer()

                ZStack(alignment: .bottom) {




                }


                Text("98% Success Rate. Remove water now before internal corrosion starts.")
                    .font(.custom("Montserrat-SemiBold", size: 18))
                    .foregroundStyle(.white.opacity(1))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)


            }

        }

//        .background(
//            ZStack(alignment: .top) {
//                Color(red: 29 / 255, green: 29 / 255, blue: 29 / 255)
//                    .ignoresSafeArea()
//
//                Image("FirstOnboardBGOne")
//                    .resizable()
//                    .scaledToFit()
//
//                    //.scaleEffect(1.05)
//            }
//                .ignoresSafeArea()
//        )
        .onAppear {
            viewModel.selectedPlan = .yearly
            Task { await viewModel.loadPricing() }
        }

    }
}


#Preview {
    NewBlackPaywallFourth(index: 2) {
        print("1")
    }
}
