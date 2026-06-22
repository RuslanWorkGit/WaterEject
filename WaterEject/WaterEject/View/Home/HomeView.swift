//
//  HomeView.swift
//  WaterEject
//
//  Created by Ruslan Liulka on 01.08.2025.
//

import SwiftUI
import RevenueCat


enum Route: Hashable {
    case modes(CleaningDevice)
    case start(CleaningDevice, CleaningMode)
}

struct HomeView: View {
    //@State private var showModesScreen = false
    @EnvironmentObject private var tabBarState: TabBarState
    @State private var selectedDevice: CleaningDevice?
    @State private var path: [Route] = []
    @State private var didLogExposure = false
    
    @State private var showSpecialOffer = false
    @State private var didCheckSpecialOffer = false
    
    var body: some View {
        NavigationStack(path: $path) {
            ZStack {
                
                //Background()
                
                BackgroundNew()
                
                VStack(spacing: 40) {
                    HStack {
                        Text("Speaker Cleaner")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(.white)
                        Spacer()
                    }
                    .padding(.horizontal, 34)
                    .padding(.top, 16)
                    
//                    ViewThatFits(in: .vertical) {
//                        DeviceGridView(size: 170, onDeviceTap: { device in path.append(.modes(device)) })
//                        DeviceGridView(size: 158, onDeviceTap: { device in path.append(.modes(device)) })
//                        DeviceGridView(size: 126, onDeviceTap: { device in path.append(.modes(device)) })
//                        DeviceGridView(size: 118, onDeviceTap: { device in path.append(.modes(device)) })
//                    }
                    
                    ViewThatFits(in: .vertical) {
                        DeviceSqureGridView(size: 170, onDeviceTap: { device in path.append(.modes(device)) })
                        DeviceSqureGridView(size: 158, onDeviceTap: { device in path.append(.modes(device)) })
                        DeviceSqureGridView(size: 126, onDeviceTap: { device in path.append(.modes(device)) })
                        DeviceSqureGridView(size: 118, onDeviceTap: { device in path.append(.modes(device)) })
                    }
                    
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
            .navigationDestination(for: Route.self) { route in
                switch route {
                case .modes(let device):
                    // Передаємо колбек, який пушне StartView
                    ModesView(device: device) { mode in
                        path.append(.start(device, mode))
                    }
                    
                case .start(let device, let mode):
                    StartView(device: device, mode: mode)
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
                    placeWhereBuy: "After onboarding"
                )
                // PaywallGate вже передається як environmentObject з кореня,
                // додатково нічого не треба
            }
            
        }
    }
}

#Preview {
    ZStack{
        BackgroundNew()
        DeviceSqureGridView(size: 170, onDeviceTap: { new in  })
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
        AppNotificationPolicy.updateForSubscription(isActive: isPro)
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



struct DeviceButtonView: View {
    let device: CleaningDevice
    let size: CGFloat
    let action: (CleaningDevice) -> Void
    
    var body: some View {
        Button { action(device) } label: {
            ZStack {
                Circle().fill(Color(red: 19/255, green: 21/255, blue: 23/255))
                Circle().fill(
                    LinearGradient(colors: [
                        Color.white.opacity(0.10),
                        Color.white.opacity(0.20)
                    ], startPoint: .top, endPoint: .bottom)
                )
                Circle()
                    .stroke(.white.opacity(0.25), lineWidth: 2)
                    .blur(radius: 0.5)
                    .offset(y: 1)
                    .mask(Circle().fill(LinearGradient(colors: [.black, .clear],
                                                       startPoint: .top, endPoint: .bottom)))
                
                VStack(spacing: 12) {
                    Image(device.imageName)
                        .resizable()                // ← спочатку
                        .scaledToFit()
                    //                        .renderingMode(.template)   // якщо потрібно тинтувати растрову іконку
                    //                        .foregroundStyle(.white)    // або .foregroundColor(.white) на iOS 15+
                        .frame(height: size * 0.45)
                    
                    Text(device.displayName)
                        .font(.headline)
                        .foregroundStyle(Color(red: 247/255, green: 247/255, blue: 247/255))
                        .lineLimit(1)
                        .minimumScaleFactor(0.85)
                }
            }
            .frame(width: size, height: size)
        }
        .buttonStyle(.plain)
    }
}

struct DeviceGridView: View {
    let size: CGFloat
    let onDeviceTap: (CleaningDevice) -> Void
    
    var body: some View {
        VStack(spacing: 32) {
            DeviceButtonView(device: .iPhone,     size: size, action: onDeviceTap)
            
            HStack(spacing: 32) {
                DeviceButtonView(device: .airPodsPro, size: size, action: onDeviceTap)
                DeviceButtonView(device: .airPods,    size: size, action: onDeviceTap)
            }
            HStack(spacing: 32) {
                DeviceButtonView(device: .airPodsMax, size: size, action: onDeviceTap)
                DeviceButtonView(device: .speakers,   size: size, action: onDeviceTap)
            }
        }
    }
}

struct DeviceSquareButtonView: View {
    let device: CleaningDevice
    let size: CGFloat
    let action: (CleaningDevice) -> Void
    
    var body: some View {
        Button { action(device) } label: {
            ZStack {
                RoundedRectangle(cornerRadius: 24).fill(Color(red: 19/255, green: 21/255, blue: 23/255))
                RoundedRectangle(cornerRadius: 24).fill(
                    LinearGradient(colors: [
                        Color(red: 31 / 255, green: 34 / 255, blue: 37 / 255),
                        Color(red: 27 / 255, green: 30 / 255, blue: 30 / 255)
                    ], startPoint: .top, endPoint: .bottom)
                )
                .strokeBorder(Color(red: 221 / 255, green: 219 / 255, blue: 225 / 255), lineWidth: 1.0)
//                RoundedRectangle(cornerRadius: 24)
//                    .stroke(.white.opacity(0.25), lineWidth: 2)
//                    .blur(radius: 0.5)
//                    .offset(y: 1)
//                    .mask(Circle().fill(LinearGradient(colors: [.black, .clear],
//                                                       startPoint: .top, endPoint: .bottom)))
                
                
                
                VStack(spacing: 0) {
                    Image(device.imageNameNew)
                        .resizable()                // ← спочатку
                        .scaledToFit()
                        .frame(height: device == .speakers ? size * 0.5 : size * 0.7)
                    
                    Text(device.displayName)
                        .font(.custom("Montserrat-Medium", size: 14))
                        .foregroundStyle(Color(red: 247/255, green: 247/255, blue: 247/255))
                        .lineLimit(1)
                        .minimumScaleFactor(0.85)
                }
            }
            .frame(width: size, height: size)
        }
        .buttonStyle(.plain)
    }
}

struct DeviceSqureGridView: View {
    let size: CGFloat
    let onDeviceTap: (CleaningDevice) -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            
            HStack(spacing: 16) {
                DeviceSquareButtonView(device: .iPhone,     size: size, action: onDeviceTap)
                DeviceSquareButtonView(device: .airPodsPro, size: size, action: onDeviceTap)
            }
           
            
            HStack(spacing: 16) {
                DeviceSquareButtonView(device: .airPodsPro, size: size, action: onDeviceTap)
                DeviceSquareButtonView(device: .airPodsMax, size: size, action: onDeviceTap)
            }
            HStack(spacing: 16) {
                //DeviceSquareButtonView(device: .airPodsMax, size: size, action: onDeviceTap)
                DeviceSquareButtonView(device: .speakers,   size: size, action: onDeviceTap)
                
                DeviceSquareButtonView(device: .speakers,   size: size, action: onDeviceTap)
                    .opacity(0)
                    .disabled(true)
                
            }
        }
    }
}


extension String: Identifiable {
    public var id: String { self }
}
