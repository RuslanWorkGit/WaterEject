//
//  FirstFreeTrialPaywal.swift
//  WaterEject
//
//  Created by Ruslan Liulka on 05.06.2026.
//

import SwiftUI
import RevenueCat

struct FirstFreeTrialPaywal: View {

    @StateObject private var viewModel = NewPaywallViewModel()
    @State private var webViewURL: URL?
    @State private var didLogOpen = false
    @State private var showTransactionAbandonSpecialOffer = false

    @EnvironmentObject private var paywallGate: PaywallGate

    private let sessionId = UUID().uuidString
    private let telemetryVariant = PaywallVariant.fifth.rawValue
    private let telemetryPaywallId = "fifth"

    let onFinish: () -> Void

    var body: some View {
        GeometryReader { proxy in
            let height = proxy.size.height
            let isSmall = height < 700
            let horizontalPadding: CGFloat = 24

            ZStack {
                Color(red: 5 / 255, green: 8 / 255, blue: 17 / 255)
                    .ignoresSafeArea()

                VStack(spacing: 0) {
                    topBar()
                        .padding(.horizontal, horizontalPadding)

                    ScrollView(.vertical, showsIndicators: false) {
                        VStack(spacing: isSmall ? 12 : 18) {
                            Image("paywallTrialImg")
                                .resizable()
                                .scaledToFit()
                                .frame(maxWidth: .infinity)
                                .frame(height: isSmall ? 220 : 270)
                                .padding(.top, isSmall ? 4 : 8)
                            

                            VStack(alignment: .center, spacing: isSmall ? 8 : 12) {
                                Text("All Pro Water Features")
                                    .font(.system(size: isSmall ? 24 : 28, weight: .bold))
                                    .foregroundStyle(.white)
                                    .multilineTextAlignment(.center)
                                    .fixedSize(horizontal: false, vertical: true)

                                VStack(alignment: .leading, spacing: isSmall ? 8 : 12) {
                                    FirstFreeTrialFeatureRow(title: "Unlimited Water Eject")
                                    FirstFreeTrialFeatureRow(title: "Deep Speaker Cleaning")
                                    FirstFreeTrialFeatureRow(title: "Bass & Stereo Tests")
                                    FirstFreeTrialFeatureRow(title: "Smart Cleaning Plan")
                                }
                            }
                            .frame(maxWidth: .infinity, alignment: .center)

                            VStack(spacing: 16) {
                                FirstFreeTrialPlanCard(
                                    todayPrice: "$0.00 due today",
                                    recurringPrice: recurringPriceText,
                                    trialText: "3 days free"
                                )

                                Text("Auto-renewable subscription")
                                    .font(.system(size: 22, weight: .medium))
                                    .foregroundStyle(.white)
                                    .multilineTextAlignment(.center)

                                Button(action: purchaseWeeklyPlan) {
                                    Text("Continue")
                                        .font(.system(size: 21, weight: .semibold))
                                        .foregroundStyle(.white)
                                        .frame(maxWidth: .infinity)
                                        .frame(height: 66)
                                        .background(Color(red: 64 / 255, green: 93 / 255, blue: 248 / 255))
                                        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                                }
                                .buttonStyle(.plain)
                                .disabled(viewModel.isPurchasing)

                                HStack(spacing: 20) {
                                    Button("Terms") {
                                        webViewURL = URL(string: "https://docs.google.com/document/d/1L2xhXP9qKJPSP7rymbXx17-xWh5_17V_nJPBbXm1boE/edit?tab=t.0")
                                    }

                                    Button("Privacy") {
                                        webViewURL = URL(string: "https://docs.google.com/document/d/1lQQMYnybap2JyKGf7Sd8gyPD1o9FWnAqgnGKx1BnSJI/edit?tab=t.0")
                                    }
                                }
                                .font(.system(size: 13, weight: .medium))
                                .foregroundStyle(Color.white.opacity(0.45))
                            }
                            .padding(.top, isSmall ? 2 : 8)
                        }
                        .padding(.horizontal, horizontalPadding)
                        .padding(.bottom, max(proxy.safeAreaInsets.bottom, 16))
                    }
                }
            }
        }
        .interactiveDismissDisabled(!PaywallAB.shared.isPaywallCloseEnabled)
        .sheet(item: $webViewURL) { url in
            SafariView(url: url)
        }
        .transactionAbandonSpecialOffer(
            isPresented: $showTransactionAbandonSpecialOffer,
            paywallGate: paywallGate,
            onFinish: onFinish
        )
        .onAppear {
            logOpenIfNeeded()
            Purchases.logLevel = .debug
            Task { await viewModel.loadPricing(paywallKey: telemetryPaywallId) }
        }
    }

    private var recurringPriceText: String {
        if let weeklyPrice = viewModel.pricePerPeriod[.weekly], !weeklyPrice.isEmpty {
            return "then \(weeklyPrice)"
        }

        return "then $11.99/week"
    }

    private func topBar() -> some View {
        HStack {
            if PaywallAB.shared.isPaywallCloseEnabled {
                Button(action: closePaywall) {
                    Text("Not Now")
                        .font(.system(size: 19, weight: .semibold))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 18)
                        .frame(height: 44)
                        .background(Color(red: 31 / 255, green: 36 / 255, blue: 55 / 255))
                        .clipShape(Capsule())
                }
            }

            Spacer()

            Button {
                Task { await viewModel.restorePurchases() }
            } label: {
                Text("Restore")
                    .font(.system(size: 19, weight: .semibold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 18)
                    .frame(height: 44)
                    .background(Color(red: 31 / 255, green: 36 / 255, blue: 55 / 255))
                    .clipShape(Capsule())
            }
        }
        .padding(.top, 8)
    }

    private func purchaseWeeklyPlan() {
        let entryPoint = paywallGate.currentContext?.rawValue ?? "unknown"
        let plan = NewPaywallPlan.weekly
        viewModel.selectedPlan = plan

        Telemetry.shared.paywallCTATap(
            variant: telemetryVariant,
            entryPoint: entryPoint,
            plan: plan.analyticsValue,
            onboardId: nil,
            paywallId: telemetryPaywallId
        )

        Task {
            let result = await viewModel.buyWithRevenueCat(
                plan: plan,
                variant: telemetryVariant,
                entryPoint: entryPoint,
                sessionId: sessionId,
                onboardId: nil,
                paywallId: telemetryPaywallId
            )

            if result.isSuccess {
                onFinish()
            } else if result.isCancelled {
                showTransactionAbandonSpecialOffer = true
            }
        }
    }

    private func closePaywall() {
        let entryPoint = paywallGate.currentContext?.rawValue ?? "unknown"
        Telemetry.shared.paywallClose(
            variant: telemetryVariant,
            entryPoint: entryPoint,
            reason: "not_now",
            sessionId: sessionId,
            paywallId: telemetryPaywallId,
            onboardId: nil
        )
        onFinish()
    }

    private func logOpenIfNeeded() {
        guard !didLogOpen else { return }

        let entryPoint = paywallGate.currentContext?.rawValue ?? "unknown"
        Telemetry.shared.configurePaywallPresentation(
            paywallId: telemetryPaywallId,
            variant: telemetryVariant,
            entryPoint: entryPoint,
            purchaseSource: Telemetry.shared.resolvedPurchaseSource(for: paywallGate.currentContext),
            onboardId: nil
        )
        Telemetry.shared.onboardPaywallOpen(
            variant: telemetryVariant,
            entryPoint: entryPoint,
            onboardId: nil,
            paywallId: telemetryPaywallId,
            paywallKey: telemetryPaywallId,
            displayedPlans: ["weekly"],
            defaultPlan: "weekly"
        )
        didLogOpen = true
    }
}

private struct FirstFreeTrialFeatureRow: View {
    let title: String

    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: "checkmark")
                .font(.system(size: 12, weight: .black))
                .foregroundStyle(Color(red: 5 / 255, green: 8 / 255, blue: 17 / 255))
                .frame(width: 22, height: 22)
                .background(Color.white)
                .clipShape(Circle())

            Text(title)
                .font(.system(size: 16, weight: .regular))
                .foregroundStyle(.white)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
        }
    }
}


private struct FirstFreeTrialPlanCard: View {
    let todayPrice: String
    let recurringPrice: String
    let trialText: String

    var body: some View {
        ZStack(alignment: .topTrailing) {
            HStack(alignment: .center) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(todayPrice)
                        .font(.system(size: 20, weight: .bold))
                        .foregroundStyle(.white)
                        .lineLimit(1)
                        .minimumScaleFactor(0.75)

                    Text(recurringPrice)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(Color.white.opacity(0.35))
                        .lineLimit(1)
                        .minimumScaleFactor(0.75)
                }

                Spacer(minLength: 14)

                Text(trialText)
                    .font(.system(size: 18, weight: .medium))
                    .foregroundStyle(.white)
                    .lineLimit(1)
                    .minimumScaleFactor(0.75)
            }
            .padding(.horizontal, 16)
            .frame(height: 92)
            .background(Color.clear)
            .overlay(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .stroke(Color(red: 58 / 255, green: 85 / 255, blue: 248 / 255), lineWidth: 2)
            )

            Text("POPULAR")
                .font(.system(size: 13, weight: .bold))
                .foregroundStyle(.white)
                .padding(.horizontal, 24)
                .frame(height: 22)
                .background(Color(red: 58 / 255, green: 85 / 255, blue: 248 / 255))
                .clipShape(Capsule())
                .offset(x: -28, y: -10)
        }
    }
}

#Preview {
    FirstFreeTrialPaywal(onFinish: {})
        .environmentObject(PaywallGate.shared)
}
