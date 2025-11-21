//
//  BlueLinesView.swift
//  WaterEject
//
//  Created by Ruslan Liulka on 21.11.2025.
//

import SwiftUI

struct BlueLinesView: View {
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
                    Text("Discover the Power").font(.system(size: 26, weight: .bold))
                        .foregroundStyle(.black)
                        .multilineTextAlignment(.center)
                        .padding(.top, 64)
                        //.padding(.bottom, 12)
                    
                    Text("of Frequency").font(.system(size: 26, weight: .semibold))
                        .foregroundStyle(.black)
                        .multilineTextAlignment(.center)
                        //.padding(.top, 40)
                        .padding(.bottom, 12)
                    
                    Text("Different sound waves push moisture out safely.")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(Color(red: 59/255, green: 65/255, blue: 72/255))
                        .padding(.bottom, 40)

                }
                
            
                
                Image("BlueLineImg")
                    .resizable()
                    .scaledToFit()
                    .padding(.horizontal, -10)
                
                Spacer()
                
                
            }
            
        }
        
    }
}

#Preview {
    BlueLinesView(index: 1 ,action: { print("N")})
}

