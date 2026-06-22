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
        case specialOfferFromPush
    }

    
    @Published var currentScreen: Screen = .boot
    @Published var specialOfferPlaceWhereBuy: String = "Push notification"
    @Published var specialOfferShownText: String = SpecialOfferNotificationManager.defaultEnglishOfferText
    @Published var specialOfferTextEn: String = SpecialOfferNotificationManager.defaultEnglishOfferText
    @Published var specialOfferNotificationId: String?
    @Published var specialOfferLaunchedFromPush = false
    @AppStorage("hasSeenOnboarding") var hasSeenOnboarding: Bool = false
    
//    init() {
//        // Якщо користувач не бачив онбординг — показати його, інакше Home
//        
//        if UserDefaults.standard.bool(forKey: "launch_special_offer_from_push") {
//                    currentScreen = .specialOfferFromPush
//                    return
//                }
//        
//        Task { [weak self] in
//            guard let self else { return }
//            if await PaywallGate.shared.isPro() {
//                self.currentScreen = .mainTabbar
//                return
//            }
//            if !hasSeenOnboarding /*|| self.shouldResurfaceOnboarding() */{
//                self.currentScreen = .onboarding
//            } else {
//                self.currentScreen = .paywall
//            }
//        }
//    }
    init() {}
    
    
       
    
    func showOnboarding() {
        currentScreen = .onboarding
    }
    
    func showMainTabbar() {
        currentScreen = .mainTabbar
    }

    func onboardingDidFinish() {
        hasSeenOnboarding = true
        currentScreen = .mainTabbar
    }
    
    func routeAfterBoot() {
        Task { [weak self] in
            guard let self else { return }
            guard self.currentScreen == .boot else { return }

            if await PaywallGate.shared.isPro() {
                self.currentScreen = .mainTabbar
                return
            }
            self.currentScreen = .onboarding
        }
    }
    
    func showSpecialOfferFromPush(placeWhereBuy: String = "Push notification") {
        self.specialOfferPlaceWhereBuy = placeWhereBuy
        self.specialOfferShownText = SpecialOfferNotificationManager.defaultEnglishOfferText
        self.specialOfferTextEn = SpecialOfferNotificationManager.defaultEnglishOfferText
        self.specialOfferNotificationId = nil
        self.specialOfferLaunchedFromPush = true
        currentScreen = .specialOfferFromPush
    }

    func showSpecialOfferFromPush(_ context: SpecialOfferPushContext) {
        self.specialOfferPlaceWhereBuy = context.placeWhereBuy
        self.specialOfferShownText = context.shownText
        self.specialOfferTextEn = context.offerTextEn
        self.specialOfferNotificationId = context.notificationId
        self.specialOfferLaunchedFromPush = context.launchedFromPush
        currentScreen = .specialOfferFromPush
    }

    

}
