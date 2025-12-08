//
//  WelcomeView.swift
//  WaterEject
//
//  Created by Ruslan Liulka on 08.12.2025.
//

import SwiftUI

struct FirstWelcomeView: View {
    let action: () -> Void
    let textButton: String
    private func handleCTA() {
        
        action()
    }
    
    var body: some View {
        
        
        OnboardNewStyle(ctaTitle: textButton, ctaAction: handleCTA, fixedWidth: 260) {
            
            Color(red: 225 / 255, green: 233 / 255, blue: 239 / 255).ignoresSafeArea()
            
            VStack() {
                VStack(alignment: .center) {
                    Text("WELCOME TO WATER EJECT")
                        .font(.custom("Montserrat-ExtraBold", size: 32))
                        .foregroundStyle(Color(red: 45 / 255, green: 127 / 255, blue: 249 / 255))
                        .multilineTextAlignment(.center)
                        .padding(.top, 64)
        
                    

                }
                
            
                
                Image("BlueLineImg")
                    .resizable()
                    .scaledToFit()
                    .padding(.horizontal, -10)
                
                Spacer()
                
                
            }
            
        }
        
    }
}

#Preview {
    FirstWelcomeView(action: { print("N")}, textButton: "Continue")
}

struct NewOboardStyleButton: View {
    let title: String
    let action: () -> Void
    var arrow: Bool = false
    
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(.white)
                .frame(minHeight: 52)
                .frame(maxWidth: .infinity)
            //.contentShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            
        }
        //.buttonStyle(.plain)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color(red: 2 / 255, green: 125 / 255, blue: 244 / 255)) // як на скріні
                .innerShadow(
                    RoundedRectangle(cornerRadius: 16),
                    color: .white, opacity: 0.25,
                    x: 0, y: 1, blur: 0, spread: 2
                )
        )

        
    }
}

struct OnboardNewStyle<Content: View>: View {
    let ctaTitle: String
    let ctaAction: () -> Void
    var fixedWidth: CGFloat = 260
    @ViewBuilder let content: () -> Content
    
    var body: some View {
        ZStack { content() }
            .safeAreaInset(edge: .bottom) {
                VStack {
                    
                    HStack { // гарантує однакову геометрію
                        Spacer()
                        NewOboardStyleButton(title: ctaTitle, action: ctaAction, arrow: true)
                            .padding(.horizontal, 40)
                            .frame(minHeight: 52) // ключ
                            .frame(width: .infinity)
                        Spacer()
                    }
                    
                    
                }
                

                
        }
    }
}


