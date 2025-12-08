//
//  SecondWomenView.swift
//  WaterEject
//
//  Created by Ruslan Liulka on 08.12.2025.
//

import SwiftUI

struct SecondWomenView: View {
    let action: () -> Void
    let textButton: String
    private func handleCTA() {
        
        action()
    }
    
    var body: some View {
        ZStack {
            Color(red: 215 / 255, green: 222 / 255, blue: 231 / 255).ignoresSafeArea()
            
            
            

            
            Image("WomenLight")
                .resizable()
                .scaledToFit()
                .frame(maxWidth: .infinity,
                       maxHeight: .infinity,
                       alignment: .bottom)   // щоб «притиснути» донизу

                .clipped()
                .ignoresSafeArea()
            
            OnboardNewStyle(ctaTitle: textButton, ctaAction: handleCTA, fixedWidth: 260) {
                
                LinearGradient(gradient: Gradient(stops: [
                    .init(color: Color(red: 225 / 255, green: 233 / 255, blue: 239 / 255).opacity(0), location: 0),
                    .init(color: Color(red: 225 / 255, green: 233 / 255, blue: 239 / 255).opacity(0), location: 0.5),
                    .init(color: Color(red: 225 / 255, green: 233 / 255, blue: 239 / 255).opacity(0.7), location: 1.0)
                ]), startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()
                
//                LinearGradient(colors: [Color(red: 225 / 255, green: 233 / 255, blue: 239 / 255).opacity(0), Color(red: 225 / 255, green: 233 / 255, blue: 239 / 255).opacity(0.7)], startPoint: .top, endPoint: .bottom).ignoresSafeArea()
                
                VStack {
        
                    
                    
                    Spacer()
                    
                    VStack(alignment: .center) {
                        Text("SPEAKER")
                            .font(.custom("Montserrat-ExtraBold", size: 42))
                            .foregroundStyle(Color(red: 45 / 255, green: 127 / 255, blue: 249 / 255))
                            .multilineTextAlignment(.center)
                            .padding(.top, 64)
                            //.padding(.bottom, 12)
                        

                        
                        Text("CLEANER")
                            .font(.custom("Montserrat-Bold", size: 36))
                            .multilineTextAlignment(.center)
                            .foregroundStyle(Color(red: 45 / 255, green: 127 / 255, blue: 249 / 255))
                            .padding(.horizontal, 20)
                            .padding(.bottom, 40)

                    }
                    
                    
                    
                }
                
                
            }
            
            
        }
    }
}

#Preview {
    SecondWomenView(action: { print("N")}, textButton: "Continue")
}
