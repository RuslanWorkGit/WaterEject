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
    @AppStorage("didAskNotifications") private var didAskNotifications = false
    @State private var lastScreen: AppCoordinator.Screen = .boot
    
    var body: some View {
        Group {
            switch coordinator.currentScreen {
            case .boot:
                // Можна поставити свій SplashView/лого/чорний фон
                BootRCView()
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
            
            lastScreen = coordinator.currentScreen
        }
        .onChange(of: coordinator.currentScreen) { newScreen in
            defer { lastScreen = newScreen }

            // ✅ тільки коли ВИЙШЛИ з онбордингу
            guard lastScreen == .onboarding, newScreen != .onboarding else { return }
            guard !didAskNotifications else { return }

            didAskNotifications = true
            SpecialOfferNotificationManager.shared.requestAuthorization()
        }
        .onReceive(NotificationCenter.default.publisher(for: .specialOfferPushTapped)) { notif in
            let placeWhereBuy = notif.object as? String ?? "Push notification"
            coordinator.showSpecialOfferFromPush(placeWhereBuy: placeWhereBuy)
            UserDefaults.standard.set(false, forKey: "launch_special_offer_from_push")
        }
        .animation(nil, value: coordinator.currentScreen)
    }
}


struct BootRCView: View {
    @EnvironmentObject var coordinator: AppCoordinator
    @State private var didProceed = false

    var body: some View {
        Color.black.ignoresSafeArea()
            .onAppear { bootstrap() }
    }

    private func bootstrap() {
        guard !didProceed else { return }

        let group = DispatchGroup()

        group.enter()
        OnboardingAB.shared.fetchRemoteConfig { group.leave() }

        group.enter()
        PaywallAB.shared.fetchRemoteConfig { group.leave() }

        group.enter()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            group.leave()
        }

        group.notify(queue: .main) { proceed() }

        DispatchQueue.main.asyncAfter(deadline: .now() + 4.0) {
            proceed() // fallback якщо немає мережі
        }
    }

    private func proceed() {
        guard !didProceed else { return }
        didProceed = true

        // ✅ після fetchAndActivate — синхронізуємо призначення
        let onbChanged = OnboardingAB.shared.syncAssignmentIfRCChanged()
        _ = OnboardingAB.shared.currentControlAssignment() // щоб одразу записати новий варіант у UserDefaults

//        // (опціонально) якщо хочеш, щоб онборд показався знову навіть тим, хто вже проходив:
//        if onbChanged {
//            UserDefaults.standard.set(false, forKey: "hasSeenOnboarding")
//        }

        coordinator.routeAfterBoot()
    }

}


struct OnboardingEntryView: View {
    @State private var isReady = false
    
    var body: some View {
        Group {
            if isReady {
                // тут вже можна безпечно вибирати онборд —
                // Remote Config активувався на boot screen
                OnboardingAB.shared.assignedOnboardingView()
            } else {
                // простий лоадер / чорний екран / сплеш
                Color.black.ignoresSafeArea()
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                print("🔥 onboarding =", OnboardingAB.shared.selectedControlFlowId())
                withAnimation(.easeInOut(duration: 0.2)) {
                    isReady = true
                }
            }
        }
    }
}
