//
//  PaywallFirstView.swift
//  WaterEject
//
//  Created by Ruslan Liulka on 06.08.2025.
//
import SwiftUI
import FirebaseAnalytics


struct PaywallFirstView: View {
    
    @StateObject private var viewModel = PaywallViewModel()
    @State private var webViewURL: URL?
    @State private var isPresentingWebView = false
    //@State private var selectedPlan: Int = 1
    
    let onFinish: () -> Void
    let deviceImages = ["devices", "airpods", "airpodsPro", "airpodsMax", "speaker"]
    var repeatedImages: [String] {
        Array(repeating: deviceImages, count: 10).flatMap { $0 }
    }
    
    var body: some View {
        
        ZStack(alignment: .topTrailing) {
            
            ZStack {
                Background()
                
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
                    .frame(height: 140)
                    .padding(.top, 64)
                    .padding(.bottom, 32)
                    
                    VStack(spacing: 24) {
                        PaywallPlanCard(
                            title: "7 days",
                            price: "$3.99 per week",
                            sublabel: nil,
                            isSelected: viewModel.selectedPlan == .weekly,
                            onTap: { viewModel.selectedPlan = .weekly }
                        )
                        PaywallPlanCard(
                            title: "12 Month",
                            price: "$12.99 per year",
                            sublabel: "Best Value",
                            isSelected: viewModel.selectedPlan == .yearly,
                            onTap: { viewModel.selectedPlan = .yearly }
                        )
                    }
                    .padding(.top, 40)
                    .padding(.horizontal, 14)
                    .padding(.bottom, 42)
                    
                    Button {
                        let v = PaywallAB.shared.variant()
                        Analytics.logEvent("paywall_cta_tap", parameters: ["variant": v.rawValue])
                        
                        let plan: PaywallPlan = viewModel.selectedPlan
                                                Task {
                                                    await viewModel.buyWithRevenueCat(plan: plan)
                                                    if viewModel.purchaseSucceeded { onFinish() }
                                                }
                    } label: {
                        Text("Continue \(viewModel.selectedPlan.price)")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(Color(red: 13 / 255, green: 64 / 255, blue: 46 / 266))
                        
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                        
                            .background(Color(red: 43 / 255, green: 217 / 255, blue: 156 / 255))
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                        
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 26)
                    
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
                                isPresentingWebView = true
                        }
                        .font(.footnote)
                        .foregroundColor(.gray)
                        
                        Button("Privacy") {
                            webViewURL = URL(string: "https://docs.google.com/document/d/1lQQMYnybap2JyKGf7Sd8gyPD1o9FWnAqgnGKx1BnSJI/edit?tab=t.0")
                            isPresentingWebView = true
                            
                        }
                        .font(.footnote)
                        .foregroundColor(.gray)
                    }
                    
                }
                .padding(.top, 140)
                .padding(.horizontal, 24)
                
            }
            
            Button(action: {
                viewModel.closePaywall()
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
        .sheet(isPresented: $isPresentingWebView) {
            if let url = webViewURL {
                SafariView(url: url)
            }
        }
        .onAppear {
            let v = PaywallAB.shared.variant()
            Analytics.logEvent("paywall_exposure", parameters: ["variant": v.rawValue])
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
                        Text(title)
                            .font(.system(size: 20, weight: .bold))
                            .foregroundStyle(Color(red: 238 / 255, green: 255 / 255, blue: 246 / 255))
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
