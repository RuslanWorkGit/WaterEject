//
//  ThirdWaveView.swift
//  WaterEject
//
//  Created by Ruslan Liulka on 08.12.2025.
//

import SwiftUI

struct ThirdWaveView: View {
    let action: () -> Void
    let textButton: String
    private func handleCTA() {
        
        action()
    }
    
    var body: some View {
        
        OnboardWaterDrops(ctaTitle: textButton, ctaAction: handleCTA, pages: 0, fixedWidth: 260) {
            
            Color(red: 225 / 255, green: 233 / 255, blue: 239 / 255).ignoresSafeArea()
            
            VStack() {
                VStack(alignment: .center) {
                    Text("Hear Every Tone")
                        .font(.custom("Montserrat-SemiBold", size: 36))
                        .foregroundStyle(Color(red: 45 / 255, green: 127 / 255, blue: 249 / 255))
                        .multilineTextAlignment(.center)
                        .padding(.top, 64)
                    
                    Text("Clearly")
                        .font(.custom("Montserrat-ExtraBold", size: 44))
                        .foregroundStyle(Color(red: 45 / 255, green: 127 / 255, blue: 249 / 255))
                        .multilineTextAlignment(.center)

        
                    

                }
                
            
                
                Image("OnboardWaves")
                    .resizable()
                    .scaledToFit()
                    .padding(.horizontal, -10)
                
                Spacer()
                
                (
                    Text("Scan the full range from ")
                        .foregroundStyle(.black.opacity(0.7))
                        .font(.custom("Montserra-Medium", size: 20))
                    +
                    Text("10 ")
                        .foregroundStyle(.black.opacity(0.7))
                        .font(.custom("Montserra-Bold", size: 20))
                    +
                    Text("to ")
                        .foregroundStyle(.black.opacity(0.7))
                        .font(.custom("Montserra-Medium", size: 20))
                    +
                    Text("20,000 Hz ")
                        .foregroundStyle(.black.opacity(0.7))
                        .font(.custom("Montserra-Bold", size: 20))
                    +
                    Text("to spot sound issues instantly.")
                        .foregroundStyle(.black.opacity(0.7))
                        .font(.custom("Montserra-Medium", size: 20))
                )
                .multilineTextAlignment(.center)
                .padding(.horizontal, 34)
                .padding(.top, 42)
                .padding(.bottom, 22)
                
                
            }
            
        }
        
    }
}

#Preview {
    ThirdWaveView(action: { print("N")}, textButton: "Continue")
}
