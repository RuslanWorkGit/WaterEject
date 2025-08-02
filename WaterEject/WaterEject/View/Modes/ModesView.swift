//
//  ModesView.swift
//  WaterEject
//
//  Created by Ruslan Liulka on 01.08.2025.
//

import SwiftUI

struct ModesView: View {
    @Environment(\.dismiss) private var dismiss
    let device: String
    
    var body: some View {
        ZStack {
            Color(red: 19 / 255, green: 21 / 255, blue: 23 / 255)
                .ignoresSafeArea()
            
            Ellipse()
                .strokeBorder(Color.white.opacity(0.05), lineWidth: 1.5)
                .background(
                    Ellipse()
                        .fill(Color.white.opacity(0.01))
                )
                .frame(width: 431, height: 80)
                .offset(y: 210)
            
            
            Ellipse()
                .fill(Color.white.opacity(0.25)) // 25% прозорість
                .frame(width: 343, height: 56)
                .blur(radius: 70) // SwiftUI blur radius не зовсім 1:1 з Figma, 70–90 виглядає схоже
                .offset(y: 210)
            
            Ellipse()
                .strokeBorder(Color.white.opacity(0.05), lineWidth: 1)
                .background(
                    Ellipse()
                        .fill(Color.white.opacity(0.01))
                )
                .frame(width: 257, height: 30)
                .offset(y: 210)
            
            Rectangle()
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color(red: 25/255, green: 14/255, blue: 13/255),
                            Color(red: 81/255, green: 132/255, blue: 234/255)   // #5184EA
                            // #190E0D
                        ]),
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(width: 375, height: 161)
                .opacity(0.5)        // 50% прозорість як у Figma
                .blur(radius: 100)   // Blur 196 у SwiftUI виглядає схоже на 100-130, тож підбери вручну!
                .offset(y: 240)
            
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
                    deviceIcon: "Dynamic",
                    deviceName: "Speaker",
                    deviceColor: Color(.sRGB, red: 41/255, green: 233/255, blue: 154/255, opacity: 1), // зелений
                    freq: "175HZ Vibro",
                    time: "25 seconds"
                )
                .padding(.horizontal, 24)
                Spacer()
                
            }
        }
    }
}

import SwiftUI

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
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top, spacing: 12) {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color(red: 20 / 255, green: 23 / 255, blue: 26 / 255, opacity: 0.1),
                                    Color(red: 222 / 255, green: 233 / 255, blue: 255 / 255, opacity: 0.2)
                                ],
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
                                LinearGradient(colors: [.black, .clear], startPoint: .top, endPoint: .bottom)
                            )
                        )
                        
                    Image(icon)

                }
                .frame(width: 48, height: 48)
                
                VStack(alignment: .leading, spacing: 2) {
                    HStack {
                        Text(emoji)
                        Text(title)
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.white)
                    }
                    Text(subtitle)
                        .font(.system(size: 14))
                        .foregroundColor(Color.white.opacity(0.55))
                }
                Spacer()
            }
            
            Divider().background(Color.white.opacity(0.1))
            
            HStack(spacing: 10) {
                Image(deviceIcon)
                    .resizable()
                    .frame(width: 16, height: 16)
                    .foregroundSyle(deviceColor)
                Text(deviceName)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(deviceColor)
                Text("•")
                    .font(.system(size: 15))
                    .foregroundColor(.white.opacity(0.5))
                Text(freq)
                    .font(.system(size: 15))
                    .foregroundColor(.white)
                Spacer()
                Text(time)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(.white.opacity(0.8))
                    .padding(.horizontal, 14)
                    .padding(.vertical, 4)
                    .background(Color.white.opacity(0.10))
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
        .padding(.horizontal, 8)
        .padding(.vertical, 6)
    }
}


#Preview {
    ModesView(device: "Iphone")

}
