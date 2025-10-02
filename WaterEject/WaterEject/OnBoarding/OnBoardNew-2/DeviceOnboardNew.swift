//
//  DeviceOnboardNew.swift
//  WaterEject
//
//  Created by Ruslan Liulka on 26.09.2025.
//

import SwiftUI
import UIKit

struct DeviceOnboardNew: View {
    let onDeviceSelect: (OnboardDeviceModel) -> Void   // ← нове
    let action: () -> Void
    
    @State private var selected: OnboardDeviceModel? = nil
    
    @State private var isExiting = false
    
    private func handleCTA() {
        guard !isExiting else { return }
        withAnimation(.easeOut(duration: 0.3)) { isExiting = true }
        // Після завершення локальної анімації — викликаємо перехід нагору
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            action()
        }
    }
    
    // Один параметр, щоб легко змінювати час
    private let exitDuration: Double = 0.35
    
    var body: some View {
        
        OnboardScaffold(ctaTitle: "Continue", ctaAction: {
            guard let picked = selected else {
                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                return
            }
            handleCTA()
            onDeviceSelect(picked)   // віддаємо вибір
                            // переходимо далі
        }, fixedWidth: 260) {
            
            // увесь твій контент екрану, БЕЗ кнопки!
//            LinearGradient(
//                colors: [Color.white,
//                         Color(red: 201/255, green: 214/255, blue: 238/255)],
//                startPoint: .top, endPoint: .bottom
//            )
//            .ignoresSafeArea()
            
            VStack {
                (
                    Text("What device ")
                        .foregroundStyle(Color(red: 17 / 255, green: 17 / 255, blue: 17 / 255))
                        .font(.system(size: 32, weight: .bold))
                    +
                    Text("are we rescuring?")
                        .foregroundStyle(Color(red: 17 / 255, green: 17 / 255, blue: 17 / 255))
                        .font(.system(size: 32, weight: .bold))
                    +
                    Text("💦")
                        .font(.system(size: 32, weight: .bold))
                )
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
                .padding(.top, 42)
                
                Text("Choose your device and let’s clear the water fast")
                    .font(.system(size: 16))
                    .foregroundStyle(Color(red: 59 / 255, green: 65 / 255, blue: 72 / 255))
                
                DeviceOnboardGridView(selected: $selected)
                                    .padding(.top, 44)

                Spacer()
                

            }
            .opacity(isExiting ? 0 : 1)
            .offset(y: isExiting ? 100 : 0)
            .animation(.easeInOut(duration: exitDuration), value: isExiting)


        }

    }
}

struct DeviceOnboardButtonView: View {
    let device: OnboardDeviceModel
    let isSelected: Bool
    let onTap: () -> Void

    private let highlight = Color(red: 81/255, green: 132/255, blue: 234/255)

    var body: some View {
        ZStack(alignment: .top) {
            // База
            ZStack {
                Circle().fill(Color(red: 19/255, green: 21/255, blue: 23/255))
                Circle().fill(
//                    LinearGradient(colors: [.white, Color(red: 201/255, green: 214/255, blue: 238/255)],
//                                   startPoint: .top, endPoint: .bottom)
                    LinearGradient(colors: [Color(red: 222/255, green: 233/255, blue: 255/255).opacity(0.8), Color(red: 178/255, green: 186/255, blue: 204/255).opacity(0.8)],
                                   startPoint: .top, endPoint: .bottom)
                )
                Circle().fill(
                    LinearGradient(colors: [.white.opacity(0.4), Color(red: 201/255, green: 214/255, blue: 238/255).opacity(0.35)],
                                   startPoint: .top, endPoint: .bottom)
//                    LinearGradient(colors: [Color(red: 222/255, green: 233/255, blue: 255/255), Color(red: 178/255, green: 186/255, blue: 204/255)],
//                                   startPoint: .top, endPoint: .bottom)
                )
                Circle()
                    .stroke(Color.white.opacity(0.25), lineWidth: 2)
                    .blur(radius: 0.5)
                    .offset(y: 1)
                    .mask(
                        Circle().fill(
                            LinearGradient(colors: [Color.white.opacity(0.35), Color.white.opacity(0.15)],
                                           startPoint: .top, endPoint: .bottom)
                        )
                    )

                VStack(spacing: 12) {
                    Image(device.onboardImage)
                        .foregroundStyle(.white)
                    Text(device.displayName)
                        .font(.headline)
                        .foregroundStyle(Color(red: 17/255, green: 17/255, blue: 17/255))
                }
            }
            .overlay(
                Circle()
                    .stroke(isSelected ? highlight : .clear, lineWidth: 1)
                    .animation(.easeInOut(duration: 0.15), value: isSelected)
            )

            // Чекмарк у правому верхньому
            if isSelected {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundStyle(highlight)
                    .background(Circle().fill(.white)) // тонкий білий підклад
                    .clipShape(Circle())
                    .font(.system(size: 20, weight: .semibold))
                    .transition(.scale.combined(with: .opacity))
            }
        }
        .frame(width: 150, height: 150)
        .contentShape(Circle())
        .onTapGesture { onTap() }         // тільки вибір, без переходу
    }
}


struct DeviceOnboardGridView: View {
    @Binding var selected: OnboardDeviceModel?

    private let spacing: CGFloat = 32

    var body: some View {
        VStack(spacing: spacing) {
            // Верхній (центральний)
            DeviceOnboardButtonView(
                device: .iPhone,
                isSelected: selected == .iPhone,
                onTap: { selected = .iPhone }
            )

            // 2×2
            HStack(spacing: spacing) {
                DeviceOnboardButtonView(device: .airPodsPro, isSelected: selected == .airPodsPro) { selected = .airPodsPro }
                DeviceOnboardButtonView(device: .airPods,    isSelected: selected == .airPods)    { selected = .airPods }
            }
            HStack(spacing: spacing) {
                DeviceOnboardButtonView(device: .airPodsMax, isSelected: selected == .airPodsMax) { selected = .airPodsMax }
                DeviceOnboardButtonView(device: .speakers,   isSelected: selected == .speakers)   { selected = .speakers }
            }
        }
    }
}



//#Preview {
//    DeviceOnboardNew(onDeviceSelect: , action: {print("hello")})
//}
