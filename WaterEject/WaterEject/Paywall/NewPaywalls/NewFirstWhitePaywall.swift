//
//  NewFirstWhitePaywall.swift
//  WaterEject
//
//  Created by Ruslan Liulka on 16.06.2026.
//

import SwiftUI
import FirebaseAnalytics
import RevenueCat

struct NewFirstWhitePaywall: View {
    @StateObject private var viewModel = NewPaywallViewModel()
    @State private var sessionId = UUID().uuidString
    @State private var didLogOpen = false
    @State private var didLogChoosePlan = false
    @State private var showTransactionAbandonSpecialOffer = false

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
        paywallId: String = "paywall_first_white_1"
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
            } else if result.isCancelled {
                logOnboardSummary(.abandon)
                showTransactionAbandonSpecialOffer = true
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

    private func closePaywall() {
        let entry = entryPoint()
        logOnboardSummary(.close)
        Telemetry.shared.paywallClose(
            variant: telemetryVariant,
            entryPoint: entry,
            reason: "close_button",
            sessionId: sessionId,
            paywallId: telemetryPaywallId,
            onboardId: onboardId
        )
        Telemetry.shared.logOnboardingAbandonIfActive(reason: "paywall_close")
        action()
    }
    
    
    var body: some View {
        let paywallText = PaywallAB.shared.textSettings(forKey: telemetryPaywallId)
        let annualPlanText = paywallText.plan(NewPaywallPlan.annual.rawValue)
        let ctaTitle = paywallText.ctaTitle ?? annualPlanText.title ?? String(localized: "Get Lifetime Access")
        let priceCaption = String(
            format: paywallText.priceCaptionFormat ?? String(localized: "%@ (Pay once - use forever)"),
            annualPrice
        )
        

//        OnboardNewFirstForm(ctaTitle:String(localized: "Continue"), ctaAction: handleCTA, pages: 2, pageIndex: index, fixedWidth: 260) {
        OnboardWhiteForm(ctaTitle: ctaTitle, ctaAction: handleCTA, pages: 3, pageIndex: index, fixedWidth: 260) {
//            Color(red: 0 / 255, green: 0 / 255, blue: 0 / 255)
//                .ignoresSafeArea()
//
//            Image("FirstOnboardBGOne")
//                .resizable()
//
//                .ignoresSafeArea()
//
            VStack(spacing: 6) {
                Spacer()
                
                ZStack(alignment: .bottom) {
                   
                   
                    
                    
                }
                
                Text(paywallText.subtitleText ?? String(localized: "Apple Watch Sonic Technology"))
                    .font(.custom("Montserrat-SemiBold", size: 12))
                    .foregroundStyle(Color(red: 25 / 255, green: 26 / 255, blue: 28 / 255))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 30)
                
                
                Text(paywallText.mainText ?? String(localized: "Unlock Full Cleaning Power"))
                    .font(.custom("Montserrat-Bold", size: 26))
                    .foregroundStyle(.black)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)
                    .padding(.bottom, 4)
                
                Text(priceCaption)
                    .font(.custom("Montserrat-SemiBold", size: 16))
                    .foregroundStyle(Color(red: 25 / 255, green: 26 / 255, blue: 28 / 255))
                    .multilineTextAlignment(.center)
                    .padding(.bottom, 12)
                    .padding(.horizontal, 30)
                
                
            }
            
        }
        
        .background(
            ZStack(alignment: .top) {
                Color(red: 238 / 255, green: 234 / 255, blue: 247 / 255)
                    .ignoresSafeArea()

                Image("NewFirstWhitePaywallImg")
                    .resizable()
                    .scaledToFit()

                    //.scaleEffect(1.05)
            }
                .ignoresSafeArea()
        )
        .overlay(alignment: .topTrailing) {
            if PaywallAB.shared.isPaywallCloseEnabled {
                Button(action: closePaywall) {
                    Image(systemName: "xmark")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundStyle(Color(red: 170 / 255, green: 170 / 255, blue: 170 / 255))
                        .frame(width: 44, height: 44)
                        .contentShape(Rectangle())
                }
                .padding(.trailing, 22)
            }
        }
        .interactiveDismissDisabled(!PaywallAB.shared.isPaywallCloseEnabled)
        .onAppear {
            viewModel.selectedPlan = .annual
            logOpenIfNeeded()
            Task { await viewModel.loadPricing(paywallKey: telemetryPaywallId) }
        }
        .transactionAbandonSpecialOffer(
            isPresented: $showTransactionAbandonSpecialOffer,
            paywallGate: paywallGate,
            onFinish: action
        )
        
    }
}

struct OnboardWhiteForm<Content: View>: View {
    let ctaTitle: String
    let ctaAction: () -> Void
    var pages: Int = 0
    var pageIndex: Int = 0
    var fixedWidth: CGFloat = 260
    var button: Bool = true
    @ViewBuilder let content: () -> Content
    
    private var isPad: Bool { UIDevice.current.userInterfaceIdiom == .pad }
    private var padScale: CGFloat { isPad ? 1.3 : 1.0 }
    
    var body: some View {
        ZStack { content() }
            .safeAreaInset(edge: .bottom) {
                VStack {
                    

                    
                    HStack { // гарантує однакову геометрію
                        Spacer()
                        
                        
                        
                        OboardWhiteNewButton(title: ctaTitle, action: ctaAction, arrow: true)
                            .padding(.horizontal, 40)
                            .frame(minHeight: 52) // ключ
                            .frame(width: .infinity)
                            .opacity(button ? 1 : 0)
                        Spacer()
                    }
                    
//                    if pages > 0 {
//                        PageDotsWhite(total: pages, index: pageIndex)
////                            .padding(.bottom, 32)
//                            .padding(.bottom, 12)
//                            //.padding(.top, 12)
//                    }
                    
                    
                }
                
                .padding(.bottom, 0)
                
            }
    }
}

struct OboardWhiteNewButton: View {
    let title: String
    let action: () -> Void
    var arrow: Bool = false
    
    
    var body: some View {
        Button(action: {
            
            let generator = UIImpactFeedbackGenerator(style: .medium)
            
            generator.prepare()
            generator.impactOccurred()
            action()
            
        }) {
            Text(title)
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(.white)
                .frame(minHeight: 52)
                .frame(maxWidth: .infinity)
            //.contentShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            
        }
        //.buttonStyle(.plain)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color(red: 2/255, green: 125/255, blue: 244/255)) // як на скріні
                .innerShadow(
                    RoundedRectangle(cornerRadius: 16),
                    color: Color(red: 2/255, green: 125/255, blue: 244/255), opacity: 0.25,
                    x: 0, y: 1, blur: 0, spread: 2
                )
        )
        
        
    }
}

struct PageDotsWhite: View {
    let total: Int
    let index: Int        // 0...total-1
    
    private let active = Color(red: 2/255, green: 125/255, blue: 244/255)// #317DEC
    private let inactive = Color(red: 220/255, green: 224/255, blue: 230/255) // сірі точки
    
    var body: some View {
        HStack(spacing: 8) {
            ForEach(0..<total, id: \.self) { i in
                let isActive = (i == index)
                
                Capsule()
                    .fill(isActive ? active : inactive)
                    .frame(
                        width: isActive ? 11 : 8,   // 👈 капсула ↔ кружок
                        height: isActive ? 11 : 8
                    )
            }
        }
        .padding(.top, 14)
        .padding(.bottom, 4)
        .frame(maxWidth: .infinity)
        .allowsHitTesting(false)
        // анімація при зміні index
        .animation(.easeInOut(duration: 0.25), value: index)
    }
}


#Preview {
    NewFirstWhitePaywall(index: 0) {
        print("1")
    }
    .environmentObject(PaywallGate.shared)
}
