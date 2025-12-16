//
//  BackGroundNew.swift
//  WaterEject
//
//  Created by Ruslan Liulka on 16.12.2025.
//


//
import SwiftUI

struct BackgroundNew: View {
    var startCleaning: Bool = false
    
    var body: some View {
        LinearGradient(colors: [Color(red: 19 / 255, green: 21 / 255, blue: 23 / 255), Color(red: 29 / 255, green: 34 / 255, blue: 42 / 255)], startPoint: .top, endPoint: .bottom)
            .ignoresSafeArea()
        

        

        
        
//        Rectangle()
//            .fill(
//                LinearGradient(
//                    gradient: Gradient(colors: [
//                        Color(red: 25/255, green: 14/255, blue: 13/255),
//                        Color(red: 81/255, green: 132/255, blue: 234/255)   // #5184EA
//                        // #190E0D
//                    ]),
//                    startPoint: .top,
//                    endPoint: .bottom
//                )
//            )
//            .frame(width: 375, height: 161)
//            .opacity(0.5)        // 50% прозорість як у Figma
//            .blur(radius: 100)   // Blur 196 у SwiftUI виглядає схоже на 100-130, тож підбери вручну!
//            .offset(y: 240)
    }
}

#Preview {
    ZStack {
        BackgroundNew()
        
    }
}
