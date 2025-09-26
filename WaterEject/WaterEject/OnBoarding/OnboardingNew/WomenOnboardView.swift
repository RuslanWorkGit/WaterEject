//
//  WomenOnboardView.swift
//  WaterEject
//
//  Created by Ruslan Liulka on 26.09.2025.
//

import SwiftUI

struct WomenOnboardView: View {
    let action: () -> Void
    var body: some View {
        let isLarge = UIScreen.main.bounds.height > 900
        
        ZStack {
            LinearGradient(
                colors: [Color.white,
                         Color(red: 201/255, green: 214/255, blue: 238/255)],
                startPoint: .top, endPoint: .bottom
            )
            .ignoresSafeArea()
            
            Image("Women")
            //.zIndex(1)
//                .colorMultiply(.black)
                .offset(y: 70)
            
            VStack {
                Image("Recomend")
                    .scaleEffect(isLarge ? 1.2 : 1)
                    .padding(.bottom, 60)
                
                ZStack {
                    Image("GreyLines")
                    

                        ZStack {
                            Image("WhiteWave")
                                .scaleEffect(1.1)
                            
                            Image("BlueWave")
                                .scaleEffect(1.1)
                                .offset(y: 8)

                        }
                    
                    .offset(y: -20)
                }
                .padding(.bottom, 150)
                
                ZStack {

//      
                    Image("SquareBack-2")
                        .offset(y: -50)
                        .opacity(0.6)
                    
                    Image("SquareBack-1")
                        .offset(y: -25)
                        .opacity(0.7)

                    
                    
                    ReviewCard(
                        name: "Olivia",
                        title: "It saved my iPhone!",
                        text: "I tried countless methods to fix my phone, but nothing worked. Then I discovered this speaker cleaner app! It brought my phone back to life!",
                        rating: 5
                    )
                    .padding(.horizontal, 16)
                    
                }
                .padding(.bottom, 24)
               
                
                PillButton(title: "Continue", action: action, arrow: true)
                    .padding(.horizontal, 80)
                
            }
            


        }
    }
}

import SwiftUI

struct ReviewCard: View {
    let name: String
    let title: String
    let text: String
    let rating: Int

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .firstTextBaseline) {
                HStack(spacing: 4) {
                    ForEach(0..<5, id: \.self) { i in
                        Image(systemName: i < rating ? "star.fill" : "star")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(Color(red: 81/255, green: 132/255, blue: 234/255))
                    }
                }
                Spacer()
                Text(name)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(.primary)
            }

            Text(title)
                .font(.system(size: 16, weight: .heavy))

            Text(text)
                .font(.system(size: 14))
                .lineSpacing(3)
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)

                .fill(
                    LinearGradient(
                        colors: [Color.white.opacity(0.65), Color.white.opacity(0.15)],
                        startPoint: .top,  // як у Figma Linear
                        endPoint: .bottom
                    )
                )
                

                
        )
        .padding(.horizontal, 16)
        
    }
}



#Preview {
    WomenOnboardView(action: { print("hello")})
}
