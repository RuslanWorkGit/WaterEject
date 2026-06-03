//
//  PaywallThirdView.swift
//  WaterEject
//
//  Created by Ruslan Liulka on 26.09.2025.
//


import SwiftUI
import FirebaseAnalytics
import RevenueCat
import AVFoundation

struct PaywallThirdView: View {
    
    @StateObject private var viewModel = PaywallViewModel()
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
    
    @State private var pulse = false
    @State private var didLogChoosePlan = false
    @State private var showTransactionAbandonSpecialOffer = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    
    
    
    
    let onFinish: () -> Void
    let onboardId: String?
    let summaryTag: OnboardTag?     // ⬅️ нове: для "Onbord_v_3.x"
    let stepsVisited: [String]?     // ⬅️ нове: пройдені екрани
    private let exitDuration: Double = 0.6
    private let telemetryVariant = PaywallVariant.third.rawValue
    private let telemetryPaywallId = "paywall_v_3.0"
    
    init(onFinish: @escaping () -> Void, onboardId: String? = nil, startDelay: Double = 0.35, summaryTag: OnboardTag? = nil, stepsVisited: [String]? = nil) {
        self.onFinish = onFinish
        self.onboardId = onboardId
        self._startDelay = State(initialValue: startDelay)
        self.summaryTag = summaryTag
        self.stepsVisited = stepsVisited
    }
    
    
    private func logOnboardSummary(_ status: PaywallStatus) {
//        guard let tag = summaryTag else {
//            print("NOOOOOOOOOO SSSSSSSUMMMMMARYYYYYY TAG")
//            return }
//        let variant = PaywallAB.shared.variant().rawValue
//        let entry = paywallGate.currentContext?.rawValue ?? "unknown"
//        Telemetry.shared.onbFlowSummary(
//                onboard: tag,
//                steps: stepsVisited ?? [],
//                paywallId: "paywall_v_3.0",
//                status: status,
//                variant: variant,
//                entryPoint: entry
//            )
//            OnboardingSessionStore.shared.clear() // ⬅️ важливо
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
                        entryPoint: "modes")

                }
            }
    }
    
    var body: some View {
        
        let isSmall = UIScreen.main.bounds.height < 700
        let isLarge = UIScreen.main.bounds.height > 900
        let secondaryPlan = viewModel.yearlyCardPlan
        
        ZStack(alignment: .topTrailing) {
            
            
            ZStack(alignment: .top) {
                Background()
                
                Color.black
                    .ignoresSafeArea()
                
                
                VStack(alignment: .center) {
                    
                    
                    (
                        Text("Premium Access 👑")
                            .foregroundStyle(Color(red: 238 / 255, green: 255 / 255, blue: 236 / 255))
                        
                    )
                    .font(.system(size: 34, weight: .bold))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)
                    .padding(.bottom, 0)
                    .padding(.top, 12)
                    
                    GeometryReader { geo in
                        let screenW = geo.size.width
                        let pad = max((screenW - featuresWidth) / 2, 16)
                        VStack {

                            VStack(spacing: isSmall ? 4 : isLarge ? 8 : 4) {
                                HorizontalThirdText(title: "Auto & Manual cleaning modes", image: "slider.vertical.3", isLarge: isLarge)
                                HorizontalThirdText(title: "5 pro-level sound tests", image: "gauge.open.with.lines.needle.33percent", isLarge: isLarge)
                                HorizontalThirdText(title: "Scientifically proven methods", image: "graduationcap", isLarge: isLarge)
                                HorizontalThirdText(title: "All future features + No Ads", image: "sparkles", isLarge: isLarge)
                            }
                            .fixedSize(horizontal: true, vertical: false)   // важливо: беремо фактичну ширину контенту
                                        .onSizeChange { featuresWidth = $0.width }      // зчитуємо ширину
                                        .padding(.horizontal, pad)
                        }
                        .frame(width: screenW, height: geo.size.height, alignment: .top)
                        
                        
                    }
                    
                    //                    .opacity(appearList ? 1 : 0)
                    .offset(y: appearList ? 0 : 10)
                    .animation(.easeOut(duration: 0.5), value: appearList)
                    
                    Spacer()
                    
                    VStack(spacing: 12) {
                        PaywallThirdPlanCard(
                            title: PaywallPlan.weekly.title,
                            price: viewModel.pricePerPeriod[.weekly] ?? "...",
                            sublabel: nil,
                            saveText: viewModel.onlyPrice[.weekly] ?? "",
                            isSelected: viewModel.selectedPlan == .weekly,
                            onTap: { viewModel.selectedPlan = .weekly
                                let resolvedOnboardId = onboardId ?? OnboardTag.lastFromUserDefaults()?.rawValue ?? "unknown"
                                Telemetry.shared.funnelPlanChosen(
                                    onboardId: resolvedOnboardId,
                                    plan: PaywallPlan.weekly.analyticsValue,
                                    selectionMethod: "tap"
                                )
                                didLogChoosePlan = true
                            }
                        )
                        PaywallThirdPlanCard(
                            title: secondaryPlan.title,
                            price: viewModel.pricePerPeriod[secondaryPlan] ?? "…",
                            sublabel: String(localized: "Best Value"),
                            saveText: viewModel.onlyPrice[secondaryPlan] ?? "",
                            isSelected: viewModel.selectedPlan == secondaryPlan,
                            onTap: { viewModel.selectedPlan = secondaryPlan
                                let resolvedOnboardId = onboardId ?? OnboardTag.lastFromUserDefaults()?.rawValue ?? "unknown"
                                Telemetry.shared.funnelPlanChosen(
                                    onboardId: resolvedOnboardId,
                                    plan: secondaryPlan.analyticsValue,
                                    selectionMethod: "tap"
                                )
                                didLogChoosePlan = true
                            }
                        )
                    }
                    .padding(.top, isSmall ? 12 : isLarge ? 60 : 40)
                    .padding(.horizontal, 14)
                    .padding(.bottom, isSmall ? 12 : isLarge ? 48 : 36)
        
                    
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
                        
                        Task {
                            let result = await viewModel.buyWithRevenueCat(
                                plan: plan, variant: telemetryVariant, entryPoint: entry, sessionId: sessionId, onboardId: onboardId, paywallId: telemetryPaywallId
                            )
                            if result.isSuccess {
                                logOnboardSummary(.success)
                                onFinish()
                            } else if result.isCancelled {
                                logOnboardSummary(.abandon)
                                showTransactionAbandonSpecialOffer = true
                            } else {
                                logOnboardSummary(.error)
                            }
                        }
                    } label: {
                        let forPeriod = viewModel.onlyPrice[viewModel.selectedPlan] ?? ""
                        Text(forPeriod.isEmpty ? String(localized: "Continue") : "\(String(localized: "Continue")) \(forPeriod)")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(Color(red: 13 / 255, green: 64 / 255, blue: 46 / 266))
                        
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
     
//                            .background(Color(red: 81 / 255, green: 132 / 255, blue: 234 / 255))
                            .background(Color(red: 43 / 255, green: 217 / 255, blue: 156 / 255))
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                        
                            .scaleEffect(pulse ? 1.03 : 1.0)
                                    .shadow(
                                        color: Color(red: 43 / 255, green: 217 / 255, blue: 156 / 255)
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
                    .padding(.bottom, 8)
                    
                    HStack {
                        Image(systemName: "checkmark.shield")
                            .foregroundStyle(Color(red: 131 / 255, green: 137 / 255, blue: 147 / 255))
                        Text("Cancel Anytime. Secure with App Store.")
                            .font(.system(size: 10))
                            .foregroundStyle(Color(red: 131 / 255, green: 137 / 255, blue: 147 / 255))
                            .multilineTextAlignment(.center)
                    }
                    .padding(0)
                    
                    
                    HStack(spacing: 30) {
                        


                        Button("Restore") {
                            Task { await viewModel.restorePurchases() }
                        }
                        .font(.system(size: 10))
                        .foregroundStyle(Color(red: 131 / 255, green: 137 / 255, blue: 147 / 255))

                        
                        Button("Terms") {
                            
                            webViewURL = URL(string: "https://docs.google.com/document/d/1L2xhXP9qKJPSP7rymbXx17-xWh5_17V_nJPBbXm1boE/edit?tab=t.0")
                            
                        }
                        .font(.system(size: 10))
                        .foregroundStyle(Color(red: 131 / 255, green: 137 / 255, blue: 147 / 255))
                        
                        Button("Privacy") {
                            
                            webViewURL = URL(string: "https://docs.google.com/document/d/1lQQMYnybap2JyKGf7Sd8gyPD1o9FWnAqgnGKx1BnSJI/edit?tab=t.0")
                            
                        }
                        
                        .font(.system(size: 10))
                        .foregroundStyle(Color(red: 131 / 255, green: 137 / 255, blue: 147 / 255))
                    }
                    
                    
                    
                }
                .frame(maxHeight: .infinity, alignment: .top)
                .padding(.horizontal, 16)
                .padding(.top, 16)
                .padding(.bottom, 8)
                .background(
                    AspectFillPlayerView(player: player)
                        .opacity(appearVideo ? 1 : 0)               // ← fade-in
                        .onAppear {
                            // лише підготовка, без play()
                            AudioSessionManager.activatePlayback(duckOthers: true)
                            player.isMuted = true
                            player.automaticallyWaitsToMinimizeStalling = true
                            
                            let url = Bundle.main.url(forResource: "NewVideo", withExtension: "mp4")!
                            let item = AVPlayerItem(url: url)
                            playerLooper = AVPlayerLooper(player: player, templateItem: item)
                            
                            player.currentItem?.preferredForwardBufferDuration = 2
                            player.seek(to: .zero, toleranceBefore: .zero, toleranceAfter: .zero)
                        }
                        .onDisappear {
                            player.pause()
                            player.seek(to: .zero)
                            AudioSessionManager.deactivate()
                        }
                        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                        .offset(y: -60)
                        .allowsHitTesting(false)
                )
                
                
            }
            
            Button(action: {
//                let variant = PaywallAB.shared.variant().rawValue
//                let entryPoint = paywallGate.currentContext?.rawValue ?? "unknown"
//                                Telemetry.shared.paywallClose(
//                                    variant: variant, entryPoint: entryPoint,
//                                    reason: "close_button", sessionId: sessionId
//                                )
                
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
        
        
        .transactionAbandonSpecialOffer(
            isPresented: $showTransactionAbandonSpecialOffer,
            paywallGate: paywallGate,
            onFinish: onFinish
        )
        .sheet(item: $webViewURL) { url in
            SafariView(url: url)
        }
        .onAppear {
            if !reduceMotion { pulse = true }
            
            if !didLogOpen {
                let entry = paywallGate.currentContext?.rawValue ?? "unknown"
                let settings = PaywallAB.shared.productSettings(for: .third)
                Telemetry.shared.configurePaywallPresentation(
                    paywallId: telemetryPaywallId,
                    variant: telemetryVariant,
                    entryPoint: entry,
                    purchaseSource: Telemetry.shared.resolvedPurchaseSource(for: paywallGate.currentContext),
                    onboardId: onboardId ?? OnboardTag.lastFromUserDefaults()?.rawValue
                )
                Telemetry.shared.onboardPaywallOpen(
                    variant: telemetryVariant,
                    entryPoint: entry,
                    onboardId: onboardId ?? OnboardTag.lastFromUserDefaults()?.rawValue,
                    paywallId: telemetryPaywallId,
                    paywallKey: telemetryVariant,
                    displayedPlans: ["weekly", settings.yearlyCardPlan.rawValue],
                    defaultPlan: "weekly"
                )
                didLogOpen = true
            }
            Task { await viewModel.loadPricing(paywallVariant: .third) }
            
//            DispatchQueue.main.asyncAfter(deadline: .now() + startDelay) {
//                player.play()
//                withAnimation(.easeIn(duration: 0.3)) {
//                    appearVideo = true
//                }
//            }
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

struct HorizontalThirdText: View {
    let title: String
    let image: String
    let isLarge: Bool
    private let color = Color(red: 81/255, green: 132/255, blue: 234/255)
    
    var body: some View {
        HStack {
            Image(systemName: image)
                .resizable()
                .frame(width: 18, height: 18)
                .foregroundStyle(Color(red: 81 / 255, green: 132 / 255, blue: 234 / 255))
            
                .padding(6)
                .background(
                    Circle()
                        .fill(color.opacity(0.15))
                )
            Text(LocalizedStringKey(title))
                .font(.system(size: isLarge ? 20 : 17))
                .foregroundStyle(Color(red: 240 / 255, green: 240 / 255, blue: 240 / 255))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    
}

struct PaywallThirdPlanCard: View {
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
                    .foregroundColor(isSelected ? Color(red: 43/255, green: 217/255, blue: 156/255) : Color.gray.opacity(0.3))
                    .font(.system(size: 28, weight: .light))
                
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(LocalizedStringKey(title))
                            .font(.system(size: 20, weight: .bold))
                            .foregroundStyle(Color(red: 238/255, green: 255/255, blue: 246/255))
                        Spacer()
                        
                    }
                    Text(price)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(Color(red: 196/255, green: 196/255, blue: 196/255))
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
                        .font(.system(size: 10))
                        .foregroundStyle(Color(red: 196/255, green: 196/255, blue: 197/255))
                    
                }
            }
            .padding(.horizontal, 16)
            .frame(maxWidth: .infinity, minHeight: 72, maxHeight: 72)
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .fill(Color.black)
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .fill(Color.white.opacity(0.15))
                }
            )
            .overlay(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .stroke(
                        isSelected ? Color(red: 43/255, green: 217/255, blue: 156/255) : .clear,
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

final class PlayerView: UIView {
    override static var layerClass: AnyClass { AVPlayerLayer.self }
    var playerLayer: AVPlayerLayer { layer as! AVPlayerLayer }
}

struct AspectFillPlayerView: UIViewRepresentable {
    let player: AVPlayer
    
    func makeUIView(context: Context) -> PlayerView {
        let v = PlayerView()
        v.playerLayer.player = player
        v.playerLayer.videoGravity = .resizeAspectFill   // ключова строка — без чорних рамок
        v.playerLayer.masksToBounds = true
        return v
    }
    func updateUIView(_ uiView: PlayerView, context: Context) {
        if uiView.playerLayer.player !== player {           // ✅ guard
            uiView.playerLayer.player = player
        }
    }
}

enum AudioSessionManager {
    static func activatePlayback(duckOthers: Bool = true) {
        let session = AVAudioSession.sharedInstance()
        do {
            try session.setCategory(.playback, mode: .moviePlayback, options: [.mixWithOthers])
            
            try session.setActive(true)
        } catch {
            print("Audio session error:", error)
        }
    }
    
    static func deactivate() {
        do { try AVAudioSession.sharedInstance().setActive(false) }
        catch { print("Deactivate error:", error) }
    }
}

#Preview(body: {
    PaywallThirdView(onFinish: {print("hello")})
})
