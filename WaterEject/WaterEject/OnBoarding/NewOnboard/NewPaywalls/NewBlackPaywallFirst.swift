//
//  NewBlackPaywallFirst.swift
//  WaterEject
//
//  Created by Ruslan Liulka on 07.05.2026.
//


import SwiftUI
import FirebaseAnalytics
import RevenueCat

struct NewBlackPaywall: View {

    @StateObject private var viewModel = NewPaywallViewModel()
    @State private var webViewURL: URL?
    @State private var didLogOpen = false
    @State private var didLogChoosePlan = false
    @State private var pulse = false

    @EnvironmentObject private var paywallGate: PaywallGate
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private let sessionId = UUID().uuidString
    private let telemetryVariant = PaywallVariant.fourth.rawValue
    private let telemetryPaywallId: String

    let onFinish: () -> Void
    let onboardId: String?
    let summaryTag: OnboardTag?
    let stepsVisited: [String]?

    init(
        onFinish: @escaping () -> Void,
        onboardId: String? = nil,
        startDelay: Double = 0.35,
        summaryTag: OnboardTag? = nil,
        stepsVisited: [String]? = nil,
        paywallId: String = "paywall_new_black_1"
    ) {
        self.onFinish = onFinish
        self.onboardId = onboardId
        self.summaryTag = summaryTag
        self.stepsVisited = stepsVisited
        self.telemetryPaywallId = paywallId
    }

    var body: some View {
        GeometryReader { proxy in
            let height = proxy.size.height
            let isSmall = height < 700
            let horizontalPadding: CGFloat = 20

            ZStack(alignment: .topTrailing) {
                Color.black.ignoresSafeArea()

                VStack(spacing: 0) {
                    Image("paywallPhotoNewBlackFirst")
                        .resizable()
                        .scaledToFill()
                        .frame(height: isSmall ? height * 0.36 : height * 0.53)
                        .frame(maxWidth: .infinity)
                        .padding(.top, 62)
                        //.clipped()

                    ScrollView(.vertical, showsIndicators: false) {
                        VStack(spacing: isSmall ? 10 : 14) {
                            VStack(spacing: 8) {
                                Text("Unlock Full Cleaning Power")
                                    .font(.system(size: isSmall ? 16 : 20, weight: .black))
                                    .foregroundStyle(.white)
                                    .multilineTextAlignment(.center)
                                    .lineSpacing(-2)

                                Text("Apple Watch Sonic Technology")
                                    .font(.system(size: isSmall ? 14 : 16, weight: .regular))
                                    .foregroundStyle(Color(red: 165 / 255, green: 172 / 255, blue: 184 / 255))
                                    .multilineTextAlignment(.center)
                            }
                        

                            NewBlackPaywallRating()
                                .padding(.top, isSmall ? 0 : 2)

                            HStack(spacing: 14) {
                                NewBlackPaywallPlanCard(
                                    title: String(localized: "Annual"),
                                    price: price(for: .annual, fallback: "$29.99"),
                                    subtitle: "\(price(for: .annual, fallback: "$29.99")) one-time purchase",
                                    badge: String(localized: "Best Value"),
                                    isSelected: viewModel.selectedPlan == .annual
                                ) {
                                    selectPlan(.annual, method: "tap")
                                }

                                NewBlackPaywallPlanCard(
                                title: "Weekly",
                                price: price(for: .weekly, fallback: "$3.99"),
                                subtitle: "$0.49/day",
                                badge: nil,
                                isSelected: viewModel.selectedPlan == .weekly
                            ) {
                                selectPlan(.weekly, method: "tap")
                            }
                        }
                        .padding(.top, isSmall ? 4 : 14)
                        .padding(.bottom, isSmall ? 4 : 14)



                        HStack(spacing: 8) {
                            Image(systemName: "checkmark.shield")
                                .font(.system(size: 16, weight: .regular))
                            Text("Cancel Anytime. No payment required today.")
                                .font(.system(size: 14, weight: .regular))
                        }
                        .foregroundStyle(Color(red: 143 / 255, green: 144 / 255, blue: 148 / 255))

                        Button(action: purchaseSelectedPlan) {
                            HStack {
                                Text("TRY FREE & FIX NOW")
                                    .font(.system(size: 20, weight: .medium))
                                    .lineLimit(1)

                                Spacer()

                                Image(systemName: "arrow.right")
                                    .font(.system(size: 28, weight: .regular))
                            }
                            .foregroundStyle(.white)
                            .padding(.horizontal, 26)
                            .frame(height: isSmall ? 56 : 58)
                            .frame(maxWidth: .infinity)
                            .background(Color(red: 2 / 255, green: 125 / 255, blue: 244 / 255))
                            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                            .scaleEffect(pulse ? 1.015 : 1.0)
                            .shadow(
                                color: Color(red: 2 / 255, green: 125 / 255, blue: 244 / 255).opacity(pulse ? 0.28 : 0),
                                radius: pulse ? 14 : 0,
                                x: 0,
                                y: 0
                            )
                        }
                        .buttonStyle(.plain)
                        .disabled(viewModel.isPurchasing)

                        HStack {
                            Button("Restore") {
                                Task { await viewModel.restorePurchases() }
                            }

                            Spacer()

                            Button("Terms of Service") {
                                webViewURL = URL(string: "https://docs.google.com/document/d/1L2xhXP9qKJPSP7rymbXx17-xWh5_17V_nJPBbXm1boE/edit?tab=t.0")
                            }

                            Spacer()

                            Button("Privacy Policy") {
                                webViewURL = URL(string: "https://docs.google.com/document/d/1lQQMYnybap2JyKGf7Sd8gyPD1o9FWnAqgnGKx1BnSJI/edit?tab=t.0")
                            }
                        }
                        .font(.system(size: 14, weight: .regular))
                        .foregroundStyle(Color(red: 143 / 255, green: 144 / 255, blue: 148 / 255))
                        .padding(.horizontal, 36)
                        .padding(.top, 2)
                        }
                        .frame(maxWidth: .infinity)
                    }
                    //.ignoresSafeArea()
                    .padding(.horizontal, horizontalPadding)
                    .padding(.top, isSmall ? -62 : -74)
                    //.padding(.bottom, max(proxy.safeAreaInsets.bottom, 10))
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                .ignoresSafeArea(edges: .top)

                Button(action: closePaywall) {
                    Image(systemName: "xmark")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundStyle(Color(red: 170 / 255, green: 170 / 255, blue: 170 / 255))
                        .frame(width: 44, height: 44)
                        .contentShape(Rectangle())
                }
                //.padding(.top, proxy.safeAreaInsets.top + 50)
                .padding(.trailing, 22)
            }
        }
        .sheet(item: $webViewURL) { url in
            SafariView(url: url)
        }
        .onAppear {
            if !reduceMotion { pulse = true }
            logOpenIfNeeded()
            Task { await viewModel.loadPricing() }
        }
        .onDisappear {
            pulse = false
        }
        .animation(
            reduceMotion ? nil : .easeInOut(duration: 0.95).repeatForever(autoreverses: true),
            value: pulse
        )
    }

    private func price(for plan: NewPaywallPlan, fallback: String) -> String {
        if let onlyPrice = viewModel.onlyPrice[plan], !onlyPrice.isEmpty {
            return onlyPrice.replacingOccurrences(of: "for ", with: "")
        }

        if let periodPrice = viewModel.pricePerPeriod[plan]?.split(separator: "/").first {
            return String(periodPrice)
        }

        return fallback
    }

    private func selectPlan(_ plan: NewPaywallPlan, method: String) {
        viewModel.selectedPlan = plan

        let resolvedOnboardId = onboardId ?? OnboardTag.lastFromUserDefaults()?.rawValue ?? "unknown"
        Telemetry.shared.funnelPlanChosen(
            onboardId: resolvedOnboardId,
            plan: plan.analyticsValue,
            selectionMethod: method
        )
        didLogChoosePlan = true
    }

    private func purchaseSelectedPlan() {
        let entry = paywallGate.currentContext?.rawValue ?? "unknown"
        let plan = viewModel.selectedPlan
        let resolvedOnboardId = onboardId ?? OnboardTag.lastFromUserDefaults()?.rawValue ?? "unknown"

        if !didLogChoosePlan {
            selectPlan(plan, method: "default_on_continue")
        }

        Telemetry.shared.paywallCTATap(
            variant: telemetryVariant,
            entryPoint: entry,
            plan: plan.analyticsValue,
            onboardId: onboardId,
            paywallId: telemetryPaywallId
        )

        Telemetry.shared.funnelGoToPurchase(
            onboardId: resolvedOnboardId,
            plan: plan.analyticsValue
        )

        Task {
            let result = await viewModel.buyWithRevenueCat(
                plan: plan,
                variant: telemetryVariant,
                entryPoint: entry,
                sessionId: sessionId,
                onboardId: onboardId,
                paywallId: telemetryPaywallId
            )

            if result.isSuccess {
                logOnboardSummary(.success)
                onFinish()
            } else {
                logOnboardSummary(.error)
            }
        }
    }

    private func closePaywall() {
        let entryPoint = paywallGate.currentContext?.rawValue ?? "unknown"
        logOnboardSummary(.close)
        Telemetry.shared.paywallClose(
            variant: telemetryVariant,
            entryPoint: entryPoint,
            reason: "close_button",
            sessionId: sessionId,
            paywallId: telemetryPaywallId,
            onboardId: onboardId
        )
        Telemetry.shared.logOnboardingAbandonIfActive(reason: "paywall_close")
        onFinish()
    }

    private func logOpenIfNeeded() {
        guard !didLogOpen else { return }

        let entry = paywallGate.currentContext?.rawValue ?? "unknown"
        Telemetry.shared.configurePaywallPresentation(
            paywallId: telemetryPaywallId,
            variant: telemetryVariant,
            entryPoint: entry,
            purchaseSource: Telemetry.shared.resolvedPurchaseSource(for: paywallGate.currentContext),
            onboardId: onboardId ?? OnboardTag.lastFromUserDefaults()?.rawValue
        )
        didLogOpen = true
    }

    private func logOnboardSummary(_ status: PaywallStatus) {
        let plan = viewModel.selectedPlan

        if let tag = summaryTag {
            let entry = paywallGate.currentContext?.rawValue ?? "unknown"
            Telemetry.shared.onbFlowSummary(
                onboard: tag,
                steps: stepsVisited ?? [],
                paywallId: telemetryPaywallId,
                plan: status == .success ? plan.analyticsValue : nil,
                status: status,
                variant: telemetryVariant,
                entryPoint: entry
            )
            OnboardingSessionStore.shared.clear()
        } else if paywallGate.currentContext == .modesTap {
            let onboardTag = OnboardTag.lastFromUserDefaults() ?? .modes
            Telemetry.shared.modesPaywall(
                status: status,
                plan: status == .success ? plan.analyticsValue : nil,
                paywallId: telemetryPaywallId,
                onboard: onboardTag,
                entryPoint: "modes"
            )
        }
    }
}

private struct NewBlackPaywallRating: View {
    var body: some View {
        HStack(spacing: 4) {
            HStack(spacing: 1) {
                ForEach(0..<5, id: \.self) { _ in
                    Image(systemName: "star.fill")
                        .font(.system(size: 14, weight: .bold))
                }
            }
            .foregroundStyle(Color(red: 2 / 255, green: 125 / 255, blue: 244 / 255))

            Text("Trusted by 1M+ users")
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(.white)
                .padding(.leading, 6)
        }
    }
}

private struct NewBlackPaywallPlanCard: View {
    let title: String
    let price: String
    let subtitle: String
    let badge: String?
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            ZStack(alignment: .top) {
                VStack(spacing: 10) {
                    Text(LocalizedStringKey(title))
                        .font(.system(size: 21, weight: .bold))
                        .foregroundStyle(.white)
                        .padding(.top, badge == nil ? 22 : 22)

                    Text(price)
                        .font(.system(size: 26, weight: .black))
                        .foregroundStyle(.white)

                    Text(LocalizedStringKey(subtitle))
                        .font(.system(size: 13, weight: .regular))
                        .foregroundStyle(Color(red: 165 / 255, green: 172 / 255, blue: 184 / 255))

                    Spacer(minLength: 0)

                    ZStack {
                        Circle()
                            .stroke(
                                isSelected ? Color(red: 2 / 255, green: 125 / 255, blue: 244 / 255) : Color(red: 167 / 255, green: 167 / 255, blue: 167 / 255),
                                lineWidth: 1.2
                            )
                            .frame(width: 30, height: 30)

                        if isSelected {
                            Circle()
                                .fill(Color(red: 2 / 255, green: 125 / 255, blue: 244 / 255))
                                .frame(width: 30, height: 30)

                            Image(systemName: "checkmark")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundStyle(.white)
                        }
                    }
                    .padding(.bottom, 14)
                }
                .frame(maxWidth: .infinity)
                .frame(height: 168)
                .background(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(isSelected ? Color(red: 31 / 255, green: 149 / 255, blue: 231 / 255).opacity(0.18) : Color.white.opacity(0.1))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .stroke(
                            isSelected ? Color(red: 109 / 255, green: 196 / 255, blue: 247 / 255) : Color(red: 160 / 255, green: 160 / 255, blue: 160 / 255),
                            lineWidth: 1.2
                        )
                )

                if let badge {
                    Text(badge)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 18)
                        .frame(height: 30)
                        .background(Color(red: 2 / 255, green: 125 / 255, blue: 244 / 255))
                        .clipShape(Capsule())
                        .offset(y: -15)
                }
            }
        }
        .buttonStyle(.plain)
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    NewBlackPaywall(onFinish: { print("hello") })
        .environmentObject(PaywallGate.shared)
}
