//
//  SecondSeventhOnboardView.swift
//  WaterEject
//
//  Created by Ruslan Liulka on 21.11.2025.
//

import SwiftUI

struct SecondSeventhOnboardView: View {
    
    let action: () -> Void
    private func handleCTA() {
        
        action()
    }
    
    
    var body: some View {
        
        
        OnboardCustomNewSecond(ctaTitle: "Continue", ctaAction: handleCTA, fixedWidth: 260) {
            
            Color(red: 225 / 255, green: 233 / 255, blue: 239 / 255).ignoresSafeArea()
            
            
            Text("😵‍💫 Speaker sounds messed up?")
                .foregroundStyle(.black)
                .font(.system(size: 18, weight: .bold))
            
            
        }
    }
}

#Preview {
    SecondSeventhOnboardView(action: { print("N")})
}


