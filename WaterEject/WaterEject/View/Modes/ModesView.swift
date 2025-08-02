//
//  ModesView.swift
//  WaterEject
//
//  Created by Ruslan Liulka on 01.08.2025.
//

import SwiftUI

struct ModesView: View {
    @Environment(\.dismiss) private var dismiss
    let device: String
    
    var body: some View {
        ZStack {
            Color(red: 19 / 255, green: 21 / 255, blue: 23 / 255)
                .ignoresSafeArea()
            
            Ellipse()
                .strokeBorder(Color.white.opacity(0.05), lineWidth: 1.5)
                .background(
                    Ellipse()
                        .fill(Color.white.opacity(0.01))
                )
                .frame(width: 431, height: 80)
                .offset(y: 210)
            
            
            Ellipse()
                .fill(Color.white.opacity(0.25)) // 25% прозорість
                .frame(width: 343, height: 56)
                .blur(radius: 70) // SwiftUI blur radius не зовсім 1:1 з Figma, 70–90 виглядає схоже
                .offset(y: 210)
            
            Ellipse()
                .strokeBorder(Color.white.opacity(0.05), lineWidth: 1)
                .background(
                    Ellipse()
                        .fill(Color.white.opacity(0.01))
                )
                .frame(width: 257, height: 30)
                .offset(y: 210)
            
            Rectangle()
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color(red: 25/255, green: 14/255, blue: 13/255),
                            Color(red: 81/255, green: 132/255, blue: 234/255)   // #5184EA
                            // #190E0D
                        ]),
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(width: 375, height: 161)
                .opacity(0.5)        // 50% прозорість як у Figma
                .blur(radius: 100)   // Blur 196 у SwiftUI виглядає схоже на 100-130, тож підбери вручну!
                .offset(y: 240)
            
            VStack(spacing: 28) {
                HStack {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "chevron.backward")
                        Text("Back")
                            .font(.system(size: 17))
                    }
                    
                    Spacer()
                    
                    Text(device)
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.white)
                    Spacer()
                    Button(action: {
                        print("Setting pressed")
                    }) {
                        Image(systemName: "gearshape")
                            .font(.system(size: 24))
                            .foregroundStyle(Color(red: 153 / 255, green: 153 / 255, blue: 153 / 255))
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 16)
                
                
                Spacer()
                
            }
        }
    }
}

#Preview {
    ModesView(device: "Iphone")
}
