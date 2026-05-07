//
//  OnboardingNewFifthViewThree.swift
//  WaterEject
//
//  Created by Ruslan Liulka on 07.05.2026.
//

import SwiftUI

struct OnboardingNewFifthViewThree: View {
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

                
                Text("WELCOME \nTO WATER EJECT")
                    .font(.custom("Montserrat-Bold", size: 32))
                    .foregroundStyle(Color(red: 2 / 255, green: 125 / 255, blue: 244 / 255))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 16)
                    .padding(.top, 42)
                
                Spacer()

                
                ZStack(alignment: .center) {
                   
                    
                    Image("FifthOnboardBGThree")
                        .resizable()
                        .scaledToFit()
  
                }
                
                Spacer()
                
                
                Text("98% Success Rate. Remove water now before internal corrosion starts.")
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
    OnboardingNewFifthViewThree(index: 3) {
        print("1")
    }
}
