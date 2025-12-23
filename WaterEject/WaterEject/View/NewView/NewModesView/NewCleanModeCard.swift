//
//  NewCleanModeCard.swift
//  WaterEject
//
//  Created by Ruslan Liulka on 23.12.2025.
//

import SwiftUI


struct NewCleaningModeCard: View {
    // Пропси для повторного використання
    let icon: String
    let mode: CleaningMode
    let deviceIcon: String
    let deviceName: String
    let deviceColor: Color
    let freq: String
    let time: String
    let isSmall: Bool
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
                                .font(.system(size: isSmall ? 14 : 18, weight: .semibold))
                                .foregroundStyle(Color(red: 247 / 255, green: 247 / 255, blue: 247 / 255))
                            
                        }
                        Text(mode.explainText)
                            .font(.system(size: isSmall ? 12 : 14))
                            .foregroundColor(Color.white.opacity(0.55))
                    }
                    .padding(.bottom, 16)
                }
                
                Divider().background(Color.white.opacity(0.1))
                
                HStack(spacing: 10) {
                    Image(deviceIcon)
                    
                    Text(deviceName)
                        .font(.system(size: isSmall ? 14 : 15, weight: .medium))
                        .foregroundStyle(deviceColor)
                    Text("•")
                        .font(.system(size: isSmall ? 14 : 15))
                        .foregroundStyle(Color(red: 196 / 255, green: 196 / 255, blue: 197 / 255))
                    Text(freq)
                        .font(.system(size: isSmall ? 14 : 15))
                        .foregroundStyle(Color(red: 196 / 255, green: 196 / 255, blue: 197 / 255))
                    Spacer()
                    Text(time)
                    //.font(.system(size: 12))
                        .font(.system(size: isSmall ? 10 : 12, weight: .regular))
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
            //            .padding(.horizontal, 24)
            //.padding(.horizontal, isSmall ? 8 : 0)
            .padding(.vertical, 6)
        }
        
    }
    
}

#Preview {
    NewCleaningModeCard(icon: "Drop", mode: .dynamicEject, deviceIcon: "SmallWave", deviceName: "Speaker", deviceColor: Color(red: 161/255, green: 225/255, blue: 255/255), freq: "21", time: "25", isSmall: true) { new in
        
    }
}
