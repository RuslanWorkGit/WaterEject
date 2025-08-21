////
////  ModesView.swift
////  WaterEject
////
////  Created by Ruslan Liulka on 01.08.2025.
////
//
//import SwiftUI
//
//
struct NavigationControllerCoordinator: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> UIViewController {
        let viewController = UIViewController()
        return viewController
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        DispatchQueue.main.async {
            if let navigationController = uiViewController.navigationController {
                navigationController.interactivePopGestureRecognizer?.isEnabled = true
                navigationController.interactivePopGestureRecognizer?.delegate = context.coordinator
            }
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
    
    class Coordinator: NSObject, UIGestureRecognizerDelegate {
        func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
            true // Allow swipe gesture to trigger
        }
    }
}


struct CleaningModeCard: View {
    // Пропси для повторного використання
    let icon: String
    let mode: CleaningMode
    let deviceIcon: String
    let deviceName: String
    let deviceColor: Color
    let freq: String
    let time: String
    let onModeAction: (CleaningMode) -> Void
    
    var body: some View {
        
        Button {
            onModeAction(mode)
        } label: {
            VStack(alignment: .leading, spacing: 12) {
                HStack(alignment: .top, spacing: 12) {
                    ZStack {
                        IconCard(icon: icon)
                        
                    }
                    .frame(width: 48, height: 48)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        HStack {
                            Text(mode.modeName)
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundStyle(Color(red: 247 / 255, green: 247 / 255, blue: 247 / 255))
                            
                        }
                        Text(mode.explainText)
                            .font(.system(size: 14))
                            .foregroundColor(Color.white.opacity(0.55))
                    }
                    .padding(.bottom, 16)
                }
                
                Divider().background(Color.white.opacity(0.1))
                
                HStack(spacing: 10) {
                    Image(deviceIcon)
                    
                    Text(deviceName)
                        .font(.system(size: 15, weight: .medium))
                        .foregroundStyle(deviceColor)
                    Text("•")
                        .font(.system(size: 15))
                        .foregroundStyle(Color(red: 196 / 255, green: 196 / 255, blue: 197 / 255))
                    Text(freq)
                        .font(.system(size: 15))
                        .foregroundStyle(Color(red: 196 / 255, green: 196 / 255, blue: 197 / 255))
                    Spacer()
                    Text(time)
                    //.font(.system(size: 12))
                        .font(.system(size: 12, weight: .regular))
                        .foregroundStyle(Color(red: 196 / 255, green: 196 / 255, blue: 197 / 255))
                        .padding(.horizontal, 6)
                        .padding(.vertical, 5)
                        .background(Color.white.opacity(0.05))
                        .clipShape(Capsule())
                }
            }
            .padding(18)
            .background(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(Color.white.opacity(0.05))
                    .shadow(color: .black.opacity(0.18), radius: 16, x: 0, y: 4)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 18)
                    .stroke(Color.white.opacity(0.05), lineWidth: 1)
            )
            .padding(.horizontal, 24)
            .padding(.vertical, 6)
        }
        
    }
    
}


//  ModesView.swift

import SwiftUI

struct ModesView: View {
    @EnvironmentObject private var paywallGate: PaywallGate
    @EnvironmentObject private var tabBarState: TabBarState
    @Environment(\.dismiss) private var dismiss
    
    @State private var pendingMode: CleaningMode?
    let device: CleaningDevice
    let onStart: (CleaningMode) -> Void
    
    var body: some View {
        ZStack {
            Background()
            
            VStack(spacing: 28) {
                
                // --- Контент списку режимів ---
                CleaningModeCard(
                    icon: "Drop",
                    mode: .sonicPulse,
                    deviceIcon: "SmallDynamic",
                    deviceName: "Speaker",
                    deviceColor: Color(red: 56/255, green: 255/255, blue: 185/255),
                    freq: "175HZ Vibro",
                    time: "25 seconds",
                    onModeAction: { mode in startIfAllowed(mode) }
                )
                
                CleaningModeCard(
                    icon: "Dynamic",
                    mode: .nanoShake,
                    deviceIcon: "SmallDynamic",
                    deviceName: "Speaker",
                    deviceColor: Color(red: 56/255, green: 255/255, blue: 185/255),
                    freq: "175HZ Vibro",
                    time: "25 seconds",
                    onModeAction: { mode in startIfAllowed(mode) }
                )
                
                CleaningModeCard(
                    icon: "Drop",
                    mode: .dynamicEject,
                    deviceIcon: "SmallDrop",
                    deviceName: "Water",
                    deviceColor: Color(red: 161/255, green: 225/255, blue: 255/255),
                    freq: "175HZ Vibro",
                    time: "25 seconds",
                    onModeAction: { mode in startIfAllowed(mode) }
                )
                
                CleaningModeCard(
                    icon: "Drop",
                    mode: .hydroGuard,
                    deviceIcon: "SmallWave",
                    deviceName: "Speaker",
                    deviceColor: Color(red: 161/255, green: 225/255, blue: 255/255),
                    freq: "175HZ Vibro",
                    time: "25 seconds",
                    onModeAction: { mode in startIfAllowed(mode) }
                )
                
                Spacer()
            }
            .padding(.top, 32)
            .padding(.horizontal, 4)
        }

        .navigationBarBackButtonHidden(true)
        .background(NavigationControllerCoordinator())
        // Тулбар: залишаємо СИСТЕМНУ стрілку назад (зі свайпом),
        // а заголовок і шестерню даємо в тулбар.
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text(device.displayName)
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.white)
            }
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "chevron.backward")
                        .foregroundStyle(Color(red: 161 / 255, green: 192 / 255, blue: 255 / 255))
                        .font(.system(size: 23))
                    
                }
                
            }
        }
        // Колір системної стрілки
        .tint(Color(red: 161/255, green: 192/255, blue: 255/255))
        // Лише стрілка без тексту "Back", якщо доступно (iOS 15+)
        
        // Пейвол лишається як модалка; після закриття відкриваємо StartView, якщо юзер став Pro
        .fullScreenCover(item: $paywallGate.presentedVariant, onDismiss: {
            Task {
                if let pending = pendingMode, await paywallGate.isPro() {
                    onStart(pending)
                    pendingMode = nil
                }
                paywallGate.dismissPaywall()
            }
        }) { variant in
            switch variant {
            case .A:
                PaywallFirstView(onFinish: {
                    paywallGate.dismissPaywall()
                    Task {
                        if let pending = pendingMode, await paywallGate.isPro() {
                            onStart(pending)
                            pendingMode = nil
                        }
                    }
                })
            case .B:
                PaywallSecondView(onFinish: {
                    paywallGate.dismissPaywall()
                    Task {
                        if let pending = pendingMode, await paywallGate.isPro() {
                            onStart(pending)
                            pendingMode = nil
                        }
                    }
                })
            }
        }
    }
    
    // MARK: - Helpers
    
    private func startIfAllowed(_ mode: CleaningMode) {
        Task {
            pendingMode = mode
            let allowed = await paywallGate.requireProOrPresentPaywall(context: .modesTap)
            if allowed {
                onStart(mode)          // пушимо StartView через Route у HomeView
                pendingMode = nil
            }
        }
    }
}


