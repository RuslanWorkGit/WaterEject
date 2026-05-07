//
//  OnboardingNewFourthViewThree.swift
//  WaterEject
//
//  Created by Ruslan Liulka on 07.05.2026.
//

import SwiftUI

struct OnboardingNewFourthViewThree: View {
    let index: Int
    let action: () -> Void
    
    
    private func handleCTA() {
        
        action()
    }
    
    
    var body: some View {
        
        

//        OnboardNewFirstForm(ctaTitle:String(localized: "Continue"), ctaAction: handleCTA, pages: 2, pageIndex: index, fixedWidth: 260) {
        OnboardFourthForm(ctaTitle:String(localized: "Continue"), ctaAction: handleCTA, pages: 3, pageIndex: index, fixedWidth: 260) {
//            Color(red: 255 / 255, green: 255 / 255, blue: 255 / 255)
//                .ignoresSafeArea()
            
//            Image("FifthOnboardBGOne")
//                .resizable()
//                .scaledToFit()
//                .ignoresSafeArea()
            
            VStack(spacing: 10) {
                Spacer()
                
                ZStack(alignment: .bottom) {
                   
                   
                    
                    
                }
                
       
                
                Text("98% Success Rate. Remove water now before internal corrosion starts.")
                    .font(.custom("Montserrat-SemiBold", size: 25))
                    .foregroundStyle(.black.opacity(0.9))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)
                
                
            }
            
        }
        
        .background(
            ZStack(alignment: .bottom) {
                Color(red: 22 / 255, green: 125 / 255, blue: 244 / 255)
                    .ignoresSafeArea()

                Image("FourhtOnboardBGThree")
                    .resizable()
                    .scaledToFit()
                    .ignoresSafeArea()

                    //.scaleEffect(1.05)
            }
                .ignoresSafeArea()
        )
        
    }
}




#Preview {
    OnboardingNewFourthViewThree(index: 2) {
        print("1")
    }
}
