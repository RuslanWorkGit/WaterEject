//
//  First.swift
//  WaterEject
//
//  Created by Ruslan Liulka on 06.05.2026.
//


import SwiftUI

struct OnboardingNewFirstViewOne: View {
    let index: Int
    let action: () -> Void
    
    
    private func handleCTA() {
        
        action()
    }
    
    
    var body: some View {
        
        

//        OnboardNewFirstForm(ctaTitle:String(localized: "Continue"), ctaAction: handleCTA, pages: 2, pageIndex: index, fixedWidth: 260) {
        OnboardThirdForm(ctaTitle:String(localized: "Continue"), ctaAction: handleCTA, pages: 3, pageIndex: index, fixedWidth: 260) {
            Color(red: 0 / 255, green: 0 / 255, blue: 0 / 255)
                .ignoresSafeArea()
            
            Image("FirstOnboardBGOne")
                .resizable()
                
                .ignoresSafeArea()
            
            VStack(spacing: 10) {
                Spacer()
                
                ZStack(alignment: .bottom) {
                   
                   
                    
                    
                }
                
                
                Text("Restore Your Speaker’s Original Sound Easily")
                    .font(.custom("Montserrat-SemiBold", size: 24))
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 16)
                    .padding(.bottom, 16)
                
                Text("Push water and dust out using advanced sonic technology. The same method used by Apple Watch.")
                    .font(.custom("Montserrat-SemiBold", size: 16))
                    .foregroundStyle(.white.opacity(0.6))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 30)
                
                
            }
            
        }
        
//        .background(
//            ZStack(alignment: .top) {
//                Color(red: 29 / 255, green: 29 / 255, blue: 29 / 255)
//                    .ignoresSafeArea()
//                
//                Image("FirstOnboardBGOne")
//                    .resizable()
//                    .scaledToFit()
//                   
//                    //.scaleEffect(1.05)
//            }
//                .ignoresSafeArea()
//        )
        
    }
}

struct OnboardThirdForm<Content: View>: View {
    let ctaTitle: String
    let ctaAction: () -> Void
    var pages: Int = 0
    var pageIndex: Int = 0
    var fixedWidth: CGFloat = 260
    var button: Bool = true
    @ViewBuilder let content: () -> Content
    
    private var isPad: Bool { UIDevice.current.userInterfaceIdiom == .pad }
    private var padScale: CGFloat { isPad ? 1.3 : 1.0 }
    
    var body: some View {
        ZStack { content() }
            .safeAreaInset(edge: .bottom) {
                VStack {
                    

                    
                    HStack { // гарантує однакову геометрію
                        Spacer()
                        
                        
                        
                        OboardThirdNewButton(title: ctaTitle, action: ctaAction, arrow: true)
                            .padding(.horizontal, 40)
                            .frame(minHeight: 52) // ключ
                            .frame(width: .infinity)
                            .opacity(button ? 1 : 0)
                        Spacer()
                    }
                    
                    if pages > 0 {
                        PageDotsThird(total: pages, index: pageIndex)
//                            .padding(.bottom, 32)
                            .padding(.bottom, 12)
                            //.padding(.top, 12)
                    }
                    
                    
                }
                
                .padding(.bottom, 0)
                
            }
    }
}

struct OboardThirdNewButton: View {
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
                .fill(Color(red: 2/255, green: 125/255, blue: 244/255)) // як на скріні
                .innerShadow(
                    RoundedRectangle(cornerRadius: 16),
                    color: Color(red: 2/255, green: 125/255, blue: 244/255), opacity: 0.25,
                    x: 0, y: 1, blur: 0, spread: 2
                )
        )
        
        
    }
}

struct PageDotsThird: View {
    let total: Int
    let index: Int        // 0...total-1
    
    private let active = Color.white // #317DEC
    private let inactive = Color(red: 220/255, green: 224/255, blue: 230/255) // сірі точки
    
    var body: some View {
        HStack(spacing: 8) {
            ForEach(0..<total, id: \.self) { i in
                let isActive = (i == index)
                
                Capsule()
                    .fill(isActive ? active : inactive)
                    .frame(
                        width: isActive ? 11 : 8,   // 👈 капсула ↔ кружок
                        height: isActive ? 11 : 8
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
    OnboardingNewFirstViewOne(index: 0) {
        print("1")
    }
}
