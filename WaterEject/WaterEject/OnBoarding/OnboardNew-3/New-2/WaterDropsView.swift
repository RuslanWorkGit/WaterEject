//
//  WaterDropsView.swift
//  WaterEject
//
//  Created by Ruslan Liulka on 21.11.2025.
//

import SwiftUI

struct WaterDropsView: View {
    let index: Int
    let action: () -> Void
    private func handleCTA() {
        
        action()
    }
    
    var body: some View {
        
        OnboardWaterDrops(ctaTitle: "Start Cleaning", ctaAction: handleCTA, pages: 4, pageIndex: index, fixedWidth: 260) {
            
            Color(red: 225 / 255, green: 233 / 255, blue: 239 / 255).ignoresSafeArea()
            
            VStack() {
                VStack(alignment: .center) {
                    Text("Eject Water ").font(.system(size: 26, weight: .bold))
                        .foregroundStyle(.black)
                        .multilineTextAlignment(.center)
                        .padding(.top, 64)
                        //.padding(.bottom, 12)
                    
                    Text("From Your Speakers").font(.system(size: 26, weight: .semibold))
                        .foregroundStyle(.black)
                        .multilineTextAlignment(.center)
                        //.padding(.top, 40)
                        .padding(.bottom, 12)
                    
                    Text("Sound waves push moisture out safely.")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(Color(red: 59/255, green: 65/255, blue: 72/255))

                }
                
                Spacer()
                
                Image("DropsImg")
                    .resizable()
                    .scaledToFit()
                    .padding(.horizontal, 30)
                
                
            }
            
        }
        
    }
}


struct OnboardWaterDrops<Content: View>: View {
    let ctaTitle: String
    let ctaAction: () -> Void
    var pages: Int = 0
    var pageIndex: Int = 0
    var fixedWidth: CGFloat = 260
    @ViewBuilder let content: () -> Content
    
    var body: some View {
        ZStack { content() }
            .safeAreaInset(edge: .bottom) {
                VStack {
                    
                    if pages > 0 {
                        PageDots(total: pages, index: pageIndex)
                            .padding(.bottom, 12)
                            .padding(.top, 30)
                    }
                    
                    HStack { // гарантує однакову геометрію
                        Spacer()
                        
                        
                        
                        NewTwoOboardButton(title: ctaTitle, action: ctaAction, arrow: true)
                            .padding(.horizontal, 40)
                            .frame(minHeight: 52) // ключ
                            .frame(width: .infinity)
                        Spacer()
                    }
                    
                    
                }
                
                .padding(.bottom, 0)
                
        }
    }
}

struct NewTwoOboardButton: View {
    let title: String
    let action: () -> Void
    var arrow: Bool = false
    
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(.white)
                .frame(minHeight: 64)
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

struct PageDots: View {
    let total: Int
    let index: Int        // 0...total-1
    
    private let active = Color(red: 49/255, green: 125/255, blue: 236/255) // #317DEC
    private let inactive = Color(red: 220/255, green: 224/255, blue: 230/255) // сірі точки

    var body: some View {
        HStack(spacing: 8) {
            ForEach(0..<total, id: \.self) { i in
                let isActive = (i == index)
                
                Capsule()
                    .fill(isActive ? active : inactive)
                    .frame(
                        width: isActive ? 30 : 8,   // 👈 капсула ↔ кружок
                        height: 8
                    )
            }
        }
        .padding(.top, 14)
        .padding(.bottom, 4)
        .frame(maxWidth: .infinity)
        .allowsHitTesting(false)
        // анімація при зміні index
        .animation(.easeInOut(duration: 0.25), value: index)
    }
}


#Preview {
    WaterDropsView(index: 0 ,action: { print("N")})
}
