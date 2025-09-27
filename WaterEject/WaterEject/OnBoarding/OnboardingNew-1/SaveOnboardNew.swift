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
        
        
        OnboardScaffold(ctaTitle: "Continue", ctaAction: action, fixedWidth: 260) {
            // увесь твій контент екрану, БЕЗ кнопки!
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
            Text(title)
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(.white)
                .frame(minHeight: 60)
                .frame(maxWidth: .infinity)
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

struct OnboardScaffold<Content: View>: View {
    let ctaTitle: String
    let ctaAction: () -> Void
    var fixedWidth: CGFloat = 260
    @ViewBuilder let content: () -> Content

    var body: some View {
        ZStack { content() }
            .safeAreaInset(edge: .bottom) {
                HStack { // гарантує однакову геометрію
                    Spacer()
                    PillButton(title: ctaTitle, action: ctaAction, arrow: true)
                        .frame(minHeight: 52) // ключ
                        .frame(width: fixedWidth)
                    Spacer()
                }
                
                .padding(.bottom, 24)

            }
    }
}


#Preview {
    SaveOnboardNew(action: {print("hello")})
}
