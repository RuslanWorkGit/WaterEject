//
//  Coordinator.swift
//  WaterEject
//
//  Created by Ruslan Liulka on 06.08.2025.
//

import Combine
import SwiftUI

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
            currentScreen = .mainTabbar
        } else {
            currentScreen = .onboarding
        }
    }
    
    func showOnboarding() {
        currentScreen = .onboarding
    }
    
    func showMainTabbar() {
        currentScreen = .mainTabbar
    }
}
