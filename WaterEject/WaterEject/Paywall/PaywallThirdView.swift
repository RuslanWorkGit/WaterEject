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
//    @State private var player: AVPlayer = {
////        let url = Bundle.main.url(forResource: "Video", withExtension: "mp4")!
//        let url = Bundle.main.url(forResource: "NewVideo", withExtension: "mp4")!
//        return AVPlayer(url: url)
//    }()
    @State private var player = AVQueuePlayer()
    @State private var playerLooper: AVPlayerLooper?
    @State private var isExiting = false
    
    @State private var appearVideo = false
    @State private var appearTitle = false
    @State private var appearList  = false
    @State private var appearCards = false
    @State private var startDelay: Double = 0.35
    
    
    let onFinish: () -> Void
    private let exitDuration: Double = 0.6
    
    
    var body: some View {
        
        let isSmall = UIScreen.main.bounds.height < 700
        let isLarge = UIScreen.main.bounds.height > 900
        
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
                    .padding(.bottom, 12)
                    .padding(.top, 20)
                    
                    //.opacity(appearTitle ? 1 : 0)
//                    .offset(y: appearTitle ? 0 : 8)
//                    .animation(.easeOut(duration: 0.45), value: appearTitle)
                    
                    VStack(spacing: isSmall ? 8 : 12) {
                        HorizontalThirdText(title: "Auto & Manual cleaning modes", image: "slider.vertical.3")
                        HorizontalThirdText(title: "5 pro-level sound tests", image: "powermeter")
                        HorizontalThirdText(title: "Scientifically proven methods", image: "graduationcap")
                        HorizontalThirdText(title: "All future features + No Ads", image: "sparkles")
                    }
                    .padding(.leading, 80)
                    
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
                            onTap: { viewModel.selectedPlan = .weekly }
                        )
                        PaywallThirdPlanCard(
                            title: PaywallPlan.yearly.title,
                            price: viewModel.pricePerPeriod[.yearly] ?? "…",
                            sublabel: "Best Value",
                            saveText: viewModel.onlyPrice[.yearly] ?? "",
                            isSelected: viewModel.selectedPlan == .yearly,
                            onTap: { viewModel.selectedPlan = .yearly }
                        )
                    }
                    .padding(.top, isSmall ? 12 : isLarge ? 60 : 40)
                    .padding(.horizontal, 14)
                    .padding(.bottom, isSmall ? 12 : isLarge ? 48 : 36)
            
                    
//                    .opacity(appearCards ? 1 : 0)
                    //.scaleEffect(appearCards ? 1.0 : 0.99)
                    //.animation(.spring(response: 0.5, dampingFraction: 0.85), value: appearCards)
                    
                    
                    
                    Button {
                        let v = PaywallAB.shared.variant()
                        Analytics.logEvent("paywall_cta_tap", parameters: ["variant": v.rawValue])
                        
                        let plan: PaywallPlan = viewModel.selectedPlan
                        let variant = PaywallAB.shared.variant().rawValue
                        let entryPoint = paywallGate.currentContext?.rawValue ?? "unknown"
                        //let plan = viewModel.selectedPlan
                        Task {
                            await viewModel.buyWithRevenueCat(
                                plan: plan, variant: variant,
                                entryPoint: entryPoint, sessionId: sessionId
                            )
                            if viewModel.purchaseSucceeded { onFinish() }
                        }
                    } label: {
                        let forPeriod = viewModel.onlyPrice[viewModel.selectedPlan] ?? ""
                        Text("Continue \(forPeriod.isEmpty ? "" : " \(forPeriod)")")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(Color(red: 13 / 255, green: 64 / 255, blue: 46 / 266))
                        
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                        
                            .background(Color(red: 81 / 255, green: 132 / 255, blue: 234 / 255))
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                        
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 8)
                    
                    HStack {
                        Image(systemName: "checkmark.shield")
                            .foregroundColor(Color(.gray))
                        Text("Cancel Anytime. Secure with App Store.")
                            .font(.system(size: 13))
                            .foregroundStyle(Color(red: 251 / 255, green: 255 / 255, blue: 255 / 255))
//                            .foregroundColor(Color(.gray))
                            .multilineTextAlignment(.center)
                    }
                    .padding(0)
                    
                    
                    HStack(spacing: 30) {
                        Button("Restore") {
                            Task { await viewModel.restorePurchases() }
                        }
                        .font(.footnote)
                        .foregroundStyle(Color(red: 251 / 255, green: 255 / 255, blue: 255 / 255))
//                        .foregroundColor(.gray)
                        
                        Button("Terms") {
                            
                            webViewURL = URL(string: "https://docs.google.com/document/d/1L2xhXP9qKJPSP7rymbXx17-xWh5_17V_nJPBbXm1boE/edit?tab=t.0")
                            //                            isPresentingWebView = true
                            
                        }
                        .font(.footnote)
                        .foregroundStyle(Color(red: 251 / 255, green: 255 / 255, blue: 255 / 255))
//                        .foregroundColor(.gray)
                        
                        Button("Privacy") {
                            
                            webViewURL = URL(string: "https://docs.google.com/document/d/1lQQMYnybap2JyKGf7Sd8gyPD1o9FWnAqgnGKx1BnSJI/edit?tab=t.0")
                            //                            isPresentingWebView = true
                            
                        }
                        
                        .font(.footnote)
                        .foregroundStyle(Color(red: 251 / 255, green: 255 / 255, blue: 255 / 255))
//                        .foregroundColor(.gray)
                    }
                    
                    
                    
                }
                .frame(maxHeight: .infinity, alignment: .top)
                .padding(.horizontal, 16)
                .padding(.top, 16)
                .padding(.bottom, 8)
                .background(
                    AspectFillPlayerView(player: player)
                        .onAppear {
                            AudioSessionManager.activatePlayback(duckOthers: true)
                            player.isMuted = true
                            player.automaticallyWaitsToMinimizeStalling = true
                            let url = Bundle.main.url(forResource: "NewVideo", withExtension: "mp4")!
                                let item = AVPlayerItem(url: url)
                            playerLooper = AVPlayerLooper(player: player, templateItem: item)

                            player.currentItem?.preferredForwardBufferDuration = 2
                            player.seek(to: .zero, toleranceBefore: .zero, toleranceAfter: .zero)
//                            DispatchQueue.main.asyncAfter(deadline: .now() + startDelay) {
                                player.play()
//                            }
                        }
                        .onDisappear {
                            player.pause()
                            player.seek(to: .zero)
                            AudioSessionManager.deactivate()
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity /*isLarge ? 400 : 370*/)
                        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                        .offset(y: -80)
                        .allowsHitTesting(false) // ⬅︎ важливо
                )
                
                
            }
            
            Button(action: {
                let variant = PaywallAB.shared.variant().rawValue
                let entryPoint = paywallGate.currentContext?.rawValue ?? "unknown"
//                Telemetry.shared.paywallClose(
//                    variant: variant, entryPoint: entryPoint,
//                    reason: "close_button", sessionId: sessionId
//                )
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
            
            if !didLogOpen {
                Telemetry.shared.paywallBOpen()   // ⬅️ головний івент
                didLogOpen = true
            }
            Purchases.logLevel = .debug
            Task { await viewModel.loadPricing()  }
            //let v = PaywallAB.shared.variant()
            //            Analytics.logEvent("paywall_exposure", parameters: ["variant": v.rawValue])
        }
        
    }
    
}

struct HorizontalThirdText: View {
    let title: String
    let image: String
    private let color = Color(red: 81/255, green: 132/255, blue: 234/255)
    
    var body: some View {
        HStack {
            Image(systemName: image)
                .resizable()
                .frame(width: 18, height: 18)
                .foregroundStyle(Color(red: 81 / 255, green: 132 / 255, blue: 234 / 255))
                
                .padding(6)                                // розмір “піллюлі”
                .background(
                    Circle()
                        .fill(color.opacity(0.15))         // напівпрозорий круг
//                        .overlay(
//                            Circle().stroke(color.opacity(0.25), lineWidth: 1) // тонка обводка (опц.)
//                        )
                )
            Text(title)
                .font(.system(size: 17))
                .foregroundStyle(Color(red: 251 / 255, green: 255 / 255, blue: 255 / 255))
//                .foregroundStyle(Color(red: 170 / 255, green: 178 / 255, blue: 191 / 255))
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
                        Text(title)
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
//            try session.setCategory(
//                .playback,                    // ігнорує тумблер беззвучного режиму
//                mode: .moviePlayback,
//                options: duckOthers ? [.duckOthers] : [] // або [.mixWithOthers]
//            )
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
 

