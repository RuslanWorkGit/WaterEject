//
//  Coordinator.swift
//  WaterEject
//
//  Created by Ruslan Liulka on 06.08.2025.
//

import Combine
import SwiftUI


@MainActor
final class AppCoordinator: ObservableObject {
    
    enum Screen {
        case boot
        case paywall
        case onboarding
        case mainTabbar
    }

    
    @Published var currentScreen: Screen = .boot
    @AppStorage("hasSeenOnboarding") var hasSeenOnboarding: Bool = false
//    @AppStorage("onb_last_shown_ts") private var onbLastShownTS: Double = 0
    
    init() {
        // Якщо користувач не бачив онбординг — показати його, інакше Home
        Task { [weak self] in
            guard let self else { return }
            if await PaywallGate.shared.isPro() {
                self.currentScreen = .mainTabbar
                return
            }
            if !hasSeenOnboarding /*|| self.shouldResurfaceOnboarding() */{
                self.currentScreen = .onboarding
            } else {
                self.currentScreen = .paywall
            }
        }
    }
    
//    private func shouldResurfaceOnboarding(now: Date = .init()) -> Bool {
//        guard onbLastShownTS > 0 else { return true } // ще жодного показу – показати
//        let elapsed = now.timeIntervalSince1970 - onbLastShownTS
//        return elapsed >= OnboardingConfig.cooldown
//    }
//    
    func showOnboarding() {
        if !hasSeenOnboarding {
            currentScreen = .onboarding
        }
        
    }
    
    func showMainTabbar() {
        currentScreen = .mainTabbar
    }
    

}


