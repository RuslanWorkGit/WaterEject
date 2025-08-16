//
//  HookView.swift
//  WaterEject
//
//  Created by Ruslan Liulka on 06.08.2025.
//

import SwiftUI

struct HookView: View {
    var body: some View {
        ZStack {
            Background()
            
            VStack(alignment: .center) {
                (
                    Text("Water")
                        .foregroundStyle(Color(red: 161 / 255, green: 192 / 255, blue: 255 / 255)) +
                    Text("💦 stuck in your speakers, iPhone, or AirPods?")
                        .foregroundStyle(Color(red: 238 / 255, green: 255 / 255, blue: 236 / 255))
                )
                .font(.system(size: 30, weight: .bold))
                .multilineTextAlignment(.center)
                .padding(.bottom, 96)
                
                
                

                
                ZStack {
                    Image("airpodsMaxBig")
                    Image("Attention")
                        .offset(x: 30, y: -110)
                }
                
                Text("We found water in your device!")
                    .padding(12)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(Color(red: 247 / 255, green: 192 / 255, blue: 67 / 255))
                    .background(Color(red: 61 / 255, green: 56 / 255, blue: 42 / 255))
                    .clipShape(Capsule())
                

                
                
            }
            .frame(maxHeight: .infinity, alignment: .top)
            .padding(.horizontal, 18)
            .padding(.top, 50)
            
        }
        
        
    }
}

#Preview {
    HookView()
}
