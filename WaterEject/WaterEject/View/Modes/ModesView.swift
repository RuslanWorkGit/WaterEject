//
//  ModesView.swift
//  WaterEject
//
//  Created by Ruslan Liulka on 01.08.2025.
//

import SwiftUI

struct ModesView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var selectedMode: String?
    let device: String
    
    var body: some View {
        ZStack {
            Background()
            
            VStack(spacing: 28) {
                HStack {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "chevron.backward")
                        Text("Back")
                            .font(.system(size: 17))
                    }
                    
                    Spacer()
                    
                    Text(device)
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.white)
                    Spacer()
                    Button(action: {
                        print("Setting pressed")
                    }) {
                        Image(systemName: "gearshape")
                            .font(.system(size: 24))
                            .foregroundStyle(Color(red: 153 / 255, green: 153 / 255, blue: 153 / 255))
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 16)
                
                CleaningModeCard(
                    icon: "Drop",
                    emoji: "🔥",
                    title: "SonicPulse™ Clean",
                    subtitle: "vibration cleaning (the most popular)",
                    deviceIcon: "SmallDynamic",
                    deviceName: "Speaker",
                    deviceColor: Color(red: 56/255, green: 255/255, blue: 185/255), // зелений
                    freq: "175HZ Vibro",
                    time: "25 seconds",
                    onModeAction: { mode in
                        selectedMode = mode
                    }
                )
                
                CleaningModeCard(
                    icon: "Dynamic",
                    emoji: "",
                    title: "NanoShake™ Frequency Modulation",
                    subtitle: "standart",
                    deviceIcon: "SmallDynamic",
                    deviceName: "Speaker",
                    deviceColor: Color(red: 56/255, green: 255/255, blue: 185/255), // зелений
                    freq: "175HZ Vibro",
                    time: "25 seconds",
                    onModeAction: { mode in
                        selectedMode = mode
                    }
                )
                
                CleaningModeCard(
                    icon: "Drop",
                    emoji: "",
                    title: "Dynamic Eject Curve v3.4",
                    subtitle: "new firmware of the regime",
                    deviceIcon: "SmallDrop",
                    deviceName: "Water",
                    deviceColor: Color(red: 161/255, green: 225/255, blue: 255/255), // зелений
                    freq: "175HZ Vibro",
                    time: "25 seconds",
                    onModeAction: { mode in
                        selectedMode = mode
                    }
                )
                
                CleaningModeCard(
                    icon: "Drop",
                    emoji: "",
                    title: "HydroGuard™ Pre-Sweep",
                    subtitle: "speaker grid preparation",
                    deviceIcon: "SmallWave",
                    deviceName: "Speaker",
                    deviceColor: Color(red: 161/255, green: 225/255, blue: 255/255), // зелений
                    freq: "175HZ Vibro",
                    time: "25 seconds",
                    onModeAction: { mode in
                        selectedMode = mode
                    }
                )

                Spacer()
                
            }
        }
        .fullScreenCover(item: $selectedMode) { mode in
            StartView(device: "Iphone", mode: mode)
        }
    }
}



struct CleaningModeCard: View {
    // Пропси для повторного використання
    let icon: String
    let emoji: String
    let title: String
    let subtitle: String
    let deviceIcon: String
    let deviceName: String
    let deviceColor: Color
    let freq: String
    let time: String
    let onModeAction: (String) -> Void
    
    var body: some View {
        
        Button {
            onModeAction(title)
        } label: {
            VStack(alignment: .leading, spacing: 12) {
                HStack(alignment: .top, spacing: 12) {
                    ZStack {
                        IconCard(icon: icon)

                    }
                    .frame(width: 48, height: 48)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        HStack {
                            Text(emoji)
                            Text(title)
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundStyle(Color(red: 247 / 255, green: 247 / 255, blue: 247 / 255))
                                
                        }
                        Text(subtitle)
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



#Preview {
    ModesView(device: "Iphone")

}
