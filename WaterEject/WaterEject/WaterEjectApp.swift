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
import FirebaseAnalytics
import AppTrackingTransparency


final class RCDelegateProxy: NSObject, PurchasesDelegate {
    static let shared = RCDelegateProxy()
    func purchases(_ purchases: Purchases, receivedUpdated customerInfo: CustomerInfo) {
        SubscriptionMonitor.shared.process(customerInfo: customerInfo)
    }
}

// MARK: - AppDelegate
final class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate, AppsFlyerLibDelegate {
    
    
    private var didHandleATT = false
    private(set) var didStartAppsFlyer = false
    
    private var attRequestAttempts = 0
    private var isRequestingATT = false
    
    private func requestATTThenStartTrackingIfNeeded() {
        if #available(iOS 14, *) {

            // ✅ only request when app is really active (otherwise iOS may not show the prompt)
            guard UIApplication.shared.applicationState == .active else {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
                    self?.requestATTThenStartTrackingIfNeeded()
                }
                return
            }

            guard !didHandleATT else { return }
            guard !isRequestingATT else { return }

            let status = ATTrackingManager.trackingAuthorizationStatus
            print("ATT status:", status.rawValue)

            // If the user already answered (or global tracking is OFF), there will be no popup — just proceed.
            guard status == .notDetermined else {
                didHandleATT = true
                startTrackingStack()
                return
            }

            // Request — sometimes iOS returns .notDetermined if it couldn’t show the prompt yet
            isRequestingATT = true
            ATTrackingManager.requestTrackingAuthorization { [weak self] newStatus in
                DispatchQueue.main.async {
                    guard let self else { return }
                    self.isRequestingATT = false
                    print("ATT completion status:", newStatus.rawValue)

                    if newStatus == .notDetermined {
                        self.attRequestAttempts += 1

                        // retry a couple of times (e.g. when another system alert is on screen)
                        if self.attRequestAttempts <= 3 {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) { [weak self] in
                                self?.requestATTThenStartTrackingIfNeeded()
                            }
                            return
                        }

                        // give up blocking the stack — still start SDKs so analytics isn’t dead
                        self.didHandleATT = true
                        self.startTrackingStack()
                        return
                    }

                    self.didHandleATT = true
                    self.startTrackingStack()
                }
            }

        } else {
            didHandleATT = true
            startTrackingStack()
        }
    }
    
    private func startTrackingStack() {
        // ✅ стартуємо AppsFlyer тільки після ATT
        startAppsFlyer()
        didStartAppsFlyer = true

        // ✅ івенти AppsFlyer теж після ATT
        sendInstallIfNeeded()
        
        DispatchQueue.main.async { [weak self] in
               self?.logStartAppIfNeeded()
           }
    }

//    private let appsFlyerDevKey = "mxUTQbads3dmAtKCADioKm"
//    private let appleAppID      = "6749094272" // без префікса "id"
    
    private var lastAFStartTs: TimeInterval = 0
    
    private let asaKeywordKey = "asaKeywordId"
    private let asaKeywordTextKey = "asaKeywordText"
    private var didLogKeywordOnStart = false

    // 👇 додано: прапорці для контролю start_app
    var sentStartAppThisForeground = false
    var isColdLaunch = true
    var isProUser: Bool = false
    weak var coordinator: AppCoordinator?

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil
    ) -> Bool {
        
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                    self.logStoredKeywordOnStartIfNeeded()
                }

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
        
        af.delegate = self
        
        #if DEBUG
        af.isDebug = false
        #endif

        //startAppsFlyer()

        // 3) Одноразовий кастомний івент "install" — ПІСЛЯ configure()
        //sendInstallIfNeeded()
        //self.logStoredKeywordOnStartIfNeeded()
        
        let center = UNUserNotificationCenter.current()
        center.delegate = self


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
        
        let isSpecialByUserInfo = (userInfo["special_offer"] as? Bool) == true

        // Визначаємо source для placeWhereBuy
        var placeWhereBuy = "Push notification 5 min"
        if id == LocalNotificationId.specialOfferAfter7Days {
            placeWhereBuy = "7 days notification buy"
        }

        let isSpecial =
            id == LocalNotificationId.specialOfferAfterClose ||
            id == LocalNotificationId.specialOfferAfter7Days ||
            isSpecialByUserInfo

        if isSpecial {
            // 1) для холодного запуску — флаг + source в UserDefaults
            UserDefaults.standard.set(true, forKey: "launch_special_offer_from_push")
            UserDefaults.standard.set(placeWhereBuy, forKey: "special_offer_place_where_buy")

            // 2) якщо апка вже жива — NotificationCenter
            NotificationCenter.default.post(
                name: .specialOfferPushTapped,
                object: placeWhereBuy
            )

            // 3) якщо координатор вже є — показуємо одразу
            if let coordinator {
                Task { @MainActor in
                    coordinator.showSpecialOfferFromPush(placeWhereBuy: placeWhereBuy)
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
        AppsFlyerLib.shared().logEvent("first_open", withValues: values)
        UserDefaults.standard.set(true, forKey: key)
        


    }
    
    private func logStoredKeywordOnStartIfNeeded() {
        guard !didLogKeywordOnStart else { return }
        didLogKeywordOnStart = true

        let storedId = UserDefaults.standard.string(forKey: asaKeywordKey)
        let storedText = UserDefaults.standard.string(forKey: asaKeywordTextKey)

        Telemetry.shared.keywordsLogOnStart(keywordId: storedId, keywordText: storedText)
    }
    
    func onConversionDataSuccess(_ installData: [AnyHashable : Any]) {
        let status = installData["af_status"] as? String
        guard status == "Non-organic" else { return }

        let info = extractASAKeywordInfo(from: installData)

        // якщо текст прийшов числом — майже точно це ID
        let keywordId = info.id ?? (info.text.flatMap { isAllDigits($0) ? $0 : nil })
        let keywordText = (info.text.flatMap { isAllDigits($0) ? nil : $0 })

        if let keywordId, !keywordId.isEmpty {
            UserDefaults.standard.set(keywordId, forKey: asaKeywordKey)
        } else {
            UserDefaults.standard.removeObject(forKey: asaKeywordKey)
        }

        if let keywordText, !keywordText.isEmpty {
            UserDefaults.standard.set(keywordText, forKey: asaKeywordTextKey)
        } else {
            UserDefaults.standard.removeObject(forKey: asaKeywordTextKey)
        }

        Telemetry.shared.keywordsLog(
            keywordId: keywordId,
            keywordText: keywordText,
            source: "appsFlyer_conversion"
        )
    }
    
    func onConversionDataFail(_ error: Error) {
        print("❌ AppsFlyer conversion data error:", error.localizedDescription)
    }

//    private func extractASAKeywordID(from data: [AnyHashable: Any]) -> String? {
//        // можливі ключі (залежить від інтеграції/провайдера)
//        let idKeys = ["keyword_id", "keywordId", "af_keyword_id", "af_keywordId", "af_keywordid"]
//        for k in idKeys {
//            if let v = data[k] { return String(describing: v) }
//        }
//
//        // у PDF є варіанти: af_keyword або af_keywords :contentReference[oaicite:5]{index=5} :contentReference[oaicite:6]{index=6}
//        if let v = data["af_keyword"] as? String, !v.isEmpty { return v }
//        if let v = data["af_keywords"] as? String, !v.isEmpty { return v }
//
//        return nil
//    }
    
    private func extractASAKeywordInfo(from data: [AnyHashable: Any]) -> (id: String?, text: String?) {
        let idKeys = ["keyword_id", "keywordId", "af_keyword_id", "af_keywordId", "af_keywordid"]
        var id: String?
        for k in idKeys {
            if let v = data[k] { id = String(describing: v); break }
        }

        // можливі ключі з “людським” текстом (залежить від інтеграції)
        let textKeys = ["keyword", "keyword_text", "asa_keyword", "asaKeyword", "search_term", "af_keyword", "af_keywords"]
        var text: String?
        for k in textKeys {
            if let v = data[k] as? String, !v.isEmpty { text = v; break }
            if let v = data[k], !(v is NSNull) {
                let s = String(describing: v)
                if !s.isEmpty { text = s; break }
            }
        }

        return (id, text)
    }
    
    private func isAllDigits(_ s: String) -> Bool {
        !s.isEmpty && s.allSatisfy { $0.isNumber }
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {


        // запускаємо SDK (але НЕ прив’язуємо start_app до completion)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.requestATTThenStartTrackingIfNeeded()
        }
        //AppsFlyerLib.shared().start()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            self.logStoredKeywordOnStartIfNeeded()
        }

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
    
    private func logStartAppIfNeeded() {
        guard didStartAppsFlyer else { return }
        guard !sentStartAppThisForeground else { return }

        let payload: [String: Any] = [
            "session_kind": isColdLaunch ? "cold" : "warm",
            "app_version": Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "",
            "build": Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "",
            "os": UIDevice.current.systemVersion
        ]

        AppsFlyerLib.shared().logEvent("start_app", withValues: payload)
        sentStartAppThisForeground = true
        isColdLaunch = false
    }
    
    func sceneBecameActive() {
        print("sceneBecameActive fired ✅")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
                self?.requestATTThenStartTrackingIfNeeded()
            }
        //logStartAppIfNeeded()
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
        
        Analytics.setAnalyticsCollectionEnabled(false)
        
        if let path = Bundle.main.path(forResource: "GoogleService-Info-Shared", ofType: "plist"),
           let opts = FirebaseOptions(contentsOfFile: path) {
            FirebaseApp.configure(name: "SharedCatalog", options: opts)
        }

        let sharedApp = FirebaseApp.app(name: "SharedCatalog")
        let sharedDB  = Firestore.firestore(app: sharedApp!)
        sharedDB.collection("apps").getDocuments { snap, err in
            print("shared apps ids =", snap?.documents.map { $0.documentID } ?? [], "err:", err as Any)
        }

//        OnboardingAB.shared.fetchRemoteConfig()
//        PaywallAB.shared.fetchRemoteConfig()
    }

    var body: some Scene {
        WindowGroup {
//            SpecialOfferView(onFinish: {print("hell")}, onboardId: "1")
//                .environmentObject(PaywallGate.shared)
            RootView()
                .environmentObject(coordinator)
                .environmentObject(PaywallGate.shared)
                .environmentObject(ReviewFlowManager.shared)
                .onAppear {
                                    // 👇 тут з’єднуємо делегат і координатор
                                    appDelegate.coordinator = coordinator
                                }
        }
        .onChange(of: scenePhase) { oldPhase, newPhase in
            switch newPhase {
            case .active:
                SpecialOfferNotificationManager.shared.cancelAllSpecialOffers()
                
                appDelegate.sceneBecameActive()

            case .background:
                
                appDelegate.sentStartAppThisForeground = false
                
                if appDelegate.isProUser {
                            // якщо Pro — ніяких офферів
                    SpecialOfferNotificationManager.shared.cancelAllSpecialOffers()
                        } else {
                            // юзер без підписки — плануємо оффер
                            SpecialOfferNotificationManager.shared.scheduleAfterClose()
                                                // 7 днів неактивності
                                                SpecialOfferNotificationManager.shared.scheduleAfter7Days()
                        }
                
               // SpecialOfferNotificationManager.shared.scheduleSpecialOffer(after: 1 * 60)

            default:
                break
            }
        }
    }
}
