//
//  RootView.swift
//  WaterEject
//
//  Created by Ruslan Liulka on 06.08.2025.
//

import SwiftUI

struct RootView: View {
    @AppStorage("hasSeenOnboarding") var hasSeenOnboarding: Bool = false
    @EnvironmentObject var coordinator: AppCoordinator
    @EnvironmentObject var paywallGate: PaywallGate
    
    var body: some View {
        Group {
            switch coordinator.currentScreen {
            case .boot:
                // Можна поставити свій SplashView/лого/чорний фон
                Color.black.ignoresSafeArea()
            case .paywall:
                PaywallAB.shared
                    .assignedPaywallView(onFinish: {
                        coordinator.showMainTabbar()       // ✅ закрили пейвол → таббар
                    })
                    .onAppear { paywallGate.currentContext = .startViewAuto }
            case .onboarding:
                
                
                //                OnboardingAB.shared.assignedOnboardingView() // ← ось тут
                //                    .onAppear {
                //                        print("🔥 Onboarding variant =", OnboardingAB.shared.variant().rawValue)
                //                    }
                OnboardingEntryView()
                
            case .mainTabbar:
                TabBarView()
                
            case .specialOfferFromPush:
                SpecialOfferView(
                        onFinish: {
                            coordinator.showMainTabbar()
                        },
                        placeWhereBuy: coordinator.specialOfferPlaceWhereBuy
                    )
            }
        }
        .onAppear {
            // якщо апку запустили тапом по пушу в killed-стані
            if UserDefaults.standard.bool(forKey: "launch_special_offer_from_push") {
                let placeWhereBuy = UserDefaults.standard.string(forKey: "special_offer_place_where_buy")
                    ?? "Push notification"
                coordinator.showSpecialOfferFromPush(placeWhereBuy: placeWhereBuy)
                UserDefaults.standard.set(false, forKey: "launch_special_offer_from_push")
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .specialOfferPushTapped)) { notif in
            let placeWhereBuy = notif.object as? String ?? "Push notification"
            coordinator.showSpecialOfferFromPush(placeWhereBuy: placeWhereBuy)
            UserDefaults.standard.set(false, forKey: "launch_special_offer_from_push")
        }
        .animation(nil, value: coordinator.currentScreen)
    }
}


struct OnboardingEntryView: View {
    @State private var isReady = false
    
    var body: some View {
        Group {
            if isReady {
                // тут вже можна безпечно вибирати онборд —
                // Remote Config активувався
                OnboardingAB.shared.assignedOnboardingView()
            } else {
                // простий лоадер / чорний екран / сплеш
                Color.black.ignoresSafeArea()
            }
        }
        .onAppear {
            // 1) тягнемо Remote Config
            OnboardingAB.shared.fetchRemoteConfig {
                print("🔥 RC fetched, variant =", OnboardingAB.shared.variant().rawValue)
                withAnimation(.easeInOut(duration: 0.2)) {
                    isReady = true
                }
            }
            
            // 2) фолбек на випадок, якщо мережі нема або RC не відповів
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                if !isReady {
                    print("⚠️ RC timeout, showing default onboarding")
                    isReady = true     // використає значення з setDefaults
                }
            }
        }
    }
}
