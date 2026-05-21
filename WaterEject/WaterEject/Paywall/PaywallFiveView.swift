//
//  PaywallFiveView.swift
//  WaterEject
//
//  Created by Ruslan Liulka on 08.12.2025.
//

import SwiftUI
import FirebaseAnalytics
import RevenueCat
import AVFoundation

struct PaywallFiveView: View {

    @StateObject private var viewModel = NewPaywallViewModel()
    @State private var webViewURL: URL?
    @State private var didLogOpen = false
    @EnvironmentObject private var paywallGate: PaywallGate
    @State private var sessionId = UUID().uuidString
    @State private var player = AVQueuePlayer()
    @State private var playerLooper: AVPlayerLooper?
    @State private var isExiting = false

    @State private var appearVideo = false
    @State private var appearTitle = false
    @State private var appearList  = false
    @State private var appearCards = false
    @State private var startDelay: Double = 0.35
    @State private var featuresWidth: CGFloat = 0

    @State private var showInfoCardContent = false
    @State private var isFreeTrialEnabled = true
    @State private var isFreeTrialAllowed = true

    @State private var pulse = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var didShowFirstCard = false
    @State private var appearReviews = false


    enum InfoCard: Int, CaseIterable {
        case reviews, features, stats
    }

    @State private var currentInfoCard: InfoCard = .reviews

    // 🔹 нове: напрямок анімації + “ручний” таймер
    @State private var isForward: Bool = true
    @State private var autoAdvanceWorkItem: DispatchWorkItem?
    @State private var didLogChoosePlan = false
    private let infoCardInterval: TimeInterval = 2.5



        let reviews: [Review] = [
            .init(text: String(localized: "It saved my iPhone!"),               name: "Maria",  rating: 5),
            .init(text: String(localized: "Saved me from going to repair!"),    name: "Kevin",  rating: 5),
            .init(text: String(localized: "Worked better than rice!"),          name: "Sophie", rating: 5)
        ]

    let onFinish: () -> Void
    let onboardId: String?
    let summaryTag: OnboardTag?     // ⬅️ нове: для "Onbord_v_3.x"
    let stepsVisited: [String]?     // ⬅️ нове: пройдені екрани
    private let exitDuration: Double = 0.6
    let startAnimations: Bool
    private let telemetryVariant = PaywallVariant.fifth.rawValue
    private let telemetryPaywallId = "paywall_v_5.0"


    private var isPad: Bool { UIDevice.current.userInterfaceIdiom == .pad }
    private var padScale: CGFloat { isPad ? 1.3 : 1.0 }

    init(onFinish: @escaping () -> Void, onboardId: String? = nil, startDelay: Double = 0.35, summaryTag: OnboardTag? = nil, stepsVisited: [String]? = nil, startAnimations: Bool = true ) {
        self.onFinish = onFinish
        self.onboardId = onboardId
        self._startDelay = State(initialValue: startDelay)
        self.summaryTag = summaryTag
        self.stepsVisited = stepsVisited
        self.startAnimations = startAnimations
    }


    private func logOnboardSummary(_ status: PaywallStatus) {
        let plan    = viewModel.selectedPlan
        if let tag = summaryTag {
            let entry   = paywallGate.currentContext?.rawValue ?? "unknown"
            Telemetry.shared.onbFlowSummary(
                onboard: tag,
                steps: stepsVisited ?? [],
                paywallId: telemetryPaywallId,
                plan: (status == .success ? plan.analyticsValue : nil), // ← лише для success
                status: status,
                variant: telemetryVariant,
                entryPoint: entry
            )
            OnboardingSessionStore.shared.clear()
        } else {
            // ⬇️ НЕ онбординг: якщо пейвол відкрито з Modes — логнемо modes_paywall
            if paywallGate.currentContext == .modesTap {

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

    var body: some View {

        let isSmall = UIScreen.main.bounds.height < 700
        let isLarge = UIScreen.main.bounds.height > 900
        let secondaryPlan = viewModel.yearlyCardPlan
        let shouldShowFreeTrial = isFreeTrialAllowed && isFreeTrialEnabled

        ZStack(alignment: .topTrailing) {


            ZStack(alignment: .top) {

                Color(red: 253 / 255, green: 251 / 255, blue: 249 / 255).ignoresSafeArea()

                VStack(alignment: .center) {

                    Spacer()

                    VStack(spacing: 8) {



                        (
                            Text("Remove Water Fast")
                                .foregroundStyle(Color(red: 2 / 255, green: 125 / 255, blue: 244 / 255))

                        )
                        .font(.system(size: 38 * padScale, weight: .semibold))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 16)
                        .padding(.bottom, 0)
                        //.padding(.top, 180)


//                        ReviewsCardView(reviews: reviews)


                        ZStack(alignment: .top) {
                            Group {
                                switch currentInfoCard {
                                case .reviews:
                                    ReviewsCardView(reviews: reviews)
//                                        .drawingGroup()

                                case .features:
                                    FeaturesCardView()
                                case .stats:
                                    StatisticCardView()
                                }
                            }
                            .id(currentInfoCard)
                            .transition(
                                didShowFirstCard
                                ? .asymmetric(
                                    insertion: .move(edge: isForward ? .trailing : .leading)
                                        .combined(with: .opacity),
                                    removal: .move(edge: isForward ? .leading : .trailing)
                                        .combined(with: .opacity)
                                )
                                : .identity
                            )
                            .frame(maxWidth: .infinity,
                                   maxHeight: .infinity,
                                   alignment: .top)
                        }
                        .frame(height: 180)
                        //.padding()
                        //.opacity(appearReviews ? 1 : 0)

                        .onAppear {
                            if startAnimations {
                                didShowFirstCard = true
                                appearReviews = false

                                DispatchQueue.main.asyncAfter(deadline: .now() + startDelay) {
                                    withAnimation(.easeOut(duration: 0.28)) {
                                        appearReviews = true
                                    }
                                }

                                restartAutoAdvance()
                            }
                        }
                        .onChange(of: startAnimations) {
                            if startAnimations {
                                didShowFirstCard = true
                                appearReviews = false

                                DispatchQueue.main.asyncAfter(deadline: .now() + startDelay - 0.5) {
                                    withAnimation(.easeOut(duration: 0.28)) {
                                        appearReviews = true
                                    }
                                }

                                restartAutoAdvance()
                            } else {
                                appearReviews = false
                                autoAdvanceWorkItem?.cancel()
                            }
                        }
                        .gesture(
                            DragGesture(minimumDistance: 20)
                                .onEnded { value in
                                    let translation = value.translation.width
                                    let threshold: CGFloat = 40
                                    guard abs(translation) > threshold else { return }

                                    if translation < 0 {
                                        // свайп ліворуч → наступна
                                        goNextCard(animated: true)
                                    } else {
                                        // свайп праворуч → попередня
                                        goPreviousCard(animated: true)
                                    }

                                    restartAutoAdvance()
                                }
                        )
                    }


                    //Spacer(minLength: 0)

                    //Spacer()

                    VStack(spacing: 12) {

                        if isFreeTrialAllowed {
                            PaywallFiveFreeTrialToggle(isOn: $isFreeTrialEnabled)
                                .onChange(of: isFreeTrialEnabled) { _, isEnabled in
                                    if isEnabled {
                                        choosePlan(.weekly, selectionMethod: "free_trial_toggle")
                                    } else if viewModel.selectedPlan == .weekly {
                                        choosePlan(secondaryPlan, selectionMethod: "free_trial_toggle")
                                    }
                                }
                        }

                        PaywallFivePlanCard(
                            title: shouldShowFreeTrial ? String(localized: "3 Days Free") : NewPaywallPlan.weekly.title,
                            price: shouldShowFreeTrial ? "\(String(localized: "then")) \(viewModel.pricePerPeriod[.weekly] ?? "...")" : viewModel.pricePerPeriod[.weekly] ?? "...",
                            sublabel: nil,
                            saveText: shouldShowFreeTrial ? String(localized: "Free trial") : viewModel.onlyPrice[.weekly] ?? "",
                            isSelected: viewModel.selectedPlan == .weekly,
                            onTap: {
                                if shouldShowFreeTrial || !isFreeTrialAllowed {
                                    choosePlan(.weekly, selectionMethod: "tap")
                                } else {
                                    isFreeTrialEnabled = true
                                }
                            }
                        )

                        PaywallFivePlanCard(
                            title: secondaryPlan.title,
                            price: viewModel.pricePerPeriod[secondaryPlan] ?? "…",
                            sublabel: String(localized: "Best Value"),
                            saveText: viewModel.onlyPrice[secondaryPlan] ?? "",
                            isSelected: viewModel.selectedPlan == secondaryPlan,
                            onTap: {
                                if shouldShowFreeTrial {
                                    isFreeTrialEnabled = false
                                } else {
                                    choosePlan(secondaryPlan, selectionMethod: "tap")
                                }
                            }
                        )
                    }
                    .padding(.top, isSmall ? 12 : isLarge ? 30 : 20)
                    .padding(.bottom, 12)

                    HStack {
                        Image(systemName: "checkmark.shield")
                            .foregroundStyle(Color(red: 131 / 255, green: 137 / 255, blue: 147 / 255))
                        Text(shouldShowFreeTrial ? String(localized: "Cancel Anytime. No payment required today.") : String(localized: "Cancel Anytime. Secure with App Store."))
                            .font(.system(size: 10))
                            .foregroundStyle(Color(red: 131 / 255, green: 137 / 255, blue: 147 / 255))
                            .multilineTextAlignment(.center)
                    }
                    .padding(0)


                    Button {
                        let entry   = paywallGate.currentContext?.rawValue ?? "unknown"
                        let plan    = viewModel.selectedPlan
                        let resolvedOnboardId = onboardId ?? OnboardTag.lastFromUserDefaults()?.rawValue ?? "unknown"

                        if !didLogChoosePlan {
                            Telemetry.shared.funnelPlanChosen(
                                onboardId: resolvedOnboardId,
                                plan: plan.analyticsValue,
                                selectionMethod: "default_on_continue"
                            )
                            didLogChoosePlan = true
                        }

                        Telemetry.shared.paywallCTATap(variant: telemetryVariant, entryPoint: entry,
                                                       plan: plan.analyticsValue, onboardId: onboardId)


                        Telemetry.shared.funnelGoToPurchase(
                            onboardId: resolvedOnboardId,
                            plan: plan.analyticsValue
                        )

//                        if let onboardId = onboardId {
//                            Telemetry.shared.funnelGoToPurchase(
//                                onboardId: onboardId,
//                                plan: plan.analyticsValue
//                            )
//                        }

                        Task {
                            let result = await viewModel.buyWithRevenueCat(
                                plan: plan, variant: telemetryVariant, entryPoint: entry, sessionId: sessionId, onboardId: onboardId, paywallId: telemetryPaywallId
                            )
                            if result.isSuccess {
                                logOnboardSummary(.success)
                                onFinish()
                            } else {
                                logOnboardSummary(.error)
                            }
                        }
                    } label: {
                        let forPeriod = viewModel.onlyPrice[viewModel.selectedPlan] ?? ""

                        HStack {
                            if viewModel.isPurchasing {
                                ProgressView().tint(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 12)

                                //                            .background(Color(red: 81 / 255, green: 132 / 255, blue: 234 / 255))
                                    .background(Color(red: 2 / 255, green: 125 / 255, blue: 244 / 255))
                                    .clipShape(RoundedRectangle(cornerRadius: 16))

                                    .scaleEffect(pulse ? 1.03 : 1.0)
                                    .shadow(
                                        color: Color(red: 2 / 255, green: 125 / 255, blue: 244 / 255)
                                            .opacity(pulse ? 0.45 : 0.0),
                                        radius: pulse ? 18 : 6, x: 0, y: 0
                                    )
                                    .animation(
                                        reduceMotion ? nil :
                                                .easeInOut(duration: 0.95).repeatForever(autoreverses: true),
                                        value: pulse
                                    )
                            } else {
                                HStack(spacing: 10) {
                                    Spacer()
                                    Text(shouldShowFreeTrial ? String(localized: "Continue") : (forPeriod.isEmpty ? String(localized: "Continue") : "\(String(localized: "Continue")) \(forPeriod)"))
                                        .font(.system(size: 16 * padScale, weight: .semibold))
                                        .foregroundStyle(.white)
                                    Image(systemName: "arrow.right")
                                        .font(.system(size: 18 * padScale, weight: .semibold))
                                        .foregroundStyle(.white)
                                    Spacer()
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .background(Color(red: 2 / 255, green: 125 / 255, blue: 244 / 255))
                                .clipShape(RoundedRectangle(cornerRadius: 16))
                                .scaleEffect(pulse ? 1.03 : 1.0)
                                .shadow(
                                    color: Color(red: 2 / 255, green: 125 / 255, blue: 244 / 255)
                                        .opacity(pulse ? 0.45 : 0.0),
                                    radius: pulse ? 18 : 6, x: 0, y: 0
                                )
                                .animation(
                                    reduceMotion ? nil :
                                            .easeInOut(duration: 0.95).repeatForever(autoreverses: true),
                                    value: pulse
                                )
                            }
                        }


                    }
                    .disabled(viewModel.isPurchasing || !appearVideo)
                    .allowsHitTesting(appearVideo && !viewModel.isPurchasing)
                    .opacity(appearVideo ? 1 : 0)

                    .padding(.horizontal, 24)
                    .padding(.bottom, 4)




                    HStack(spacing: 36) {



                        Button("Restore") {
                            Task { await viewModel.restorePurchases() }
                        }
                        .font(.system(size: 10 * padScale))
                        .foregroundStyle(Color(red: 131 / 255, green: 137 / 255, blue: 147 / 255))


                        Button("Terms of Service") {

                            webViewURL = URL(string: "https://docs.google.com/document/d/1L2xhXP9qKJPSP7rymbXx17-xWh5_17V_nJPBbXm1boE/edit?tab=t.0")

                        }
                        .font(.system(size: 10 * padScale))
                        .foregroundStyle(Color(red: 131 / 255, green: 137 / 255, blue: 147 / 255))

                        Button("Privacy Policy") {

                            webViewURL = URL(string: "https://docs.google.com/document/d/1lQQMYnybap2JyKGf7Sd8gyPD1o9FWnAqgnGKx1BnSJI/edit?tab=t.0")

                        }

                        .font(.system(size: 10 * padScale))
                        .foregroundStyle(Color(red: 131 / 255, green: 137 / 255, blue: 147 / 255))
                    }



                }
                //                .frame(maxHeight: .infinity, alignment: .top)
                .frame(maxHeight: .infinity)
                .padding(.horizontal, 16)
                .padding(.top, 16)
                .padding(.bottom, 8)
                .background(
                    VStack {
                        Image("paywallPhoto")
                            .resizable()
                            .scaledToFit()

                        Spacer()
                    }
                        .ignoresSafeArea()

                )



            }

            Button(action: {
                let entryPoint = paywallGate.currentContext?.rawValue ?? "unknown"
                logOnboardSummary(.close)
                Telemetry.shared.paywallClose(
                    variant: telemetryVariant,
                    entryPoint: entryPoint,
                    reason: "close_button",
                    sessionId: sessionId
                )
                Telemetry.shared.logOnboardingAbandonIfActive(reason: "paywall_close")
                onFinish()
            }) {
                Image(systemName: "xmark")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(Color(red: 179 / 255, green: 179 / 255, blue: 179 / 255))
                    .padding(14)
            }
            .padding(.top, 20)
            .padding(.trailing, 18)
        }


        .sheet(item: $webViewURL) { url in
            SafariView(url: url)
        }
        .onAppear {
            if !reduceMotion { pulse = true }

            if !didLogOpen {
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
            Task {
                await viewModel.loadPricing(paywallVariant: .fifth)
                isFreeTrialAllowed = viewModel.freeTestEnabled
                isFreeTrialEnabled = viewModel.freeTestEnabled
            }



            //            withAnimation(.easeInOut(duration: 0.2)) {
            //                appearReviews = true
            //            }
            //
            //            restartAutoAdvance()

        }
        .task {
            DispatchQueue.main.asyncAfter(deadline: .now() + startDelay) {
                player.play()
                withAnimation(.easeIn(duration: 0.4)) {
                    appearVideo = true
                }
            }
        }
        .onDisappear {
            pulse = false
            autoAdvanceWorkItem?.cancel()
            autoAdvanceWorkItem = nil
        }

    }

    private func goNextCard(animated: Bool) {
        let all = InfoCard.allCases
        guard let idx = all.firstIndex(of: currentInfoCard) else { return }
        let next = all[(idx + 1) % all.count]

        isForward = true

        if animated && !reduceMotion {
            withAnimation { currentInfoCard = next }
        } else {
            currentInfoCard = next
        }
    }

    private func choosePlan(_ plan: NewPaywallPlan, selectionMethod: String) {
        viewModel.selectedPlan = plan

        let resolvedOnboardId = onboardId ?? OnboardTag.lastFromUserDefaults()?.rawValue ?? "unknown"
        Telemetry.shared.funnelPlanChosen(
            onboardId: resolvedOnboardId,
            plan: plan.analyticsValue,
            selectionMethod: selectionMethod
        )

        didLogChoosePlan = true
    }

    private func goPreviousCard(animated: Bool) {
        let all = InfoCard.allCases
        guard let idx = all.firstIndex(of: currentInfoCard) else { return }
        let prev = all[(idx - 1 + all.count) % all.count]

        isForward = false

        if animated && !reduceMotion {
            withAnimation { currentInfoCard = prev }
        } else {
            currentInfoCard = prev
        }
    }

    // MARK: - Авто-перелистування + перезапуск

    private func restartAutoAdvance() {
        autoAdvanceWorkItem?.cancel()

        guard !reduceMotion else { return }

        let work = DispatchWorkItem {
            goNextCard(animated: true)
            restartAutoAdvance()
        }

        autoAdvanceWorkItem = work
        DispatchQueue.main.asyncAfter(deadline: .now() + infoCardInterval, execute: work)
    }



}


// 1) Ключ для передачі розміру
private struct SizePref: PreferenceKey {
    static var defaultValue: CGSize = .zero
    static func reduce(value: inout CGSize, nextValue: () -> CGSize) {
        let n = nextValue()
        value = CGSize(width: max(value.width, n.width), height: max(value.height, n.height))
    }
}

// 2) Зручний модифікатор
private extension View {
    func onSizeChange(_ perform: @escaping (CGSize) -> Void) -> some View {
        background(
            GeometryReader { g in
                Color.clear.preference(key: SizePref.self, value: g.size)
            }
        )
        .onPreferenceChange(SizePref.self, perform: perform)
    }
}

struct Review: Identifiable {
    let id = UUID()
    let text: String
    let name: String
    let rating: Int
}

struct StarsView: View {
    let rating: Int

    private var isPad: Bool { UIDevice.current.userInterfaceIdiom == .pad }
    private var padScale: CGFloat { isPad ? 1.3 : 1.0 }

    var body: some View {
        HStack(spacing: 4) {
            ForEach(0..<rating, id: \.self) { _ in
                Image(systemName: "star.fill")
                    .font(.system(size: 16 * padScale))
                    .foregroundColor(Color(red: 250/255, green: 204/255, blue: 21/255)) // жовтий
            }
        }
    }
}

struct PaywallFivePlanCard: View {
    let title: String
    let price: String
    let sublabel: String?
    let saveText: String
    let isSelected: Bool
    let onTap: () -> Void



    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 16) {
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(isSelected ? Color(red: 2 / 255, green: 125 / 255, blue: 244 / 255) : Color.gray.opacity(0.3))
                    .font(.system(size: 28, weight: .light))

                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(title)
                            .font(.system(size: 20, weight: .bold))
                            .foregroundStyle(.black)
                        Spacer()

                    }
                    Text(price)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(Color(red: 170/255, green: 178/255, blue: 191/255))
                }



                VStack {
                    if let sublabel = sublabel {
                        Text(sublabel)
                            .font(.system(size: 12))
                            .padding(.horizontal, 6)
                            .padding(.vertical, 4)
                            .background(Color(red: 81/255, green: 132/255, blue: 234/255).opacity(0.14))
                            .foregroundStyle(Color(red: 81/255, green: 132/255, blue: 234/255))
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                    }


                    Text(saveText)
                        .font(.system(size: sublabel == nil ? 16 : 10, weight: sublabel == nil ? .semibold : .regular))
                        .foregroundStyle(sublabel == nil ? .black : Color(red: 196/255, green: 196/255, blue: 197/255))
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                }
                .frame(minWidth: 92, alignment: .trailing)
            }
            .padding(.horizontal, 16)
            .frame(maxWidth: .infinity, minHeight: 72, maxHeight: 72)
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .fill(Color.white)
                    //                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                    //                        .fill(Color.white.opacity(0.15))
                }
            )
            .overlay(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .stroke(
                        isSelected ? Color(red: 2 / 255, green: 125 / 255, blue: 244 / 255) : Color(red: 221 / 255, green: 219 / 255, blue: 225 / 255).opacity(0.5),
                        lineWidth: 1
                    )

            )
            .shadow(
                color: isSelected ? Color(red: 43/255, green: 217/255, blue: 156/255, opacity: 0.08) : .clear,
                radius: 8, x: 0, y: 4
            )
        }
        .buttonStyle(.plain)
        .padding(.horizontal, 4)
    }
}

struct PaywallFiveFreeTrialToggle: View {
    @Binding var isOn: Bool

    private var isPad: Bool { UIDevice.current.userInterfaceIdiom == .pad }
    private var padScale: CGFloat { isPad ? 1.3 : 1.0 }

    var body: some View {
        HStack {
            Text("Free Trial Enabled")
                .font(.system(size: 16 * padScale, weight: .medium))
                .foregroundStyle(.black)

            Spacer()

            Toggle("", isOn: $isOn)
                .labelsHidden()
                .tint(Color(red: 2 / 255, green: 125 / 255, blue: 244 / 255))
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(.white)
                .overlay {
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .strokeBorder(Color(red: 221 / 255, green: 219 / 255, blue: 225 / 255).opacity(0.5), lineWidth: 1)
                }
        )
        .padding(.horizontal, 4)
    }
}


struct ReviewsCardView: View {

    let reviews: [Review]
//    let reviews: [Review] = [
//        .init(text: "It saved my iPhone!",               name: "Maria",  rating: 5),
//        .init(text: "Saved me from going to repair!",    name: "Kevin",  rating: 5),
//        .init(text: "Worked better than rice!",          name: "Sophie", rating: 5)
//    ]

    private var isPad: Bool { UIDevice.current.userInterfaceIdiom == .pad }
    private var padScale: CGFloat { isPad ? 1.3 : 1.0 }


    var body: some View {
        ZStack {
            VStack(alignment: .leading, spacing: 8) {
//                ForEach(reviews) { review in
//                    HStack(alignment: .top) {
//                        VStack(alignment: .leading, spacing: 4) {
//                            StarsView(rating: review.rating)
//
//                            Text(review.text)
//                                .font(.custom("Montserrat-Bold", size: 14))
//                                .foregroundColor(.black)
//                        }
//
//                        Spacer()
//
//                        Text(review.name)
//                            .font(.custom("Montserrat-Medium", size: 14))
//                            .foregroundColor(.black)
//                            .padding(.top, 2) // трохи вирівняти по вертикалі
//
//                    }
//                }

                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 4) {
                        StarsView(rating: reviews[0].rating)

                        Text(reviews[0].text)
                            .font(.custom("Montserrat-Bold", size: 14 * padScale))
                            .foregroundColor(.black)
                    }

                    Spacer()

                    Text(reviews[0].name)
                        .font(.custom("Montserrat-Medium", size: 14 * padScale))
                        .foregroundColor(.black)
                        .padding(.top, 2) // трохи вирівняти по вертикалі

                }


                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 4) {
                        StarsView(rating: reviews[1].rating)

                        Text(reviews[1].text)
                            .font(.custom("Montserrat-Bold", size: 14 * padScale))
                            .foregroundColor(.black)
                    }

                    Spacer()

                    Text(reviews[1].name)
                        .font(.custom("Montserrat-Medium", size: 14 * padScale))
                        .foregroundColor(.black)
                        .padding(.top, 2) // трохи вирівняти по вертикалі

                }


                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 4) {
                        StarsView(rating: reviews[2].rating)

                        Text(reviews[2].text)
                            .font(.custom("Montserrat-Bold", size: 14 * padScale))
                            .foregroundColor(.black)
                    }

                    Spacer()

                    Text(reviews[2].name)
                        .font(.custom("Montserrat-Medium", size: 14 * padScale))
                        .foregroundColor(.black)
                        .padding(.top, 2) // трохи вирівняти по вертикалі

                }






            }
            .padding(16)
        }
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(Color.white)
                .shadow(color: .black.opacity(0.06), radius: 20, x: 0, y: 8)
        )
        .compositingGroup()
    }
}

struct FeatureItem: Identifiable {
    let id = UUID()
    let emoji: String
    let text: String
}

struct FeaturesCardView: View {

    private var isPad: Bool { UIDevice.current.userInterfaceIdiom == .pad }
    private var padScale: CGFloat { isPad ? 1.3 : 1.0 }

    private let items: [FeatureItem] = [
        .init(emoji: "🎛️", text: String(localized: "All sound & dB tools unlocked")),
        .init(emoji: "🔊", text: String(localized: "Unlimited cleaning cycles")),
        .init(emoji: "🚫", text: String(localized: "No ads, premium experience"))
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            ForEach(items) { item in
                HStack(alignment: .center, spacing: 12) {
                    Text(item.emoji)
                        .font(.system(size: 28 * padScale))

                    Text(item.text)
                        .font(.custom("Montserrat-SemiBold", size: 18 * padScale))
                        .foregroundColor(.black)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(Color.white)
                .shadow(color: .black.opacity(0.06), radius: 20, x: 0, y: 8)
        )
    }
}

struct StatisticCardView: View {

    private var isPad: Bool { UIDevice.current.userInterfaceIdiom == .pad }
    private var padScale: CGFloat { isPad ? 1.3 : 1.0 }

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {

            HStack(alignment: .center, spacing: 20) {

                Image("Left")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 80 * padScale)

                VStack(spacing: 6) {
                    Text("MORE THAN")
                        .font(.custom("Montserrat-SemiBold", size: 20 * padScale))
                        .foregroundColor(.black)
                        //.fixedSize(horizontal: false, vertical: true)

                    Text("1,000,000")
                        .font(.custom("Montserrat-Bold", size: 20 * padScale))
                        .foregroundColor(.black)
                        //.fixedSize(horizontal: false, vertical: true)

                    Text("SATISFIED USERS")
                        .font(.custom("Montserrat-SemiBold", size: 20 * padScale))
                        .foregroundColor(.black)
                        //.fixedSize(horizontal: false, vertical: true)
                }


                Image("Right")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 80 * padScale)


            }

        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(Color.white)
                .shadow(color: .black.opacity(0.06), radius: 20, x: 0, y: 8)
        )
    }
}


//#Preview {
//    ZStack {
//        Color(red: 239/255, green: 244/255, blue: 248/255).ignoresSafeArea()
//        StatisticCardView()
//            .padding()
//    }
//}

#Preview(body: {
    PaywallFiveView(onFinish: {print("hello")})
})
