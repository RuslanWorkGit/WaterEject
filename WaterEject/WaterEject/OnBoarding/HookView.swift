//
//  HookView.swift
//  WaterEject
//
//  Created by Ruslan Liulka on 06.08.2025.
//

import SwiftUI

struct HookView: View {
    var body: some View {
        
        let isLarge = UIScreen.main.bounds.height > 900
        
        ZStack {
            Background()
            
            VStack(alignment: .center) {
                (
                    Text("Get ")
                        .foregroundStyle(Color(red: 238 / 255, green: 255 / 255, blue: 236 / 255)) +
                    Text("water")
                        .foregroundStyle(Color(red: 161 / 255, green: 192 / 255, blue: 255 / 255)) +
                    Text("💦 out of your iPhone & AirPods in 30 seconds!")
                        .foregroundStyle(Color(red: 238 / 255, green: 255 / 255, blue: 236 / 255))
                )
                .font(.system(size: 30, weight: .bold))
                .multilineTextAlignment(.center)
                .padding(.bottom, 4)
                .padding(.horizontal, 40)
                
                
                Text("Safe sound frequencies push liquid out instantly")
                    .font(.system(size: 16))
                    .foregroundStyle(Color(red: 238 / 255, green: 255 / 255, blue: 236 / 255))
                    .padding(.bottom, isLarge ? 80 : 42)
                

                    Image("HookImage")
                        .resizable()
                        .scaledToFit()
                        .scaleEffect(isLarge ? 1.2 : 1)
                        .animation(.easeInOut(duration: 0.2), value: isLarge)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                        .frame(height: 400)
                
                // висота області під зображення (щоб GeometryReader не займав увесь екран)
                
                
                //                ZStack {
                //                    Image("HookImage")
                //                        .resizable()
                //
                //
                //
                //                }
                //
                //                Text("We found water in your device!")
                //                    .padding(12)
                //                    .font(.system(size: 14, weight: .semibold))
                //                    .foregroundStyle(Color(red: 247 / 255, green: 192 / 255, blue: 67 / 255))
                //                    .background(Color(red: 61 / 255, green: 56 / 255, blue: 42 / 255))
                //                    .clipShape(Capsule())
                
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
