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
        case paywall
        case onboarding
        case mainTabbar
    }
    
    @Published var currentScreen: Screen = .mainTabbar
    @AppStorage("hasSeenOnboarding") var hasSeenOnboarding: Bool = false
    
    init() {
        // Якщо користувач не бачив онбординг — показати його, інакше Home
        if hasSeenOnboarding {
            Task { [weak self] in
                if await PaywallGate.shared.isPro() {
                    self?.currentScreen = .mainTabbar   // ✅ підписка є — одразу в таббар
                } else {
                    self?.currentScreen = .paywall      // ❌ підписки нема — показуємо пейвол
                }
            }
        } else {
            currentScreen = .onboarding
        }
    }
    
    func showOnboarding() {
        if !hasSeenOnboarding {
            currentScreen = .onboarding
        }
        
    }
    
    func showMainTabbar() {
        currentScreen = .mainTabbar
    }
}
