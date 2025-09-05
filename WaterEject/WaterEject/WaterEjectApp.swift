//
//  WaterEjectApp.swift
//  WaterEject
//
//  Created by Ruslan Liulka on 24.07.2025.
//

import SwiftUI
import RevenueCat
import Firebase
import FirebaseFirestore

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
        
        if let path = Bundle.main.path(forResource: "GoogleService-Info-Shared", ofType: "plist"),
               let opts = FirebaseOptions(contentsOfFile: path) {
                FirebaseApp.configure(name: "SharedCatalog", options: opts)
            }
        
        let sharedApp = FirebaseApp.app(name: "SharedCatalog")
        let sharedDB  = Firestore.firestore(app: sharedApp!)

        sharedDB.collection("apps").getDocuments { snap, err in
            print("shared apps ids =", snap?.documents.map{$0.documentID} ?? [], "err:", err as Any)
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
