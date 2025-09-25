//
//  StartOnboard.swift
//  WaterEject
//
//  Created by Ruslan Liulka on 25.09.2025.
//

import SwiftUI

struct StartOnboardView: View {
    @State private var webViewURL: URL?
    let action: () -> Void
    
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color(red: 94 / 255, green: 148 / 255, blue: 255 / 255), Color(red: 56 / 255, green: 114 / 255, blue: 229 / 255)],
                startPoint: .top, endPoint: .bottom
            ).ignoresSafeArea()
            
            VStack {
                Image("IphoneNewOnboard")
                    .resizable()
                    .scaledToFit()
                
                Image("WaterDrop")
                
                ZStack {
                    LinearGradient(
                        colors: [Color.white, Color(red: 201 / 255, green: 214 / 255, blue: 238 / 255)],
                        startPoint: .top, endPoint: .bottom
                    ).ignoresSafeArea()
                    
                    VStack {
                        (
                            Text("Get ")
                                .foregroundStyle(Color(red: 17 / 255, green: 17 / 255, blue: 17 / 255))
                                .font(.system(size: 34, weight: .regular))
                            +
                            Text("water")
                                .foregroundStyle(Color(red: 17 / 255, green: 17 / 255, blue: 17 / 255))
                                .font(.system(size: 34, weight: .medium))
                            +
                            Text("💦")
                                .foregroundStyle(Color(red: 17 / 255, green: 17 / 255, blue: 17 / 255))
                                .font(.system(size: 34, weight: .medium))
                            +
                            Text("out ")
                                .foregroundStyle(Color(red: 17 / 255, green: 17 / 255, blue: 17 / 255))
                                .font(.system(size: 34, weight: .medium))
                            +
                            Text("of your iPhone & AirPods in ")
                                .foregroundStyle(Color(red: 17 / 255, green: 17 / 255, blue: 17 / 255))
                                .font(.system(size: 34, weight: .regular))
                            +
                            Text("30 seconds!")
                                .foregroundStyle(Color(red: 17 / 255, green: 17 / 255, blue: 17 / 255))
                                .font(.system(size: 34, weight: .medium))
                            
                        )
                        .multilineTextAlignment(.center)
                        .padding(.bottom, 4)
                        .padding(.horizontal, 52)
                        
                        Text("Safe sound frequencies push liquid out instantly")
                            .font(.system(size: 16))
                            .foregroundStyle(Color(red: 59 / 255, green: 65 / 255, blue: 72 / 255))
                            //.padding(.bottom, isLarge ? 80 : 42)
                        
                        PrimaryPillButton(title: "Get Started", action: action)
                                                    .padding(.top, 8)
                                                    .padding(.horizontal, 64)
                        
                        HStack(spacing: 0) {

                            Text("By proceeding you accept our ")
                                .font(.system(size: 10))
                                .foregroundStyle(Color(red: 131 / 255, green: 137 / 255, blue: 147 / 255))
                                //.padding(.bottom, isLarge ? 80 : 42)
                            
                            Button {
                                webViewURL = URL(string: "https://docs.google.com/document/d/1L2xhXP9qKJPSP7rymbXx17-xWh5_17V_nJPBbXm1boE/edit?tab=t.0")
                            } label: {
                                Text("Terms of Use")
                                    .font(.system(size: 10))
                                    .foregroundStyle(Color(red: 131/255, green: 137/255, blue: 147/255))
                                    .underline(true, color: Color(red: 131/255, green: 137/255, blue: 147/255))
                            }
                            .buttonStyle(.plain) // щоб не з’являвся системний стиль/синій колір
                            
                            Text(" and ")
                                .font(.system(size: 10))
                                .foregroundStyle(Color(red: 131 / 255, green: 137 / 255, blue: 147 / 255))
                            
                            Button {
                                webViewURL = URL(string: "https://docs.google.com/document/d/1lQQMYnybap2JyKGf7Sd8gyPD1o9FWnAqgnGKx1BnSJI/edit?tab=t.0")
                            } label: {
                                Text("Privacy Policy")
                                    .font(.system(size: 10))
                                    .foregroundStyle(Color(red: 131/255, green: 137/255, blue: 147/255))
                                    .underline(true, color: Color(red: 131/255, green: 137/255, blue: 147/255))
                            }
                            .buttonStyle(.plain)

                        }
                    }
                }
                
                
            }
        }
        .sheet(item: $webViewURL) { url in
            SafariView(url: url)
        }
    }
}

struct PrimaryPillButton: View {
    let title: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 20, weight: .semibold))
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity, minHeight: 60)
                .contentShape(RoundedRectangle(cornerRadius: 32, style: .continuous))
        }
        .buttonStyle(.plain)
        .background(
            RoundedRectangle(cornerRadius: 32, style: .continuous)
                .fill(Color.black) // як на скріні
        )
        .overlay(
            RoundedRectangle(cornerRadius: 32, style: .continuous)
                .stroke(Color.white.opacity(0.08), lineWidth: 1) // тонка обводка (опційно)
        )
    }
}


#Preview {
    StartOnboardView(action: { print("Hello")})
}
