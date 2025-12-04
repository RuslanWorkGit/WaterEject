//
//  SpecialPepositionView.swift
//  WaterEject
//
//  Created by Ruslan Liulka on 03.12.2025.
//

import SwiftUI
import RevenueCat

struct SpecialOfferView: View {
    
    @StateObject private var viewModel = SpecialOfferViewModel()
    @EnvironmentObject private var paywallGate: PaywallGate
    
    let onFinish: () -> Void
    let placeWhereBuy: String?
    
    @State private var sessionId = UUID().uuidString
    @State private var featuresWidth: CGFloat = 0
    @State private var webViewURL: URL?
    
    private let paywallId = "special_offer_v_1.0"
    
    var body: some View {
        let isSmall = UIScreen.main.bounds.height < 700
        let isLarge = UIScreen.main.bounds.height > 900
        
        ZStack(alignment: .topTrailing) {
            
            ZStack {
                Color.black.ignoresSafeArea()
                
                VStack(spacing: 24) {
                    
                    // HEADER
                    VStack(spacing: 8) {
                        Text("SPECIAL")
                            .font(.system(size: 28, weight: .semibold))
                            .foregroundStyle(.white)
                        
                        Text("-40%")
                            .padding(.vertical, 4)
                            .padding(.horizontal ,8)
                            .background(
                                RoundedRectangle(cornerRadius: 24, style: .continuous)
                                    .fill(Color(red: 207 / 255, green: 68 / 255, blue: 68 / 255))
                            )
                            .font(.system(size: 72, weight: .medium))
                            .foregroundStyle(.white.opacity(0.8))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 24)
                        
                    }
                    .padding(.top, 32)
                    
                    GeometryReader { geo in
                        let screenW = geo.size.width
                        let pad = max((screenW - featuresWidth) / 2, 16)
                        
                        
                        VStack(spacing: isSmall ? 4 : isLarge ? 8 : 4) {
                            HorizontalSpecialText(title: "Auto & Manual cleaning modes", image: "slider.vertical.3", isLarge: isLarge)
                            HorizontalSpecialText(title: "5 pro-level sound tests", image: "gauge.open.with.lines.needle.33percent", isLarge: isLarge)
                            HorizontalSpecialText(title: "Scientifically proven methods", image: "sparkles", isLarge: isLarge)
                            HorizontalSpecialText(title: "All future features + No Ads", image: "graduationcap", isLarge: isLarge)
                        }
                        .fixedSize(horizontal: true, vertical: true)   // важливо: беремо фактичну ширину контенту
                        .onSizeChange { featuresWidth = $0.width }      // зчитуємо ширину
                        .padding(.horizontal, pad)
                        //.frame(width: screenW, alignment: .top)
                        
                        
                        
                        //                        .frame(width: screenW, height: geo.size.height, alignment: .top)
                        
                        
                    }
                    .frame(height: 110)
                    
                    // TIMER
                    HStack(alignment: .top, spacing: 12) {
                        TimerBlockView(value: viewModel.hoursText,   label: "Hours")
                        
                        Text(":")
                            .font(.system(size: 28, weight: .bold, design: .monospaced))
                            .foregroundStyle(.white)
                            .padding(.top, 12)
                        
                        TimerBlockView(value: viewModel.minutesText, label: "Minutes")
                        
                        Text(":")
                            .font(.system(size: 28, weight: .bold, design: .monospaced))
                            .foregroundStyle(.white)
                            .padding(.top, 12)
                        
                        TimerBlockView(value: viewModel.secondsText, label: "Seconds")
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 50)
                    
                    Spacer()
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Try Water Eject for \(viewModel.weeklyOnlyPrice) per weeek")
                            .font(.system(size: 22, weight: .bold))
                            .foregroundStyle(.white)
                        
                        Text("Unlock all feature")
                            .font(.system(size: 16))
                            .foregroundStyle(Color(red: 166 / 255, green: 166 / 255, blue: 166 / 255))
                    }
                    
                    
                    
                    //Spacer()
                    
                    // CTA
                    VStack(spacing: 12) {
                        //                    Button {
                        //                        Task { await handleCTA() }
                        //                    } label: {
                        //                        HStack {
                        //                            if viewModel.isPurchasing {
                        //                                ProgressView()
                        //                                    .tint(.white)
                        //                            } else {
                        //                                Text("Subscribe Now")
                        //                                    .font(.system(size: 17, weight: .semibold))
                        //                            }
                        //                        }
                        //                        .frame(maxWidth: .infinity)
                        //                        .padding(.vertical, 16)
                        //                        .background(Color(red: 43/255, green: 217/255, blue: 156/255))
                        //                        .foregroundStyle(.black)
                        //                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                        //                    }
                        //                    .disabled(viewModel.isPurchasing)
                        SpecialButton(title: "Subscribe Now") {
                            Task { await handleCTA() }
                        }
                        .disabled(viewModel.isPurchasing)
                        
                        Text("Just \(viewModel.weeklyOnlyPrice), then \(viewModel.weeklyFullPrice) week")
                            .font(.system(size: 10))
                            .foregroundStyle(Color(red: 166 / 255, green: 166 / 255, blue: 166 / 255))
                        
                        HStack(spacing: 36) {
                            
                            Button("Terms of Service") {
                                
                                webViewURL = URL(string: "https://docs.google.com/document/d/1L2xhXP9qKJPSP7rymbXx17-xWh5_17V_nJPBbXm1boE/edit?tab=t.0")
                                
                            }
                            .font(.system(size: 10))
                            .foregroundStyle(Color(red: 166 / 255, green: 166 / 255, blue: 166 / 255))
                            
                            Button("Restore") {
                                Task { await viewModel.restorePurchases() }
                            }
                            .font(.system(size: 10))
                            .foregroundStyle(Color(red: 166 / 255, green: 166 / 255, blue: 166 / 255))
                            
                            
                            Button("Privacy Policy") {
                                
                                webViewURL = URL(string: "https://docs.google.com/document/d/1lQQMYnybap2JyKGf7Sd8gyPD1o9FWnAqgnGKx1BnSJI/edit?tab=t.0")
                                
                            }
                            
                            .font(.system(size: 10))
                            .foregroundStyle(Color(red: 166 / 255, green: 166 / 255, blue: 166 / 255))
                        }
                        
                        //                    Button {
                        //                        onFinish()
                        //                    } label: {
                        //                        Text("Maybe later")
                        //                            .font(.system(size: 15, weight: .medium))
                        //                            .foregroundStyle(.white.opacity(0.8))
                        //                    }
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 12)
                    
                    // terms/restore можна докинути окремо, якщо треба
                }
                
            }
            
            Button(action: {

                onFinish()
            }) {
                Image(systemName: "xmark")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(Color(red: 166 / 255, green: 166 / 255, blue: 166 / 255))
                    .padding(14)
            }
            .padding(.top, 20)
            .padding(.trailing, 18)
            

        }
        .task {
            await viewModel.loadPricing()
        }
        .sheet(item: $webViewURL) { url in
            SafariView(url: url)
        }
    }
    
    private func handleCTA() async {
        let variant = PaywallAB.shared.variant().rawValue
        let entry   = paywallGate.currentContext?.rawValue ?? "special_offer"
        
        
        await viewModel.buySpecialOffer(
            variant: variant,
            entryPoint: entry,
            sessionId: sessionId,
            placeWhereBuy: placeWhereBuy,
            paywallId: paywallId
        )
        
        if viewModel.purchaseSucceeded {
            // можна додати окремий summary-лог, якщо хочеш
            SpecialOfferNotificationManager.shared.cancelAllSpecialOffers()
            onFinish()
        }
    }
}

struct HorizontalSpecialText: View {
    let title: String
    let image: String
    let isLarge: Bool
    private let color = Color(red: 2 / 255, green: 125 / 255, blue: 244 / 255)
    
    var body: some View {
        HStack {
            Image(systemName: image)
                .resizable()
                .frame(width: 16, height: 16)
                .foregroundStyle(Color(red: 30 / 255, green: 215 / 255, blue: 96 / 255))
            
            
                .padding(8)
            //                .background(
            //                    RoundedRectangle(cornerRadius: 10, style: .continuous)
            //                        .fill(Color(red: 2 / 255, green: 125 / 255, blue: 244 / 255))
            ////                    Circle()
            ////                        .fill(color.opacity(0.15))
            //                )
            Text(title)
                .font(.system(size: isLarge ? 20 : 17, weight: .semibold))
                .foregroundStyle(Color(red: 238 / 255, green: 255 / 255, blue: 246 / 255))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    
}

struct SpecialButton: View {
    let title: String
    let action: () -> Void
    var arrow: Bool = false
    
    
    var body: some View {
        ZStack {
            Button(action: action) {
                Text(title)
                    .font(.custom("Manrope_SemiBold", size: 16))
                    .foregroundStyle(Color(red: 17 / 255, green: 17 / 255, blue: 17 / 255))
                    .frame(minHeight: 52)
                    .frame(maxWidth: .infinity)
                    .contentShape(RoundedRectangle(cornerRadius: 32, style: .continuous))
                
            }
            .buttonStyle(.plain)
            .background(
                VStack {
                    Capsule()
                        .fill(Color(red: 255 / 255, green: 217 / 255, blue: 168 / 255))
                        .frame(maxWidth: .infinity)
                        .offset(y: 40)
                        .blur(radius: 15)
                }
                    .clipShape(RoundedRectangle(cornerRadius: 32))
                
            )
            .background(
                RoundedRectangle(cornerRadius: 32, style: .continuous)
                    .fill(Color(red: 30 / 255, green: 215 / 255, blue: 96 / 255)) // як на скріні
                    .innerShadowNew(RoundedRectangle(cornerRadius: 32, style: .continuous), color: .white, radius: 8, offset: .zero, thickness: 6, opacity: 1)
                
                
            )
            
            
            .overlay(
                RoundedRectangle(cornerRadius: 32, style: .continuous)
                    .stroke(Color.white.opacity(0.08), lineWidth: 1) // тонка обводка (опційно)
            )
            
            // Ніжне «світло» знизу
            VStack {
                
            }
            .clipShape(RoundedRectangle(cornerRadius: 32))
            
        }
    }
}

struct TimerBlockView: View {
    let value: String
    let label: String
    
    var body: some View {
        VStack(spacing: 6) {
            Text(value)
                .font(.system(size: 32, weight: .bold, design: .monospaced)) // 👈 моноширинний шрифт
            // або так:
            // .font(.system(size: 32, weight: .bold))
            // .monospacedDigit()
                .foregroundStyle(.black)
            //.frame(minWidth: 60) // 👈 фіксуємо ширину, щоб блочок не стискався/розтягувався
                .padding(.horizontal, 18)
                .padding(.vertical, 6)
                .background(
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .fill(Color.white)
                )
            
            Text(label)
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(.white)
        }
    }
}
private struct SizePref: PreferenceKey {
    static var defaultValue: CGSize = .zero
    static func reduce(value: inout CGSize, nextValue: () -> CGSize) {
        let n = nextValue()
        value = CGSize(width: max(value.width, n.width), height: max(value.height, n.height))
    }
}

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

struct InnerShadowNew<S: Shape>: ViewModifier {
    let shape: S
    var color: Color = .white
    var radius: CGFloat = 8      // Blur (як у Figma)
    var offset: CGSize = .zero   // X/Y
    var thickness: CGFloat = 8   // “Spread” (товщина смуги всередині)
    var opacity: Double = 1
    
    func body(content: Content) -> some View {
        content.overlay(
            shape
                .stroke(color.opacity(opacity), lineWidth: thickness)
                .offset(offset)
                .blur(radius: radius)
                .mask(shape) // залишаємо лише внутрішню частину розмитого штриха
        )
    }
}

extension View {
    func innerShadowNew<S: Shape>(
        _ shape: S,
        color: Color = .white,
        radius: CGFloat = 8,
        offset: CGSize = .zero,
        thickness: CGFloat = 8,
        opacity: Double = 1
    ) -> some View {
        modifier(InnerShadowNew(shape: shape, color: color, radius: radius, offset: offset, thickness: thickness, opacity: opacity))
    }
}



#Preview {
    SpecialOfferView(onFinish: {print("hell")}, placeWhereBuy: "1")
}
