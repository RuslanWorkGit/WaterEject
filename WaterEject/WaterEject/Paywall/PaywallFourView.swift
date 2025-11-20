//
//  PaywallFourView.swift
//  WaterEject
//
//  Created by Ruslan Liulka on 20.11.2025.
//

import SwiftUI
import FirebaseAnalytics
import RevenueCat
import AVFoundation

struct PaywallFourView: View {
    
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
    
    @State private var isFreeTrialEnabled = true
    
    @State private var pulse = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    
    
    
    
    let onFinish: () -> Void
    let onboardId: String?
    let summaryTag: OnboardTag?     // ⬅️ нове: для "Onbord_v_3.x"
    let stepsVisited: [String]?     // ⬅️ нове: пройдені екрани
    private let exitDuration: Double = 0.6
    
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
            let variant = PaywallAB.shared.variant().rawValue
            let entry   = paywallGate.currentContext?.rawValue ?? "unknown"
            Telemetry.shared.onbFlowSummary(
                onboard: tag,
                steps: stepsVisited ?? [],
                paywallId: "paywall_v_3.0",
                plan: (status == .success ? plan.analyticsValue : nil), // ← лише для success
                status: status,
                entryPoint: entry
            )
            OnboardingSessionStore.shared.clear()
        } else {
            // ⬇️ НЕ онбординг: якщо пейвол відкрито з Modes — логнемо modes_paywall
            if paywallGate.currentContext == .modesTap {
                Telemetry.shared.modesPaywall(
                    status: status,
                    plan: status == .success ? plan.analyticsValue : nil,
                    paywallId: "paywall_v_3.0",
                    onboard: .modes)
                
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
                    
                    Spacer()
                    
                    
                    (
                        Text("Remove Water Fast")
                            .foregroundStyle(Color(red: 2 / 255, green: 125 / 255, blue: 244 / 255))
                        
                    )
                    .font(.system(size: 38, weight: .semibold))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 16)
                    .padding(.bottom, 0)
                    .padding(.top, 12)
                    
                    GeometryReader { geo in
                        let screenW = geo.size.width
                        let pad = max((screenW - featuresWidth) / 2, 16)
                  
                            
                            VStack(spacing: isSmall ? 4 : isLarge ? 8 : 4) {
                                HorizontalFourText(title: "Auto & Manual cleaning modes", image: "slider.vertical.3", isLarge: isLarge)
                                HorizontalFourText(title: "5 pro-level sound tests", image: "gauge.open.with.lines.needle.33percent", isLarge: isLarge)
                                HorizontalFourText(title: "All future features + No Ads", image: "sparkles", isLarge: isLarge)
                            }
                            .fixedSize(horizontal: true, vertical: true)   // важливо: беремо фактичну ширину контенту
                            .onSizeChange { featuresWidth = $0.width }      // зчитуємо ширину
                            .padding(.horizontal, pad)
                            //.frame(width: screenW, alignment: .top)
                            
                        
                        
                        //                        .frame(width: screenW, height: geo.size.height, alignment: .top)
                        
                        
                    }
                    .frame(height: 110)

                    .offset(y: appearList ? 0 : 10)
                    .animation(.easeOut(duration: 0.5), value: appearList)
                    
                   
                    
                    
                    //Spacer()
                    
                    VStack(spacing: 12) {
                        HStack {
                            Text("Free Trial Enable")
                                .font(.system(size: 16))
                                .foregroundStyle(.black)
                            
                            Spacer()
                            
                            Toggle("", isOn: $isFreeTrialEnabled)
                                   .labelsHidden()
                                   .tint(Color(red: 2 / 255, green: 125 / 255, blue: 244 / 255))
                                   .disabled(viewModel.selectedPlan == .yearly)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .fill(.white)
                                .overlay(content: {
                                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                                        .strokeBorder(Color(red: 221 / 255, green: 219 / 255, blue: 225 / 255).opacity(0.5), lineWidth: 1)
                                })
                        )
                        
                        PaywallFourPlanCard(
                            title: PaywallPlan.weekly.title,
                            price: viewModel.pricePerPeriod[.weekly] ?? "...",
                            sublabel: nil,
                            saveText: viewModel.onlyPrice[.weekly] ?? "",
                            isSelected: viewModel.selectedPlan == .weekly,
                            onTap: { viewModel.selectedPlan = .weekly }
                        )
                        
                        PaywallFourPlanCard(
                            title: PaywallPlan.yearly.title,
                            price: viewModel.pricePerPeriod[.yearly] ?? "…",
                            sublabel: "Best Value",
                            saveText: viewModel.onlyPrice[.yearly] ?? "",
                            isSelected: viewModel.selectedPlan == .yearly,
                            onTap: { viewModel.selectedPlan = .yearly }
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
                        Task {
                            let paywallId = "paywall_v_3.0"
                            await viewModel.buyWithRevenueCat(
                                plan: plan, variant: variant, entryPoint: entry, sessionId: sessionId, onboardId: onboardId, paywallId: paywallId
                            )
                            if viewModel.purchaseSucceeded {
                                Telemetry.shared.purchaseSuccess(
                                    variant: variant, plan: plan.analyticsValue,
                                    packageId: plan.analyticsValue, // або свій packageId
                                    sessionId: sessionId,
                                    onboardId: onboardId
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
                //                let variant = PaywallAB.shared.variant().rawValue
                //                let entryPoint = paywallGate.currentContext?.rawValue ?? "unknown"
                //                                Telemetry.shared.paywallClose(
                //                                    variant: variant, entryPoint: entryPoint,
                //                                    reason: "close_button", sessionId: sessionId
                //                                )
                
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
        .onChange(of: viewModel.selectedPlan) { _, newPlan in
            switch newPlan {
            case .weekly:
                isFreeTrialEnabled = true
            case .yearly:
                isFreeTrialEnabled = false
            }
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





struct HorizontalFourText: View {
    let title: String
    let image: String
    let isLarge: Bool
    private let color = Color(red: 2 / 255, green: 125 / 255, blue: 244 / 255)
    
    var body: some View {
        HStack {
            Image(systemName: image)
                .resizable()
                .frame(width: 18, height: 18)
                .foregroundStyle(Color(red: 2 / 255, green: 125 / 255, blue: 244 / 255))
            
                .padding(6)
                .background(
                    Circle()
                        .fill(color.opacity(0.15))
                )
            Text(title)
                .font(.system(size: isLarge ? 20 : 17))
                .foregroundStyle(Color(red: 65 / 255, green: 67 / 255, blue: 72 / 255))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    
}

struct PaywallFourPlanCard: View {
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
                        .font(.system(size: 10))
                        .foregroundStyle(Color(red: 196/255, green: 196/255, blue: 197/255))
                    
                }
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


//#Preview(body: {
//    PaywallFourView(onFinish: {print("hello")})
//})
