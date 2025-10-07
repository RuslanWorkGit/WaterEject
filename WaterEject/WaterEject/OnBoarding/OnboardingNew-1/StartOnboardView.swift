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
    
    var device: OnboardDeviceModel? = nil   // ← нове
    var startAnimations: Bool = false
    var staticDisplay: Bool = false
    @State private var appearScreen   = false
    
    private func handleCTA() {

            action()
        
    }
    
    // Один параметр, щоб легко змінювати час
    private let exitDuration: Double = 0.45
    

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color(red: 94/255, green: 148/255, blue: 255/255),
                         Color(red: 56/255, green: 114/255, blue: 229/255)],
                startPoint: .top, endPoint: .bottom
            )
            .ignoresSafeArea()
            
            LightPanelScaffold(ctaTitle: "Get Started", ctaAction: handleCTA, ctaWidth: 260, animation: appearScreen) {

                Image(device?.imageName ?? "IphoneNewOnboard")  // ← ключ
                                        .resizable()
                                        .scaledToFit()
//                                      .offset(y: (appearScreen ? 0 : 20))
                                        .opacity(appearScreen ? 1 : 0)
                                        .animation(.spring(response: 0.55, dampingFraction: 0.85), value: appearScreen)
                
                LottieView(name: "Water")
                    .frame(width: 60, height: 50)
                    .padding(.bottom, 16)
                    .offset(y: (appearScreen ? 0 : 20))
                    .opacity(appearScreen ? 1 : 0)
                    .animation(.spring(response: 0.55, dampingFraction: 0.85), value: appearScreen)
                Spacer()
                
            } contentOne: {
                Group {
                    
                    (
                        Text("Get ").font(.system(size: 30, weight: .regular))
                        + Text("water").font(.system(size: 30, weight: .medium))
                        + Text("💦").font(.system(size: 30, weight: .medium))
                        + Text("out ").font(.system(size: 30, weight: .medium))
                        + Text("of your iPhone & AirPods in ").font(.system(size: 30, weight: .regular))
                        + Text("30 seconds!").font(.system(size: 30, weight: .medium))
                    )
                    .foregroundStyle(Color(red: 17/255, green: 17/255, blue: 17/255))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
                    .padding(.top, 16)
                    .padding(.bottom, 12)
                    
                    Text("Safe sound frequencies push liquid out instantly")
                        .font(.system(size: 16))
                        .foregroundStyle(Color(red: 59/255, green: 65/255, blue: 72/255))
                }
                //.opacity(isExiting ? 0 : 1)
//                .offset(y: isExiting ? 20 : 0)
                //.animation(.easeInOut(duration: exitDuration), value: isExiting)
                
            } footer: {
                HStack(spacing: 0) {
                    Text("By proceeding you accept our ")
                        .font(.system(size: 10))
                        .foregroundStyle(Color(red: 131/255, green: 137/255, blue: 147/255))

                    Button {
                        webViewURL = URL(string: "https://docs.google.com/document/d/1L2xhXP9qKJPSP7rymbXx17-xWh5_17V_nJPBbXm1boE/edit?tab=t.0")
                    } label: {
                        Text("Terms of Use")
                            .font(.system(size: 10))
                            .foregroundStyle(Color(red: 131/255, green: 137/255, blue: 147/255))
                            .underline(true, color: Color(red: 131/255, green: 137/255, blue: 147/255))
                    }
                    .buttonStyle(.plain)

                    Text(" and ")
                        .font(.system(size: 10))
                        .foregroundStyle(Color(red: 131/255, green: 137/255, blue: 147/255))

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
                
                //.opacity(isExiting ? 0 : 1)
//                .offset(y: isExiting ? 8 : 0)
                //.animation(.easeInOut(duration: exitDuration), value: isExiting)
            }
            //.padding(.horizontal, 16) // поля від країв екрана
//            .offset(y: (appearScreen ? 0 : 20))
//            .opacity(appearScreen ? 1 : 0)
//            .animation(.spring(response: 0.55, dampingFraction: 0.85), value: appearScreen)
        }

        .animation(nil, value: startAnimations)
        .animation(nil, value: staticDisplay)
        .onChange(of: startAnimations) { _, ready in
            guard ready && !staticDisplay else { return }
            appearScreen = false
            withAnimation(.easeOut(duration: 0.45)) { appearScreen = true }
        }
        .onAppear {
            if staticDisplay {
                var tx = Transaction()
                tx.disablesAnimations = true           // вимкнути анімації на час апдейту
                withTransaction(tx) {
                    appearScreen = true
                }
            } else if startAnimations {
                appearScreen = false
                withAnimation(.easeOut(duration: 0.45)) { appearScreen = true }
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
                .frame(height: 52) // тільки висота, ширину задає scaffold
                .frame(maxWidth: .infinity)
                .contentShape(RoundedRectangle(cornerRadius: 32, style: .continuous))
        }
        .buttonStyle(.plain)
        .background(
            RoundedRectangle(cornerRadius: 32, style: .continuous).fill(Color.black)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 32, style: .continuous)
                .stroke(Color.white.opacity(0.08), lineWidth: 1)
        )
    }
}

struct LightPanelScaffold<Top: View, Main: View, Footer: View>: View {
    let ctaTitle: String
    let ctaAction: () -> Void
    var ctaWidth: CGFloat = 260
    var animation: Bool = false
    
    @ViewBuilder let content: () -> Top
    @ViewBuilder let contentOne: () -> Main
    @ViewBuilder let footer: () -> Footer
    
    var body: some View {
        
        VStack(spacing: 0) {
            content()
            
            VStack(spacing: 2) {
                // верхня частина панелі (твій контент)
                contentOne()
                    .padding(.bottom, 18)
                
                // кнопка на тій самій панелі
                HStack {
                    Spacer()
                    PrimaryPillButton(title: ctaTitle, action: ctaAction)
                        .frame(width: ctaWidth, height: 52)
                    Spacer()
                }
                .padding(.bottom, 8)
                
                // футер під кнопкою, теж на панелі
                footer()
                    .padding(.top, 8)
            }
            .padding(.top, 8)
            .padding(.horizontal, 16)
            .background(
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [Color.white, Color(red: 201/255, green: 214/255, blue: 238/255)],
                            startPoint: .top, endPoint: .bottom
                        )
                        
                    )
                    .ignoresSafeArea()
            )
            .overlay(
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .stroke(Color.white.opacity(0.10), lineWidth: 1)
            )
            .offset(y: (animation ? 0 : 300))
            .opacity(animation ? 1 : 0)
            .animation(.spring(response: 0.55, dampingFraction: 0.85), value: animation)
            
        }
    }
}



#Preview {
    StartOnboardView(action: { print("Hello")})
}
