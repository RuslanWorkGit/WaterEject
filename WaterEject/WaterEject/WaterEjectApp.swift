//
//  WaterEjectApp.swift
//  WaterEject
//
//  Created by Ruslan Liulka on 24.07.2025.
//

import SwiftUI
import RevenueCat
import Firebase

@main
struct WaterEjectApp: App {
    
    init() {
        Purchases.configure(withAPIKey: "appl_lVJsBEhDCcyoBVhDgoyaBHruByh")
        FirebaseApp.configure()
        
        if FirebaseApp.app() != nil {
            print("✅ Firebase connected successfully")
        } else {
            print("❌ Firebase failed to connect")
        }
        
        PaywallAB.shared.fetchRemoteConfig()
    }
    @StateObject var coordinator = AppCoordinator()
    
    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(coordinator)
                .environmentObject(PaywallGate.shared)
        }
    }
}
