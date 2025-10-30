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
import AppsFlyerLib

// MARK: - AppDelegate для AppsFlyer (і, за потреби, диплінків)
final class AppDelegate: NSObject, UIApplicationDelegate {

    // ВСТАВ свої значення
    private let appsFlyerDevKey = "mxUTQbads3dmAtKCADioKm"
    private let appleAppID      = "6749094272" // напр. "1234567890"

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil
    ) -> Bool {

        // 1) Базова конфігурація AF
        let af = AppsFlyerLib.shared()
        af.appsFlyerDevKey = appsFlyerDevKey
        af.appleAppID = appleAppID

        // 2) Зв'язуємо юзерID з RevenueCat (той самий ID у всіх системах)
        af.customerUserID = Purchases.shared.appUserID
        
        print("AppsFlyer UID:", AppsFlyerLib.shared().getAppsFlyerUID())

        printIDFV()
        
        #if DEBUG
        af.isDebug = true
        #endif
        return true
    }

    // 3) Старт сесії якомога раніше (коли апка активна)
    func applicationDidBecomeActive(_ application: UIApplication) {
        AppsFlyerLib.shared().start()
    }

    // 4) (Необов’язково) якщо будуть OneLink/Universal Links
    func application(_ app: UIApplication,
                     open url: URL,
                     options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        AppsFlyerLib.shared().handleOpen(url, options: options)
        return false
    }
    
    func printIDFV() {
        if let idfv = UIDevice.current.identifierForVendor?.uuidString {
            print("IDFV:", idfv)
        } else {
            print("IDFV is nil")
        }
    }
}


@main
struct WaterEjectApp: App {
    
    // Підключаємо делегат до SwiftUI-життєвого циклу
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    init() {
        OneTimeDefaultsReset.run(full: true)
        
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
