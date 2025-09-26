//
//  SaveOnboardNew.swift
//  WaterEject
//
//  Created by Ruslan Liulka on 26.09.2025.
//

import SwiftUI

struct SaveOnboardNew: View {
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
                    Text("Save ")
                        .foregroundStyle(Color(red: 17 / 255, green: 17 / 255, blue: 17 / 255))
                        .font(.system(size: 32, weight: .bold))
                    +
                    Text("$199 ")
                        .foregroundStyle(Color(red: 43 / 255, green: 217 / 255, blue: 156 / 255))
                        .font(.system(size: 32, weight: .medium))
                    +
                    Text("on repair.")
                        .foregroundStyle(Color(red: 17 / 255, green: 17 / 255, blue: 17 / 255))
                        .font(.system(size: 32, weight: .bold))
                )
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
                .padding(.top, 42)
                
                (
                    Text("Just use ")
                        .foregroundStyle(Color(red: 17 / 255, green: 17 / 255, blue: 17 / 255))
                        .font(.system(size: 32, weight: .regular))
                    +
                    Text("Water eject.")
                        .foregroundStyle(Color(red: 17 / 255, green: 17 / 255, blue: 17 / 255))
                        .font(.system(size: 32, weight: .medium))
                )
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
                
                HStack(spacing: 0) {
                    WalletImg()
                        .offset(y: 122)
                    
                    AppImg()
                        .padding(.trailing, 12)

    
                }
                .padding(.top, 40)
                .padding(.trailing, 32)
                
                Spacer()
                
                Text("Sound fixed, money saved. Simple.")
                    .foregroundStyle(Color(red: 59 / 255, green: 65 / 255, blue: 72 / 255))
                    .font(.system(size: 14, weight: .bold))
                
                PillButton(title: "Continue", action: action, arrow: true)
                    .padding(.top, 8)
                    .padding(.horizontal, 90)
                    .padding(.bottom, 24)

            }
            

            
            
        }
    }
}


struct AppImg: View {
    
    var body: some View {
        VStack(spacing: 4) {
            Image("AppImg")
                .offset(x: 10)
                .padding(.bottom, 16)
            
            Text("Save with")
                .foregroundStyle(Color(red: 17 / 255, green: 17 / 255, blue: 17 / 255))
                .font(.system(size: 16, weight: .regular))
            
            Text("Water Eject!")
                .foregroundStyle(Color(red: 13 / 255, green: 64 / 255, blue: 46 / 255))
                .font(.system(size: 22, weight: .medium))
        }
    }
}

struct WalletImg: View {
    
    var body: some View {
        VStack(spacing: 4) {
            
            Text("Dont throw $199")
                .foregroundStyle(Color(red: 17 / 255, green: 17 / 255, blue: 17 / 255))
                .font(.system(size: 16, weight: .regular))
                //.offset(x: -20)
            
            Text("away!")
                .foregroundStyle(Color(red: 17 / 255, green: 17 / 255, blue: 17 / 255))
                .font(.system(size: 16, weight: .regular))
                //.offset(x: -20)
            
            Image("Wallet-5")
//                .resizable()
//                .scaledToFit()
                .frame(width: 294, alignment: .leading) // ← ключ
                .offset(x: -50, y: -12)
                .scaleEffect(0.9)
        }
    }
}

struct PillButton: View {
    let title: String
    let action: () -> Void
    var arrow: Bool = false
    
    var body: some View {
        Button(action: action) {
            Spacer()
            Text(title)
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity, minHeight: 60)
                .contentShape(RoundedRectangle(cornerRadius: 32, style: .continuous))
            
        }
        .buttonStyle(.plain)
        .background(
            RoundedRectangle(cornerRadius: 32, style: .continuous)
                .fill(Color.black) // як на скріні
        )
        .overlay( // стрілка зверху, не зсуває текст
            Group {
                if arrow {
                    Image(systemName: "chevron.right")
                        .foregroundStyle(.white)
                        .fontWeight(.bold)
                        .padding(.trailing, 16)
                }
            },
            alignment: .trailing
        )
        .overlay(
            RoundedRectangle(cornerRadius: 32, style: .continuous)
                .stroke(Color.white.opacity(0.08), lineWidth: 1) // тонка обводка (опційно)
        )
    }
}


#Preview {
    SaveOnboardNew(action: {print("hello")})
}
