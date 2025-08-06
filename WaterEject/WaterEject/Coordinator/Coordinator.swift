//
//  Coordinator.swift
//  WaterEject
//
//  Created by Ruslan Liulka on 06.08.2025.
//

import Combine

final class AppCoordinator: ObservableObject {
    
    enum Screen {
        case paywall
        case onboarding
        case mainTabbar
    }

    @Published var currentScreen: Screen = .mainTabbar
    @Published var showCreateTask: Bool = false

    func showOnboarding() {
        currentScreen = .onboarding
    }

    func showMainTabbar() {
        currentScreen = .mainTabbar
    }
}
