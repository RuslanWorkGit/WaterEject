//
//  OnboardingNewSeventhViewOne.swift
//  WaterEject
//
//  Created by Ruslan Liulka on 08.05.2026.
//

import SwiftUI

struct OnboardingNewSeventhViewOne: View {
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
            
            //            Image("FifthOnboardBGOne")
            //                .resizable()
            //                .scaledToFit()
            //                .ignoresSafeArea()
            
            VStack(spacing: 10) {
                Spacer()
                
                ZStack(alignment: .bottom) {
                    
                    
                    
                    
                }
                
                
                Text("Restore Your Speaker’s Original Sound Easily")
                    .font(.custom("Montserrat-SemiBold", size: 24))
                    .foregroundStyle(.black)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 16)
                
                
                Text("Push water and dust out using advanced sonic technology. The same method used by Apple Watch.")
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
                
                Image("FifthOnboardBGOne")
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
    OnboardingNewSeventhViewOne(index: 0) {
        print("1")
    }
}
