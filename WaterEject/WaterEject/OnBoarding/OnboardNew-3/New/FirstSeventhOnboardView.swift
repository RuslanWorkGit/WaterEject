
//
//  FirstSeventhOnboardView.swift
//  WaterEject
//
//  Created by Ruslan Liulka on 21.11.2025.
//


import SwiftUI

struct FirstSeventhOnboardView: View {
    
    let action: () -> Void
    private func handleCTA() {
        
        action()
    }
    
    
    var body: some View {
        let isLarge = UIScreen.main.bounds.height > 900
        
        
        OnboardCustomNewSecond(ctaTitle: "Continue", ctaAction: handleCTA, fixedWidth: 260) {
            
            Color(red: 225 / 255, green: 233 / 255, blue: 239 / 255).ignoresSafeArea()
            
            
            Text("💦 Water got into your speakers?")
                .foregroundStyle(.black)
                .font(.system(size: isLarge ? 26 : 24, weight: .bold))
            
            
        }
    }
}

#Preview {
    FirstSeventhOnboardView(action: { print("N")})
}


struct NewSecondOboardButton: View {
    let title: String
    let action: () -> Void
    var arrow: Bool = false
    
    
    var body: some View {
        Button(action: {
            let generator = UIImpactFeedbackGenerator(style: .medium)
            
            generator.prepare()
            generator.impactOccurred()
            
            action()
        }) {
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


struct OnboardCustomNewSecond<Content: View>: View {
    let ctaTitle: String
    let ctaAction: () -> Void
    var fixedWidth: CGFloat = 260
    @ViewBuilder let content: () -> Content
    
    var body: some View {
        ZStack { content() }
            .safeAreaInset(edge: .bottom) {
                HStack { // гарантує однакову геометрію
                    Spacer()
                    //                    NewSecondOboardButton(title: ctaTitle, action: ctaAction, arrow: true)
                    //                        .padding(.horizontal, 32)
                    //                        .frame(minHeight: 52) // ключ
                    //                        .frame(width: fixedWidth)
                    Spacer()
                }
                
                .padding(.bottom, 30)
                
            }
    }
}
