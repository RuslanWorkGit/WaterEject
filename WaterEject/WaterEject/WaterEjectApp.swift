//
//  WaterEjectApp.swift
//  WaterEject
//
//  Created by Ruslan Liulka on 24.07.2025.
//
//


//  WaterEjectApp.swift
//  WaterEject

import SwiftUI
import RevenueCat
import Firebase
import FirebaseFirestore
import AppsFlyerLib


final class RCDelegateProxy: NSObject, PurchasesDelegate {
    static let shared = RCDelegateProxy()
    func purchases(_ purchases: Purchases, receivedUpdated customerInfo: CustomerInfo) {
        SubscriptionMonitor.shared.process(customerInfo: customerInfo)
    }
}

// MARK: - AppDelegate
final class AppDelegate: NSObject, UIApplicationDelegate {
    private let appsFlyerDevKey = "mxUTQbads3dmAtKCADioKm"
    private let appleAppID      = "6749094272" // без префікса "id"
    
    private var lastAFStartTs: TimeInterval = 0

    // 👇 додано: прапорці для контролю start_app
    var sentStartAppThisForeground = false
    var isColdLaunch = true

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil
    ) -> Bool {

        // 0) Спершу конфігурація RevenueCat, щоб був appUserID
        Purchases.configure(withAPIKey: "appl_lVJsBEhDCcyoBVhDgoyaBHruByh")
        
        Purchases.shared.delegate = RCDelegateProxy.shared
        
        Task { @MainActor in
            do {
                let info = try await Purchases.shared.customerInfo()
                SubscriptionMonitor.shared.process(customerInfo: info)
            } catch {
                print("CustomerInfo fetch error:", error.localizedDescription)
            }
        }

        // 1) Конфігурація AppsFlyer
        let af = AppsFlyerLib.shared()
        af.appsFlyerDevKey = appsFlyerDevKey
        af.appleAppID = appleAppID
        af.customerUserID = Purchases.shared.appUserID
        #if DEBUG
        af.isDebug = true
        #endif

        print("AF UID:", af.getAppsFlyerUID())
        print("AF customerUserID at launch:", af.customerUserID ?? "nil")
        

        // 2) Старт AF одразу після лаунчу (як і було)
        startAppsFlyer()

        // 3) Одноразовий кастомний івент "install" — ПІСЛЯ configure()
        sendInstallIfNeeded()

        return true
    }
    

    private func startAppsFlyer() {
        AppsFlyerLib.shared().start { result, error in
            if let error = error {
                print("AF start error:", error.localizedDescription)
                return
            }
            let status = (result?["status"] as? Int) ?? -1
            let type   = (result?["type"] as? String) ?? "unknown"
            print("AF start status:", status, "type:", type,
                  "customerUserID:", AppsFlyerLib.shared().customerUserID ?? "nil")
        }
    }

    /// Лог "install" лише один раз на девайс
    private func sendInstallIfNeeded() {
        let key = "af_install_sent"
        guard !UserDefaults.standard.bool(forKey: key) else { return }

        let values: [String: Any] = [
            "device_model_id": hardwareIdentifier()
        ]
        AppsFlyerLib.shared().logEvent("install", withValues: values)
        UserDefaults.standard.set(true, forKey: key)
        


    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // як і було: дебаунс старту SDK
        let now = Date().timeIntervalSince1970
        guard now - lastAFStartTs > 2 else { return }
        lastAFStartTs = now

        // запускаємо SDK (але НЕ прив’язуємо start_app до completion)
        AppsFlyerLib.shared().start { result, error in
            if let error = error {
                print("AF start error:", error.localizedDescription)
                return
            }
            let status = (result?["status"] as? Int) ?? -1
            let type   = (result?["type"] as? String) ?? "unknown"
            print("AF start status:", status, "type:", type)
        }

        // як і було: підтягнути CustomerInfo
        Task { @MainActor in
            if let info = try? await Purchases.shared.customerInfo() {
                SubscriptionMonitor.shared.process(customerInfo: info)
            }
        }
    }

    // 👇 додано: скидаємо прапорець, щоб при наступному поверненні у фокус знову надіслати start_app
    func applicationDidEnterBackground(_ application: UIApplication) {
        sentStartAppThisForeground = false
    }

    // Якщо будуть диплінки через URL-схеми:
    func application(_ app: UIApplication,
                     open url: URL,
                     options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        AppsFlyerLib.shared().handleOpen(url, options: options)
        return false
    }
    
    func hardwareIdentifier() -> String {
        var s = utsname(); uname(&s)
        return withUnsafePointer(to: &s.machine) {
            $0.withMemoryRebound(to: CChar.self, capacity: 1) { String(cString: $0) }
        }
    }
}

@main
struct WaterEjectApp: App {

    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject var coordinator = AppCoordinator()
    @Environment(\.scenePhase) private var scenePhase
    
//    private func hardwareIdentifier() -> String {
//        var s = utsname(); uname(&s)
//        return withUnsafePointer(to: &s.machine) {
//            $0.withMemoryRebound(to: CChar.self, capacity: 1) { String(cString: $0) }
//        }
//    }

    init() {
        OneTimeDefaultsReset.run(full: true)

        // Firebase
        FirebaseApp.configure()
        if let path = Bundle.main.path(forResource: "GoogleService-Info-Shared", ofType: "plist"),
           let opts = FirebaseOptions(contentsOfFile: path) {
            FirebaseApp.configure(name: "SharedCatalog", options: opts)
        }

        let sharedApp = FirebaseApp.app(name: "SharedCatalog")
        let sharedDB  = Firestore.firestore(app: sharedApp!)
        sharedDB.collection("apps").getDocuments { snap, err in
            print("shared apps ids =", snap?.documents.map { $0.documentID } ?? [], "err:", err as Any)
        }

        PaywallAB.shared.fetchRemoteConfig()
    }

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(coordinator)
                .environmentObject(PaywallGate.shared)
        }
        .onChange(of: scenePhase) { oldPhase, newPhase in
            switch newPhase {
            case .active:
                if !appDelegate.sentStartAppThisForeground {
                    let payload: [String: Any] = [
                        "session_kind": appDelegate.isColdLaunch ? "cold" : "warm",
                        "app_version": Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "",
                        "build": Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "",
                        "os": UIDevice.current.systemVersion
                    ]
                    AppsFlyerLib.shared().logEvent("start_app", withValues: payload)
                    appDelegate.sentStartAppThisForeground = true
                    appDelegate.isColdLaunch = false
                }

            case .background:
                appDelegate.sentStartAppThisForeground = false

            default:
                break
            }
        }
    }
}

//  AppDelegate + SwiftUI App
//import SwiftUI
//import AppsFlyerLib
//import RevenueCat
//import Firebase
//import FirebaseFirestore
//
//// MARK: - AppDelegate
//final class AppDelegate: NSObject, UIApplicationDelegate {
//
//    private let appsFlyerDevKey = "mxUTQbads3dmAtKCADioKm"
//    private let appleAppID      = "6749094272"     // без "id"
//
//    private var didStartThisForeground = false     // щоб не стартувати двічі за один фокус
//
//    func application(
//        _ application: UIApplication,
//        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil
//    ) -> Bool {
//
//        // 1) RevenueCat
//        Purchases.configure(withAPIKey: "appl_lVJsBEhDCcyoBVhDgoyaBHruByh")
//
//        // 2) AppsFlyer — базова конфігурація
//        let af = AppsFlyerLib.shared()
//        af.appsFlyerDevKey = appsFlyerDevKey
//        af.appleAppID      = appleAppID
//        #if DEBUG
//        af.isDebug = true
//        #endif
//
//        // 3) Прив’язуємо CUID (можна одразу — RC вже має appUserID)
//        af.customerUserID = Purchases.shared.appUserID
//
//        // 4) (не викликаємо start тут; зробимо це лише коли app стане active)
//        return true
//    }
//
//    func applicationDidBecomeActive(_ application: UIApplication) {
//        guard !didStartThisForeground else { return }
//        didStartThisForeground = true
//
//        // Якщо потрібно, оновимо CUID перед стартом (раптом змінився)
//        AppsFlyerLib.shared().customerUserID = Purchases.shared.appUserID
//
//        AppsFlyerLib.shared().start { result, error in
//            if let error = error {
//                print("AppsFlyer start error:", error.localizedDescription)
//            } else {
//                let status = (result?["status"] as? Int) ?? -1
//                let type   = (result?["type"] as? String) ?? "unknown"
//                print("AppsFlyer started. status=\(status) type=\(type)")
//            }
//        }
//    }
//
//    func applicationDidEnterBackground(_ application: UIApplication) {
//        didStartThisForeground = false
//    }
//
//    // Диплінки/Universal Links (опційно, якщо використовуєте)
//    func application(_ app: UIApplication,
//                     open url: URL,
//                     options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
//        AppsFlyerLib.shared().handleOpen(url, options: options)
//        return false
//    }
//}
//
//@main
//struct WaterEjectApp: App {
//    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
//    @Environment(\.scenePhase) private var scenePhase
//    @StateObject var coordinator = AppCoordinator()
//    
//    init() {
//            OneTimeDefaultsReset.run(full: true)
//    
//            // Firebase
//            FirebaseApp.configure()
//            if let path = Bundle.main.path(forResource: "GoogleService-Info-Shared", ofType: "plist"),
//               let opts = FirebaseOptions(contentsOfFile: path) {
//                FirebaseApp.configure(name: "SharedCatalog", options: opts)
//            }
//    
//            let sharedApp = FirebaseApp.app(name: "SharedCatalog")
//            let sharedDB  = Firestore.firestore(app: sharedApp!)
//            sharedDB.collection("apps").getDocuments { snap, err in
//                print("shared apps ids =", snap?.documents.map { $0.documentID } ?? [], "err:", err as Any)
//            }
//    
//            PaywallAB.shared.fetchRemoteConfig()
//        }
//
//    var body: some Scene {
//        WindowGroup {
//            RootView()
//                .environmentObject(coordinator)
//                .environmentObject(PaywallGate.shared)
//        }
//        .onChange(of: scenePhase) { _, newPhase in
//            // 👇 якщо хочете свій кастомний евент на кожен фокус
//            if newPhase == .active {
//                AppsFlyerLib.shared().logEvent("start_app", withValues: [
//                    "session_kind": "auto",
//                ])
//            }
//        }
//    }
//}
