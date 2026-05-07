//
//  OnboardingNewFifthViewTwo.swift
//  WaterEject
//
//  Created by Ruslan Liulka on 07.05.2026.
//

import SwiftUI

struct OnboardingNewFifthViewTwo: View {
    let index: Int
    let action: () -> Void
    
    
    private func handleCTA() {
        
        action()
    }
    
    
    var body: some View {
        
        

//        OnboardNewFirstForm(ctaTitle:String(localized: "Continue"), ctaAction: handleCTA, pages: 2, pageIndex: index, fixedWidth: 260) {
        OnboardFifthForm(ctaTitle:String(localized: "Continue"), ctaAction: handleCTA, pages: 3, pageIndex: index, fixedWidth: 260) {
//            Color(red: 255 / 255, green: 255 / 255, blue: 255 / 255)
//                .ignoresSafeArea()
            
            

            
            
            VStack(spacing: 10) {
                Spacer()
                
                ZStack(alignment: .center) {
                   
                    
                    
                    Image("CirclesOnboardImg")
                        .resizable()
                        .scaleEffect(0.9)
                        .scaledToFit()
                       
                    NewOnboardLottieView()
                        .scaleEffect(2)
                           .allowsHitTesting(false)
                    
                    Image("IphoneOnboardImg")
                        .resizable()
                        .scaleEffect(0.75)
                        .scaledToFit()
                        
                    
                    
                }
                
                
                Text("Calibrating Sonic Frequency...")
                    .font(.custom("Montserrat-SemiBold", size: 26))
                    .foregroundStyle(.black)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 16)

                
                Text("Generating low-frequency air pressure to push liquid out.")
                    .font(.custom("Montserrat-SemiBold", size: 16))
                    .foregroundStyle(.black.opacity(0.6))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 30)
                
                
            }
            
        }
        
        .background(
            ZStack(alignment: .top) {
                Color(red: 255 / 255, green: 255 / 255, blue: 255 / 255)
                    .ignoresSafeArea()

//                Image("FifthOnboardBGTwo")
//                    .resizable()
//                    .scaledToFit()
//                    .ignoresSafeArea()

                    //.scaleEffect(1.05)
            }
                .ignoresSafeArea()
        )
        
    }
}


#Preview {
    OnboardingNewFifthViewTwo(index: 0) {
        print("1")
    }
}
