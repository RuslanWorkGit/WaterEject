//
//  NewBlackPaywallThird.swift
//  WaterEject
//
//  Created by Ruslan Liulka on 07.05.2026.
//

import SwiftUI
import FirebaseAnalytics
import RevenueCat

struct NewBlackPaywallThird: View {
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

    init(
        index: Int,
        action: @escaping () -> Void,
        onboardId: String? = nil,
        summaryTag: OnboardTag? = nil,
        stepsVisited: [String]? = nil,
        paywallId: String = "paywall_new_black_3"
    ) {
        self.index = index
        self.action = action
        self.onboardId = onboardId
        self.summaryTag = summaryTag
        self.stepsVisited = stepsVisited
        self.telemetryPaywallId = paywallId
    }

    private var annualPrice: String {
        if let onlyPrice = viewModel.onlyPrice[.annual], !onlyPrice.isEmpty {
            return onlyPrice.replacingOccurrences(of: "for ", with: "")
        }

        if let periodPrice = viewModel.pricePerPeriod[.annual]?.split(separator: "/").first {
            return String(periodPrice)
        }

        return "$29.99"
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
//            Color(red: 0 / 255, green: 0 / 255, blue: 0 / 255)
//                .ignoresSafeArea()
//            
//            Image("FirstOnboardBGOne")
//                .resizable()
//                
//                .ignoresSafeArea()
//            
            VStack(spacing: 10) {
                Spacer()
                
                ZStack(alignment: .bottom) {
                   
                   
                    
                    
                }
                
                
                Text("Start Cleaning and Playing")
                    .font(.custom("Montserrat-Bold", size: 26))
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)
                    .padding(.bottom, 16)
                
                Text("\(annualPrice) one-time")
                    .font(.custom("Montserrat-SemiBold", size: 16))
                    .foregroundStyle(.white.opacity(0.6))
                    .multilineTextAlignment(.center)
                    .padding(.bottom, 18)
                    .padding(.horizontal, 30)
                
                
            }
            
        }
        
        .background(
            ZStack(alignment: .top) {
                Color(red: 0 / 255, green: 0 / 255, blue: 0 / 255)
                    .ignoresSafeArea()

                Image("paywallPhotoNewBlackThird")
                    .resizable()
                    .scaledToFit()

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
    NewBlackPaywallThird(index: 0) {
        print("1")
    }
    .environmentObject(PaywallGate.shared)
}
