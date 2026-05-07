//
//  NewBlackPaywallThird.swift
//  WaterEject
//
//  Created by Ruslan Liulka on 07.05.2026.
//

import SwiftUI

struct NewBlackPaywallThird: View {
    let index: Int
    let action: () -> Void
    
    
    private func handleCTA() {
        
        action()
    }
    
    
    var body: some View {
        
        

//        OnboardNewFirstForm(ctaTitle:String(localized: "Continue"), ctaAction: handleCTA, pages: 2, pageIndex: index, fixedWidth: 260) {
        OnboardThirdForm(ctaTitle:String(localized: "Continue"), ctaAction: handleCTA, pages: 3, pageIndex: index, fixedWidth: 260) {
//            Color(red: 0 / 255, green: 0 / 255, blue: 0 / 255)
//                .ignoresSafeArea()
//            
//            Image("FirstOnboardBGOne")
//                .resizable()
//                
//                .ignoresSafeArea()
//            
            VStack(spacing: 10) {
                Spacer()
                
                ZStack(alignment: .bottom) {
                   
                   
                    
                    
                }
                
                
                Text("Start Cleaning and Playing")
                    .font(.custom("Montserrat-Bold", size: 26))
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)
                    .padding(.bottom, 16)
                
                Text("$29.99 (Pay once - use forever)")
                    .font(.custom("Montserrat-SemiBold", size: 16))
                    .foregroundStyle(.white.opacity(0.6))
                    .multilineTextAlignment(.center)
                    .padding(.bottom, 18)
                    .padding(.horizontal, 30)
                
                
            }
            
        }
        
        .background(
            ZStack(alignment: .top) {
                Color(red: 0 / 255, green: 0 / 255, blue: 0 / 255)
                    .ignoresSafeArea()

                Image("paywallPhotoNewBlackThird")
                    .resizable()
                    .scaledToFit()

                    //.scaleEffect(1.05)
            }
                .ignoresSafeArea()
        )
        
    }
}



#Preview {
    NewBlackPaywallThird(index: 0) {
        print("1")
    }
}
