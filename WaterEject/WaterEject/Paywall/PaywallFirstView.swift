//
//  PaywallFirstView.swift
//  WaterEject
//
//  Created by Ruslan Liulka on 06.08.2025.
//
import SwiftUI
import FirebaseAnalytics
import RevenueCat


struct PaywallFirstView: View {
    
    @StateObject private var viewModel = PaywallViewModel()
    @State private var webViewURL: URL?
    //@State private var selectedPlan: Int = 1
    @State private var didLogOpen = false
    @EnvironmentObject private var paywallGate: PaywallGate
    @State private var sessionId = UUID().uuidString
    
    let onFinish: () -> Void
    let deviceImages = ["devices", "airpods", "airpodsPro", "airpodsMax", "speaker"]
    var repeatedImages: [String] {
        Array(repeating: deviceImages, count: 10).flatMap { $0 }
    }
    
    var body: some View {
        
        let isSmall = UIScreen.main.bounds.height < 700
        let isLarge = UIScreen.main.bounds.height > 900
        let secondaryPlan = viewModel.yearlyCardPlan
        
        
        ZStack(alignment: .topTrailing) {
            
            ZStack {
                Background()
                //ScrollView {
                
                VStack {
                    
                    VStack(alignment: .center) {
                        (
                            Text("Unlock Full Device Care")
                                .foregroundStyle(Color(red: 238 / 255, green: 255 / 255, blue: 236 / 255))
                            
                        )
                        .font(.system(size: 32, weight: .bold))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 24)
                        .padding(.bottom, 20)
                        
                        Text("Access all cleaning modes, 5 pro-level sound tests,and future features. Keep your device in peak condition.")
                            .font(.system(size: 14))
                            .padding(.horizontal, 32)
                            .multilineTextAlignment(.center)
                            .foregroundStyle(Color(red: 238 / 255, green: 255 / 255, blue: 236 / 255))
                            .padding(.bottom, 32)
                        
                        
                        
                        
                    }
                    .frame(maxHeight: .infinity, alignment: .top)
                    .padding(.horizontal, 12)
                    .padding(.top, 50)
                    
                    Spacer(minLength: isSmall ? 16 : isLarge ? 60 : 48)
                    
                    
                    VStack {
                        
                        
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 36) {
                                ForEach(repeatedImages.indices, id: \.self) { index in
                                    Image(repeatedImages[index])
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: 110, height: 110)
                                        .clipShape(RoundedRectangle(cornerRadius: 24))
                                }
                            }
                            .padding(.horizontal, 10)
                        }
                        .padding(.bottom, isSmall ? 8 : isLarge ? 46 : 32)
                        
                        Spacer(minLength: isSmall ? 0 : isLarge ? 36 : 24)
                        
                        VStack(spacing: 12) {
                            PaywallPlanCard(
                                title: PaywallPlan.weekly.title,
                                price: viewModel.pricePerPeriod[.weekly] ?? "...",
                                sublabel: nil,
                                isSelected: viewModel.selectedPlan == .weekly,
                                onTap: { viewModel.selectedPlan = .weekly }
                            )
                            PaywallPlanCard(
                                title: secondaryPlan.title,
                                price: viewModel.pricePerPeriod[secondaryPlan] ?? "...",
                                sublabel: String(localized: "Best Value"),
                                isSelected: viewModel.selectedPlan == secondaryPlan,
                                onTap: { viewModel.selectedPlan = secondaryPlan }
                            )
                        }
                        .padding(.top, isSmall ? 20 : isLarge ? 50 : 40)
                        .padding(.horizontal, 14)
                        .padding(.bottom, isSmall ? 16 : isLarge ? 46 : 36)
                        
                        Button {
                            let v = PaywallAB.shared.variant()
                            Analytics.logEvent("paywall_cta_tap", parameters: ["variant": v.rawValue])
                            
                            let variant = PaywallAB.shared.variant().rawValue
                                    let entryPoint = paywallGate.currentContext?.rawValue ?? "unknown"
                                    let plan = viewModel.selectedPlan
                                    Task {
//                                        await viewModel.buyWithRevenueCat(
//                                            plan: plan,
//                                            variant: variant,
//                                            entryPoint: entryPoint,
//                                            sessionId: sessionId
//                                        )
                                        if viewModel.purchaseSucceeded { onFinish() }
                                    }

                        } label: {
                            let forPeriod = viewModel.onlyPrice[viewModel.selectedPlan] ?? ""
                            Text(forPeriod.isEmpty ? String(localized: "Continue") : "\(String(localized: "Continue")) \(forPeriod)")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundStyle(Color(red: 13 / 255, green: 64 / 255, blue: 46 / 266))
                            
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                            
                                .background(Color(red: 43 / 255, green: 217 / 255, blue: 156 / 255))
                                .clipShape(RoundedRectangle(cornerRadius: 16))
                            
                        }
                        .padding(.horizontal, 24)
                        .padding(.bottom, 8)
                        
                        Text("Cancel Anytime. Secure with App Store.")
                            .font(.system(size: 13))
                            .foregroundColor(Color(.gray))
                            .multilineTextAlignment(.center)
                        
                        HStack(spacing: 12) {
                            Button("Restore") {
                                Task { await viewModel.restorePurchases() }
                            }
                            .font(.footnote)
                            .foregroundColor(.gray)
                            
                            Button("Terms") {
                                webViewURL = URL(string: "https://docs.google.com/document/d/1L2xhXP9qKJPSP7rymbXx17-xWh5_17V_nJPBbXm1boE/edit?tab=t.0")
                                
                            }
                            .font(.footnote)
                            .foregroundColor(.gray)
                            
                            Button("Privacy") {
                                webViewURL = URL(string: "https://docs.google.com/document/d/1lQQMYnybap2JyKGf7Sd8gyPD1o9FWnAqgnGKx1BnSJI/edit?tab=t.0")
                                
                            }
                            .font(.footnote)
                            .foregroundColor(.gray)
                        }
                        
                    }
                    //                    .padding(.top, 140)
                    .padding(.horizontal, 24)
                    .padding(.bottom, 24)
                    //}
                }
                
            }
            
            if PaywallAB.shared.isPaywallCloseEnabled {
                Button(action: {
                    let variant = PaywallAB.shared.variant().rawValue
                    let entryPoint = paywallGate.currentContext?.rawValue ?? "unknown"
                    Telemetry.shared.paywallClose(
                        variant: variant,
                        entryPoint: entryPoint,
                        reason: "close_button",
                        sessionId: sessionId
                    )
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
        }
        .interactiveDismissDisabled(!PaywallAB.shared.isPaywallCloseEnabled)
        .sheet(item: $webViewURL, content: { url in
            SafariView(url: url)
        })
        
        .onAppear {
            if !didLogOpen {
                Telemetry.shared.paywallAOpen()   // ⬅️ головний івент
                didLogOpen = true
            }
            Purchases.logLevel = .debug
            Task { await viewModel.loadPricing(paywallKey: "first") }
        }
    }
    
}



struct PaywallPlanCard: View {
    let title: String
    let price: String
    let sublabel: String?
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            ZStack(alignment: .leading) {
                // Основа картки
                RoundedRectangle(cornerRadius: 20)
                    .stroke(isSelected ? Color(red: 43/255, green: 217/255, blue: 156/255) : Color.clear, lineWidth: 1)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color.white.opacity(0.05))
                    )
                    .shadow(color: isSelected ? Color(red: 43/255, green: 217/255, blue: 156/255, opacity: 0.08) : .clear, radius: 8, x: 0, y: 4)
                
                // Checkmark
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(Color(red: 43/255, green: 217/255, blue: 156/255))
                        .font(.system(size: 28))
                        .padding(16)
                } else {
                    Image(systemName: "circle")
                        .foregroundColor(Color.gray.opacity(0.3))
                        .font(.system(size: 28, weight: .light))
                        .padding(16)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(LocalizedStringKey(title))
                            .font(.system(size: 20, weight: .bold))
                            .foregroundStyle(Color(red: 238 / 255, green: 255 / 255, blue: 246 / 255))
                            .lineLimit(1)
                            .minimumScaleFactor(0.65)
                            .layoutPriority(1)
                        Spacer()
                        if let sublabel = sublabel {
                            Text(sublabel)
                                .font(.system(size: 15, weight: .semibold))
                                .padding(.horizontal, 10)
                                .padding(.vertical, 4)
                                .background(Color(red: 43/255, green: 217/255, blue: 156/255).opacity(0.14))
                                .foregroundStyle(Color(red: 43/255, green: 217/255, blue: 156/255))
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                        }
                    }
                    Text(price)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(Color(red: 196 / 255, green: 196 / 255, blue: 196 / 255))
                }
                .padding(.leading, 60)
                .padding(.trailing, 18)
            }
            
        }
        .frame(maxWidth: .infinity, minHeight: 72, maxHeight: 72)
        .buttonStyle(.plain)
        .padding(.horizontal, 4)
    }
}

#Preview(body: {
    PaywallFirstView(onFinish: {print("hello")})
})
