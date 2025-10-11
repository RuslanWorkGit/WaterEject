//
//  HomeView.swift
//  WaterEject
//
//  Created by Ruslan Liulka on 01.08.2025.
//

import SwiftUI


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
    
    var body: some View {
        NavigationStack(path: $path) {
            ZStack {
                
                Background()
                
//                VStack(spacing: 28) {
//                    HStack {
//                        Text("Speaker Cleaner")
//                            .font(.system(size: 28, weight: .bold))
//                            .foregroundColor(.white)
//                        Spacer()
//                    }
//                    .padding(.horizontal, 34)
//                    .padding(.top, 16)
//                    
//                    DeviceGridView { device in
////                        Telemetry.shared.homeDeviceTap(device: device)
////                                                // 2) лог навігації
////                        Telemetry.shared.homeNavigateToModes(device: device)
//                        
//                        path.append(.modes(device))
//                        //showModesScreen = true
//                    }
//                    
//                    
//                    Spacer()
//                    
//                }
                VStack(spacing: 28) {
                    HStack {
                        Text("Speaker Cleaner")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(.white)
                        Spacer()
                    }
                    .padding(.horizontal, 34)
                    .padding(.top, 16)

                    ViewThatFits(in: .vertical) {
                        DeviceGridView(size: 170, onDeviceTap: { device in path.append(.modes(device)) })
                        DeviceGridView(size: 158, onDeviceTap: { device in path.append(.modes(device)) })
                        DeviceGridView(size: 126, onDeviceTap: { device in path.append(.modes(device)) })
                        DeviceGridView(size: 118, onDeviceTap: { device in path.append(.modes(device)) })
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
            
        }
    }
}

#Preview {
    HomeView()
}

//import SwiftUI
//
//struct DeviceButtonView: View {
//    
//    let device: CleaningDevice
//    let action: (CleaningDevice) -> Void
//    
//    var body: some View {
//        Button(action: { action(device) }) {
//            ZStack {
//                // Фон та overlay — ВСЕРЕДИНІ Button!
//                Circle()
//                    .fill(Color(red: 19 / 255, green: 21 / 255, blue: 23 / 255))
//                Circle()
//                    .fill(
//                        LinearGradient(
//                            colors: [
//                                Color(red: 222 / 255, green: 233 / 255, blue: 255 / 255, opacity: 0.1),
//                                Color(red: 222 / 255, green: 233 / 255, blue: 255 / 255, opacity: 0.2)
//                            ],
//                            startPoint: .top,
//                            endPoint: .bottom
//                        )
//                    )
//                Circle()
//                    .stroke(Color.white.opacity(0.25), lineWidth: 2)
//                    .blur(radius: 0.5)
//                    .offset(x: 0, y: 1)
//                    .mask(
//                        Circle().fill(
//                            LinearGradient(colors: [.black, .clear], startPoint: .top, endPoint: .bottom)
//                        )
//                    )
//                
//                VStack(spacing: 12) {
//                    Image(device.imageName)
//                        .foregroundStyle(.white)
//                    Text(device.displayName)
//                        .font(.headline)
//                        .foregroundStyle(Color(red: 247 / 255, green: 247 / 255, blue: 247 / 255))
//                }
//            }
//            .frame(width: 150, height: 150)
//        }
//        .buttonStyle(.plain) // Щоб не було сірого ефекту system button
//    }
//}

import SwiftUI

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



//struct DeviceGridView: View {
//    let onDeviceTap: (CleaningDevice) -> Void
//    
//    var body: some View {
//        VStack(spacing: 32) {
//            // Верхній (центральний) елемент
//            DeviceButtonView(device: .iPhone, action: onDeviceTap)
//            
//            // Два ряди по 2 елементи
//            HStack(spacing: 32) {
//                DeviceButtonView(device: .airPodsPro, action: onDeviceTap)
//                DeviceButtonView(device: .airPods, action: onDeviceTap)
//            }
//            HStack(spacing: 32) {
//                DeviceButtonView(device: .airPodsMax, action: onDeviceTap)
//                DeviceButtonView(device: .speakers, action: onDeviceTap)
//            }
//        }
//        
//        
//    }
//}

extension String: Identifiable {
    public var id: String { self }
}
