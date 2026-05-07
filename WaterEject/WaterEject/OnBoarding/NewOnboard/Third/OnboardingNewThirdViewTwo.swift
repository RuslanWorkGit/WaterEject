//
//  Untitled.swift
//  WaterEject
//
//  Created by Ruslan Liulka on 07.05.2026.
//

import SwiftUI

struct OnboardingNewThirdViewTwo: View {
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
            
//            Image("FirstOnboardBGTwo")
//                .resizable()
//                .scaledToFit()
//                .ignoresSafeArea()
            
            NewOnboardLottieView()
                .scaleEffect(2)
                   .allowsHitTesting(false)
            
            VStack(spacing: 10) {
                Spacer()
                
                ZStack(alignment: .bottom) {
                   
                   
                    
                    
                }
                
                
                Text("Calibrating Sonic Frequency...")
                    .font(.custom("Montserrat-SemiBold", size: 28))
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 25)
                    .padding(.bottom, 16)
                
                Text("Generating low-frequency air pressure to push liquid out.")
                    .font(.custom("Montserrat-SemiBold", size: 16))
                    .foregroundStyle(.white.opacity(0.6))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
                
                
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


#Preview {
    OnboardingNewThirdViewTwo(index: 1) {
        print("1")
    }
}
