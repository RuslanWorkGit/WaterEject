//
//  DeviceOnboardNew.swift
//  WaterEject
//
//  Created by Ruslan Liulka on 26.09.2025.
//

import SwiftUI

struct DeviceOnboardNew: View {
    let action: () -> Void
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color.white,
                         Color(red: 201/255, green: 214/255, blue: 238/255)],
                startPoint: .top, endPoint: .bottom
            )
            .ignoresSafeArea()
            
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
                
                DeviceOnboardGridView { device in

                }
                .padding(.top, 44)
                
                PillButton(title: "Continue", action: action, arrow: true)
                    .padding(.top, 42)
                    .padding(.horizontal, 80)
            }
        }
    }
}

struct DeviceOnboardButtonView: View {
    
    let device: CleaningDevice
    let action: (CleaningDevice) -> Void
    
    var body: some View {
        Button(action: { action(device) }) {
            ZStack {
                // Фон та overlay — ВСЕРЕДИНІ Button!
                Circle()
                    .fill(Color(red: 19 / 255, green: 21 / 255, blue: 23 / 255))
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color.white,
                                     Color(red: 201/255, green: 214/255, blue: 238/255)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                Circle()
                    .stroke(Color.white.opacity(0.25), lineWidth: 2)
                    .blur(radius: 0.5)
                    .offset(x: 0, y: 1)
                    .mask(
                        Circle().fill(
                            LinearGradient(colors: [Color.white.opacity(0.35),
                                                    Color.white.opacity(0.15)], startPoint: .top, endPoint: .bottom)
                        )
                    )
                
                VStack(spacing: 12) {
                    Image(device.onboardImage)
                        .foregroundStyle(.white)
                    Text(device.displayName)
                        .font(.headline)
                        .foregroundStyle(Color(red: 17 / 255, green: 17 / 255, blue: 17 / 255))
                }
            }
            .frame(width: 150, height: 150)
        }
        .buttonStyle(.plain) // Щоб не було сірого ефекту system button
    }
}

struct DeviceOnboardGridView: View {
    let onDeviceTap: (CleaningDevice) -> Void
    
    var body: some View {
        VStack(spacing: 32) {
            // Верхній (центральний) елемент
            DeviceOnboardButtonView(device: .iPhone, action: onDeviceTap)
            
            // Два ряди по 2 елементи
            HStack(spacing: 32) {
                DeviceOnboardButtonView(device: .airPodsPro, action: onDeviceTap)
                DeviceOnboardButtonView(device: .airPods, action: onDeviceTap)
            }
            HStack(spacing: 32) {
                DeviceOnboardButtonView(device: .airPodsMax, action: onDeviceTap)
                DeviceOnboardButtonView(device: .speakers, action: onDeviceTap)
            }
        }
        
        
    }
}


#Preview {
    DeviceOnboardNew(action: {print("hello")})
}
