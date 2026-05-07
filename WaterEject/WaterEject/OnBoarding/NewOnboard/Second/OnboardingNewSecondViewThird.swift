
//  Untitled.swift
//  WaterEject
//
//  Created by Ruslan Liulka on 07.05.2026.
//


import SwiftUI

struct OnboardingNewSecondViewThird: View {
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
            
            Image("SecondOnboardBGTwo")
                .resizable()
                .scaledToFit()
                //.scaleEffect(0.9)
                .ignoresSafeArea()
            
            VStack(spacing: 10) {
                Spacer()
                
                ZStack(alignment: .bottom) {
                   
                   
                    
                    
                }
                
    
                Text("98% Success Rate. Remove water now before internal corrosion starts.")
                    .font(.custom("Montserrat-SemiBold", size: 18))
                    .foregroundStyle(.white.opacity(1))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)
                
                
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
    OnboardingNewSecondViewThird(index: 2) {
        print("1")
    }
}
