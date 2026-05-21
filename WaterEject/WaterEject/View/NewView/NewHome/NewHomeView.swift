//
//  NewStartView.swift
//  WaterEject
//
//  Created by Ruslan Liulka on 23.12.2025.
//
//
//  HomeView.swift
//  WaterEject
//
//  Created by Ruslan Liulka on 01.08.2025.
//

import SwiftUI
import RevenueCat


enum NewRoute: Hashable {
    case sevenDaysModes
    case sevenDaysStart(NewCleaningMode)
}

struct NewHomeView: View {
    //@State private var showModesScreen = false
    @EnvironmentObject private var tabBarState: TabBarState
    @State private var selectedDevice: CleaningDevice?
    @State private var path: [NewRoute] = []
    @State private var didLogExposure = false
//    private var sevenDaysCompleted: Int = 0
    
    @AppStorage(SevenDayPlanProgress.daysKey)
    private var sevenDaysCompleted: Int = 0
    
    @State private var showSpecialOffer = false
    @State private var didCheckSpecialOffer = false
    
    private let sevenDaysDefaultDevice: CleaningDevice = .iPhone
    
    @EnvironmentObject private var paywallGate: PaywallGate
    @Environment(\.dismiss) private var dismiss
    @State private var pendingMode: NewCleaningMode?

    
    var body: some View {
        let isSmall = UIScreen.main.bounds.height < 700
        let isMini = UIScreen.main.bounds.height < 850
        let isLarge = UIScreen.main.bounds.height > 900
        
        NavigationStack(path: $path) {
            ZStack {
                
                //Background()
                
                BackgroundNew()
                
                VStack(spacing: 16) {
                    HStack {
                        Text("Speaker Cleaner")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(.white)
                        Spacer()
                    }
                    .padding(.horizontal, 34)
                    .padding(.top, 16)
                    
                    
                    SevenDayPlanCardView(completedDays: sevenDaysCompleted) {
                        path.append(.sevenDaysModes)
                    }
                    .padding(.horizontal, 24)
                    
                    BigCardStartCleaningView(
                        icon: "NewWaterDrop",
                        mode: .waterRemoval,
                        day: String(localized: "Day 1"),
                        mainText: String(localized: "Water Removal"),
                        deviceIcon: "SmallWave",
                        firstHesh: String(localized: "#Clean"),
                        deviceColor: Color(red: 161/255, green: 225/255, blue: 255/255),
                        secondHesh: String(localized: "#LowFrequency"),
                        time: String.localizedStringWithFormat(String(localized: "%d seconds"), 60),
                        isSmall: isSmall,
                        onModeAction: { mode in startIfAllowed(mode) }
                    )
                    .padding(.horizontal, 24)
                    
                    TurboCleaningCardView(icon: "Lightning", mode: .waterRemoval, mainText: String(localized: "Turbo Cleaning"), secondText: String(localized: "Advanced"), isSmall: isSmall) { mode in
                        startIfAllowed(mode)
                    }
                    .padding(.horizontal, 24)
                    
                    Spacer()
                    
                    
                }
            }
            .safeAreaInset(edge: .bottom) {
                Color.clear.frame(height: 74) // висота твого таббара
            }
            
            .onAppear {
                //                Telemetry.shared.homeExposure()
                tabBarState.isHidden = false
            }   // ⟵ сховати
            
            .onChange(of: path) { _, newPath in
                // ховаємо таб-бар лише коли ми НА СТЕКУ Home (є пуш у Modes/Start)
                tabBarState.isHidden = !newPath.isEmpty
            }
            
            //            .onDisappear { tabBarState.isHidden = true }
            .navigationDestination(for: NewRoute.self) { route in
                switch route {
                case .sevenDaysModes:
                    // Передаємо колбек, який пушне StartView
                    SevenDaysModesView { mode in
                                            path.append(.sevenDaysStart(mode))
                                        }
                    
                case .sevenDaysStart(let mode):
                    NewStartView(device: sevenDaysDefaultDevice, mode: mode)
                }
            }
            .task {
                // щоб не перевіряти декілька разів при реконструкції в’ю
                guard !didCheckSpecialOffer else { return }
                didCheckSpecialOffer = true
                
                if await shouldShowSpecialOfferOnSecondLaunch() {
                    await MainActor.run {
                        showSpecialOffer = true
                    }
                }
            }
            // 🔽 сам fullScreenCover з SpecialOfferView
            .fullScreenCover(isPresented: $showSpecialOffer) {
                SpecialOfferView(
                    onFinish: { showSpecialOffer = false },
                    placeWhereBuy: "Buy on second show"
                )
                
            }
            
        }
    }
    
    private func startIfAllowed(_ mode: NewCleaningMode) {
        Task {
            pendingMode = mode
            if await paywallGate.isPro() {
               // onStart(mode)
                path.append(.sevenDaysStart(mode))
            } else {
                paywallGate.currentContext = .modesTap
                showSpecialOffer = true
            }
        }
    }
}

#Preview {
    ZStack{
        NewHomeView()
            .environmentObject(TabBarState())
    }
    
    
}

private enum AppDefaultsKeys {
    static let appOpenCount     = "app_open_count"
    static let specialOfferShown = "special_offer_shown"
}

/// Перевірка: чи треба показати SpecialOffer після другого запуску
private func shouldShowSpecialOfferOnSecondLaunch() async -> Bool {
    let defaults = UserDefaults.standard
    
    // збільшуємо лічильник відкриттів (Прив'язуємося до появи HomeView)
    let newCount = defaults.integer(forKey: AppDefaultsKeys.appOpenCount) + 1
    defaults.set(newCount, forKey: AppDefaultsKeys.appOpenCount)
    
    // тільки з 2-го запуску
    guard newCount >= 2 else { return false }
    
    // якщо вже показували оффер — більше не чіпаємо
    if defaults.bool(forKey: AppDefaultsKeys.specialOfferShown) {
        return false
    }
    
    // перевірка, що юзер ще не Pro
    do {
        let info = try await Purchases.shared.customerInfo()
        let isPro = info.entitlements["pro_user"]?.isActive == true
        if isPro { return false }
    } catch {
        // якщо не змогли отримати info — краще нічого не показувати
        return false
    }
    
    // тут всі умови виконані → відмічаємо, що оффер вже показали
    defaults.set(true, forKey: AppDefaultsKeys.specialOfferShown)
    
    // 🔽 ТУТ можна скидати лічильник, щоб оффер знову показувався через 2 заходи
    // defaults.set(0, forKey: AppDefaultsKeys.appOpenCount)
    
    return true
}

