//
//  IconCard.swift
//  WaterEject
//
//  Created by Ruslan Liulka on 02.08.2025.
//

import SwiftUI

struct IconCard: View {
    let icon: String

    
    var body: some View {
        Circle()
            .fill(
                LinearGradient(
                    colors: [
                        Color(red: 20 / 255, green: 23 / 255, blue: 26 / 255, opacity: 0.1),
                        Color(red: 222 / 255, green: 233 / 255, blue: 255 / 255, opacity: 0.2)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            
        Circle()
            .stroke(Color.white.opacity(0.25), lineWidth: 2)
            .blur(radius: 0.5)
            .offset(x: 0, y: 1)
            .mask(
                Circle().fill(
                    LinearGradient(colors: [.black, .clear], startPoint: .top, endPoint: .bottom)
                )
            )
            

            Image(icon)

        

    }
}

#Preview {
    IconCard(icon: "Drop")
}
