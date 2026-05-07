//
//  Untitled.swift
//  WaterEject
//
//  Created by Ruslan Liulka on 07.05.2026.
//



import SwiftUI

struct OnboardingNewSixthViewTwo: View {
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
            
            Image("FirstOnboardBGTwo")
                .resizable()
                .scaledToFit()
                .ignoresSafeArea()
            
            VStack(spacing: 10) {
                Spacer()
                
                ZStack(alignment: .bottom) {
                   
                   
                    
                    
                }
                
                
                Text("Clear Your Speakers from Liquid and Dust")
                    .font(.custom("Montserrat-SemiBold", size: 24))
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 16)
                    .padding(.bottom, 16)
                
                Text("Deep-clean every speaker on your device with precision-tuned frequencies in seconds.")
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


#Preview {
    OnboardingNewSixthViewTwo(index: 0) {
        print("1")
    }
}
