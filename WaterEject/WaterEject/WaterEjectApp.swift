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
import UserNotifications


final class RCDelegateProxy: NSObject, PurchasesDelegate {
    static let shared = RCDelegateProxy()
    func purchases(_ purchases: Purchases, receivedUpdated customerInfo: CustomerInfo) {
        SubscriptionMonitor.shared.process(customerInfo: customerInfo)
    }
}

// MARK: - AppDelegate
final class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {
//    private let appsFlyerDevKey = "mxUTQbads3dmAtKCADioKm"
//    private let appleAppID      = "6749094272" // без префікса "id"
    
    private var lastAFStartTs: TimeInterval = 0

    // 👇 додано: прапорці для контролю start_app
    var sentStartAppThisForeground = false
    var isColdLaunch = true
    var isProUser: Bool = false
    weak var coordinator: AppCoordinator?

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
                
                let active = info.entitlements["pro_user"]?.isActive == true
                        self.isProUser = active
            } catch {
                print("CustomerInfo fetch error:", error.localizedDescription)
            }
        }


        // 1) Конфігурація AppsFlyer 
        let af = AppsFlyerLib.shared()
//        af.appsFlyerDevKey = appsFlyerDevKey
//        af.appleAppID = appleAppID
        af.customerUserID = Purchases.shared.appUserID
        #if DEBUG
        af.isDebug = false
        #endif

        startAppsFlyer()

        // 3) Одноразовий кастомний івент "install" — ПІСЛЯ configure()
        sendInstallIfNeeded()
        
        let center = UNUserNotificationCenter.current()
        center.delegate = self

        // 🔹 2. Запит дозволу на локальні пуші (можеш перенести після онбордингу, якщо хочеш)
        SpecialOfferNotificationManager.shared.requestAuthorization()

        return true
    }
    
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        let request = response.notification.request
        let userInfo = request.content.userInfo
        let id = request.identifier

        // наш локальний оффер-пуш
        let isSpecialById       = (id == LocalNotificationId.specialOffer)
        let isSpecialByUserInfo = (userInfo["special_offer"] as? Bool) == true

        if isSpecialById || isSpecialByUserInfo {
            // 1) для холодного запуску — флаг в UserDefaults
            UserDefaults.standard.set(true, forKey: "launch_special_offer_from_push")

            // 2) якщо апка вже жива — кинемо подію через NotificationCenter
            NotificationCenter.default.post(name: .specialOfferPushTapped, object: nil)

            // 3) extra-safety: якщо координатор уже під’єднаний — можна одразу показати
            if let coordinator {
                Task { @MainActor in
                    coordinator.showSpecialOfferFromPush()
                }
            }
        }

        completionHandler()
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


        // запускаємо SDK (але НЕ прив’язуємо start_app до completion)
        AppsFlyerLib.shared().start()

        // як і було: підтягнути CustomerInfo
        Task { @MainActor in
            if let info = try? await Purchases.shared.customerInfo() {
                SubscriptionMonitor.shared.process(customerInfo: info)
                
                let active = info.entitlements["pro_user"]?.isActive == true
                           self.isProUser = active
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

        OnboardingAB.shared.fetchRemoteConfig()
        PaywallAB.shared.fetchRemoteConfig()
    }

    var body: some Scene {
        WindowGroup {
//            SpecialOfferView(onFinish: {print("hell")}, onboardId: "1")
//                .environmentObject(PaywallGate.shared)
            RootView()
                .environmentObject(coordinator)
                .environmentObject(PaywallGate.shared)
                .onAppear {
                                    // 👇 тут з’єднуємо делегат і координатор
                                    appDelegate.coordinator = coordinator
                                }
        }
        .onChange(of: scenePhase) { oldPhase, newPhase in
            switch newPhase {
            case .active:
                SpecialOfferNotificationManager.shared.cancelSpecialOffer()
                
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
                
                if appDelegate.isProUser {
                            // якщо Pro — ніяких офферів
                            SpecialOfferNotificationManager.shared.cancelSpecialOffer()
                        } else {
                            // юзер без підписки — плануємо оффер
                            SpecialOfferNotificationManager.shared.scheduleSpecialOffer(after: 1 * 60)
                        }
                
               // SpecialOfferNotificationManager.shared.scheduleSpecialOffer(after: 1 * 60)

            default:
                break
            }
        }
    }
}
