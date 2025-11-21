//
//  MeetView.swift
//  WaterEject
//
//  Created by Ruslan Liulka on 21.11.2025.
//

import SwiftUI

struct MeetView: View {
    let index: Int
    let action: () -> Void
    private func handleCTA() {
        
        action()
    }
    
    var body: some View {
        
        OnboardWaterDrops(ctaTitle: "Start Cleaning", ctaAction: handleCTA, pages: 3, pageIndex: index, fixedWidth: 260) {
            
            Color(red: 225 / 255, green: 233 / 255, blue: 239 / 255).ignoresSafeArea()
            
            VStack() {
                VStack(alignment: .center) {
                    Text("Meet the Cleaning Modes")
                        .font(.system(size: 26, weight: .bold))
                        .foregroundStyle(.black)
                        .multilineTextAlignment(.center)
                        .padding(.top, 64)
                        //.padding(.bottom, 12)
                    

                    
                    Text("Each one is tuned for a specific purpose — from deep water ejection to frequency modulation.")
                        .font(.system(size: 12, weight: .semibold))
                        .multilineTextAlignment(.center)
                        .foregroundStyle(Color(red: 59/255, green: 65/255, blue: 72/255))
                        .padding(.horizontal, 20)
                        .padding(.bottom, 80)

                }
                
            
                
                Image("LastImg")
                    .resizable()
                    .scaledToFit()
                    .padding(.horizontal, 5)
                
                Spacer()
                
                
            }
            
        }
        
    }
}

#Preview {
    MeetView(index: 2 ,action: { print("N")})
}
