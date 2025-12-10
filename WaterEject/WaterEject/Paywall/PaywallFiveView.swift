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
    //@State private var isFreeTrialEnabled = true
    
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
        private let infoCardInterval: TimeInterval = 2.5
    
    
    
    
    
    let onFinish: () -> Void
    let onboardId: String?
    let summaryTag: OnboardTag?     // ⬅️ нове: для "Onbord_v_3.x"
    let stepsVisited: [String]?     // ⬅️ нове: пройдені екрани
    private let exitDuration: Double = 0.6
    let startAnimations: Bool
    
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
            let variant = PaywallAB.shared.variant().rawValue
            let entry   = paywallGate.currentContext?.rawValue ?? "unknown"
            Telemetry.shared.onbFlowSummary(
                onboard: tag,
                steps: stepsVisited ?? [],
                paywallId: "paywall_v_4.0",
                plan: (status == .success ? plan.analyticsValue : nil), // ← лише для success
                status: status,
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
                    paywallId: "paywall_v_4.0",
                    onboard: onboardTag,
                    entryPoint: "modes"
                )
                
            }
        }
    }
    
    var body: some View {
        
        let isSmall = UIScreen.main.bounds.height < 700
        let isLarge = UIScreen.main.bounds.height > 900
        
        ZStack(alignment: .topTrailing) {
            
            
            ZStack(alignment: .top) {
                
                Color(red: 253 / 255, green: 251 / 255, blue: 249 / 255).ignoresSafeArea()
                
                VStack(alignment: .center) {
                    
                    //Spacer()
                    
                    
                    (
                        Text("Remove Water Fast")
                            .foregroundStyle(Color(red: 2 / 255, green: 125 / 255, blue: 244 / 255))
                        
                    )
                    .font(.system(size: 38, weight: .semibold))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 16)
                    .padding(.bottom, 0)
                    .padding(.top, 180)
                    
                    
                    


                    
//                    ZStack(alignment: .top) {
//                        Group {
//                            switch currentInfoCard {
//                            case .reviews:
//                                ReviewsCardView()
//                            case .features:
//                                FeaturesCardView()
//                            case .stats:
//                                StatisticCardView()
//                            }
//                        }
//                        .id(currentInfoCard)
//                        .transition(
////                            .asymmetric(
////                                insertion: .move(edge: isForward ? .trailing : .leading)
////                                    .combined(with: .opacity),
////                                removal: .move(edge: isForward ? .leading : .trailing)
////                                    .combined(with: .opacity)
////                            )
//                            didShowFirstCard
//                                    ? .asymmetric(
//                                        insertion: .move(edge: isForward ? .trailing : .leading)
//                                            .combined(with: .opacity),
//                                        removal: .move(edge: isForward ? .leading : .trailing)
//                                            .combined(with: .opacity)
//                                      )
//                                    : .identity
//                        )
//                        .frame(maxWidth: .infinity,
//                               maxHeight: .infinity,
//                               alignment: .top)
//                    }
//                    .frame(height: 180)
//                    .padding()
//                    //.opacity(appearReviews ? 1 : 0)
//                    .onAppear {
//                        // як тільки блок вперше з’явився – далі вже можна включати transition
//                        didShowFirstCard = true
//                    }
////                    .animation(reduceMotion ? nil : .easeInOut(duration: 0.35),
////                               value: currentInfoCard)
//                    //.contentShape(Rectangle())
//                    .gesture(
//                        DragGesture(minimumDistance: 20)
//                            .onEnded { value in
//                                let translation = value.translation.width
//                                let threshold: CGFloat = 40
//                                guard abs(translation) > threshold else { return }
//                                
//                                if translation < 0 {
//                                    // свайп ліворуч → наступна
//                                    goNextCard(animated: true)
//                                } else {
//                                    // свайп праворуч → попередня
//                                    goPreviousCard(animated: true)
//                                }
//                                
//                                restartAutoAdvance()
//                            }
//                    )
                    
                    ZStack(alignment: .top) {
                        Group {
                            switch currentInfoCard {
                            case .reviews:
                                ReviewsCardView()
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
                        .opacity(showInfoCardContent ? 1 : 0)      // ⬅️ ВАЖЛИВО
                    }
                    .frame(height: 180)
                    .padding()
                    .opacity(appearReviews ? 1 : 0)
                    .onAppear {
                        // якщо екран показується як "поточний" (без слайду) – одразу показуємо
                        if startAnimations {
                            showInfoCardContent = true
                            didShowFirstCard = true
                        }
                    }
                    .onChange(of: startAnimations) { newValue in
                        // коли OnboardingFlow закінчив слайд → дає true
                        if newValue {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                showInfoCardContent = true
                            }
                            didShowFirstCard = true
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



                    Spacer(minLength: 0)
                    
                    //Spacer()
                    
                    VStack(spacing: 12) {
                        
                        PaywallFourPlanCard(
                            title: PaywallPlan.weekly.title,
                            price: viewModel.pricePerPeriod[.weekly] ?? "...",
                            sublabel: nil,
                            saveText: viewModel.onlyPrice[.weekly] ?? "",
                            isSelected: viewModel.selectedPlan == .weekly,
                            onTap: { viewModel.selectedPlan = .weekly
                                if let onboardId = onboardId {
                                            Telemetry.shared.funnelPlanChosen(
                                                onboardId: onboardId,
                                                plan: PaywallPlan.weekly.analyticsValue
                                            )
                                        }
                            }
                        )
                        
                        PaywallFourPlanCard(
                            title: PaywallPlan.yearly.title,
                            price: viewModel.pricePerPeriod[.yearly] ?? "…",
                            sublabel: "Best Value",
                            saveText: viewModel.onlyPrice[.yearly] ?? "",
                            isSelected: viewModel.selectedPlan == .yearly,
                            onTap: { viewModel.selectedPlan = .yearly
                                if let onboardId = onboardId {
                                            Telemetry.shared.funnelPlanChosen(
                                                onboardId: onboardId,
                                                plan: PaywallPlan.yearly.analyticsValue
                                            )
                                        }
                            }
                        )
                    }
                    .padding(.top, isSmall ? 12 : isLarge ? 30 : 20)
                    //.padding(.horizontal, 14)
                    .padding(.bottom, 12)
                    
                    HStack {
                        Image(systemName: "checkmark.shield")
                            .foregroundStyle(Color(red: 131 / 255, green: 137 / 255, blue: 147 / 255))
                        Text("Cancel Anytime. Secure with App Store.")
                            .font(.system(size: 10))
                            .foregroundStyle(Color(red: 131 / 255, green: 137 / 255, blue: 147 / 255))
                            .multilineTextAlignment(.center)
                    }
                    .padding(0)
                    
                    
                    Button {
                        let variant = PaywallAB.shared.variant().rawValue
                        let entry   = paywallGate.currentContext?.rawValue ?? "unknown"
                        let plan    = viewModel.selectedPlan
                        
                        Telemetry.shared.paywallCTATap(variant: variant, entryPoint: entry,
                                                       plan: plan.analyticsValue, onboardId: onboardId)
                        
                        if let onboardId = onboardId {
                            Telemetry.shared.funnelGoToPurchase(
                                onboardId: onboardId,
                                plan: plan.analyticsValue
                            )
                        }

                        Task {
                            let paywallId = "paywall_v_5.0"
                            await viewModel.buyWithRevenueCat(
                                plan: plan, variant: variant, entryPoint: entry, sessionId: sessionId, onboardId: onboardId, paywallId: paywallId
                            )
                            if viewModel.purchaseSucceeded {
                                Telemetry.shared.purchaseSuccess(
                                    variant: variant,
                                    packageId: plan.analyticsValue, // або свій packageId
                                    sessionId: sessionId,
                                    onboardId: summaryTag?.rawValue
                                )
                                
                                logOnboardSummary(.success)
                                
                                onFinish()
                            } else {
                                
                                logOnboardSummary(.error)
                                
                                Telemetry.shared.purchaseError(
                                    variant: variant, plan: plan.analyticsValue,
                                    packageId: plan.analyticsValue,
                                    rcCode: nil, message: "cancel_or_fail",
                                    sessionId: sessionId,
                                    onboardId: onboardId
                                )
                            }                        }
                    } label: {
                        let forPeriod = viewModel.onlyPrice[viewModel.selectedPlan] ?? ""
                        Text("Continue \(forPeriod.isEmpty ? "" : " \(forPeriod)")")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(Color(red: 13 / 255, green: 64 / 255, blue: 46 / 266))
                        
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
                        
                    }
                    .opacity(appearVideo ? 1 : 0)
                    
                    .padding(.horizontal, 24)
                    .padding(.bottom, 4)
                    
          
                    
                    
                    HStack(spacing: 36) {
                        
                        
                        
                        Button("Restore") {
                            Task { await viewModel.restorePurchases() }
                        }
                        .font(.system(size: 10))
                        .foregroundStyle(Color(red: 131 / 255, green: 137 / 255, blue: 147 / 255))
                        
                        
                        Button("Terms of Service") {
                            
                            webViewURL = URL(string: "https://docs.google.com/document/d/1L2xhXP9qKJPSP7rymbXx17-xWh5_17V_nJPBbXm1boE/edit?tab=t.0")
                            
                        }
                        .font(.system(size: 10))
                        .foregroundStyle(Color(red: 131 / 255, green: 137 / 255, blue: 147 / 255))
                        
                        Button("Privacy Policy") {
                            
                            webViewURL = URL(string: "https://docs.google.com/document/d/1lQQMYnybap2JyKGf7Sd8gyPD1o9FWnAqgnGKx1BnSJI/edit?tab=t.0")
                            
                        }
                        
                        .font(.system(size: 10))
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
                logOnboardSummary(.close)
                
                Telemetry.shared.paywallClosed(source: .closeButton)
                
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
                let variant = PaywallAB.shared.variant().rawValue
                let entry = paywallGate.currentContext?.rawValue ?? "unknown"
                //Telemetry.shared.paywallExposure(variant: variant, entryPoint: entry, onboardId: onboardId)
                didLogOpen = true
                
                
            }
            Task { await viewModel.loadPricing() }
            

            withAnimation(.easeInOut(duration: 0.2)) {
                appearReviews = true
            }
            
            restartAutoAdvance()
            
        }
        .task {
            DispatchQueue.main.asyncAfter(deadline: .now() + startDelay) {
                player.play()
                withAnimation(.easeIn(duration: 0.4)) {
                    appearVideo = true
                }
            }
        }
        .onDisappear { pulse = false }
        
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
    
    var body: some View {
        HStack(spacing: 4) {
            ForEach(0..<rating, id: \.self) { _ in
                Image(systemName: "star.fill")
                    .font(.system(size: 16))
                    .foregroundColor(Color(red: 250/255, green: 204/255, blue: 21/255)) // жовтий
            }
        }
    }
}


struct ReviewsCardView: View {
    
    let reviews: [Review] = [
        .init(text: "It saved my iPhone!",               name: "Maria",  rating: 5),
        .init(text: "Saved me from going to repair!",    name: "Kevin",  rating: 5),
        .init(text: "Worked better than rice!",          name: "Sophie", rating: 5)
    ]
    
    var body: some View {
        ZStack {
            VStack(alignment: .leading, spacing: 8) {
                ForEach(reviews) { review in
                    HStack(alignment: .top) {
                        VStack(alignment: .leading, spacing: 4) {
                            StarsView(rating: review.rating)
                            
                            Text(review.text)
                                .font(.custom("Montserrat-Bold", size: 14))
                                .foregroundColor(.black)
                        }
                        
                        Spacer()
                        
                        Text(review.name)
                            .font(.custom("Montserrat-Medium", size: 14))
                            .foregroundColor(.black)
                            .padding(.top, 2) // трохи вирівняти по вертикалі
                        
                    }
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
    
    private let items: [FeatureItem] = [
        .init(emoji: "🎛️", text: "All sound & dB tools unlocked"),
        .init(emoji: "🔊", text: "Unlimited cleaning cycles"),
        .init(emoji: "🚫", text: "No ads, premium experience")
    ]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            ForEach(items) { item in
                HStack(alignment: .center, spacing: 12) {
                    Text(item.emoji)
                        .font(.system(size: 28))
                    
                    Text(item.text)
                        .font(.custom("Montserrat-SemiBold", size: 18))
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
    

    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
       
                HStack(alignment: .center, spacing: 20) {
                    
                    Image("Left")
                    
                    VStack(spacing: 8) {
                        Text("MORE THAN")
                            .font(.custom("Montserrat-SemiBold", size: 20))
                            .foregroundColor(.black)
                            .fixedSize(horizontal: false, vertical: true)
                        
                        Text("1,000,000")
                            .font(.custom("Montserrat-Bold", size: 20))
                            .foregroundColor(.black)
                            .fixedSize(horizontal: false, vertical: true)
                        
                        Text("SATISFIED USERS")
                            .font(.custom("Montserrat-SemiBold", size: 20))
                            .foregroundColor(.black)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                
                    
                    Image("Right")
  
                   
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


#Preview {
    ZStack {
        Color(red: 239/255, green: 244/255, blue: 248/255).ignoresSafeArea()
        StatisticCardView()
            .padding()
    }
}

//#Preview(body: {
//    PaywallFourView(onFinish: {print("hello")})
//})
