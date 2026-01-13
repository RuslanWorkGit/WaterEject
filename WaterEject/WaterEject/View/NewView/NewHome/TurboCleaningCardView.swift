//
//  TurboCleaningCardView.swift
//  WaterEject
//
//  Created by Ruslan Liulka on 24.12.2025.
//

import SwiftUI


struct TurboCleaningCardView: View {
    let icon: String
    let mode: NewCleaningMode
    let mainText: String
    let secondText: String
    let isSmall: Bool
    let onModeAction: (NewCleaningMode) -> Void
    
    private var isPad: Bool { UIDevice.current.userInterfaceIdiom == .pad }
    private var padScale: CGFloat { isPad ? 1.3 : 1.0 }
    
    var body: some View {
        
        VStack(alignment: .leading, spacing: 32) {
            HStack(alignment: .center, spacing: 16) {
                ZStack {
                    
                    Image(icon)
                        .scaleEffect(padScale)
                        .padding(18 * padScale)
                        .background(
                            Circle()
                                .fill(Color(red: 238 / 255, green: 176 / 255, blue: 0 ).opacity(0.08))
                        )

        
                    
                }
                .frame(width: 48, height: 48)
                
                VStack(alignment: .leading) {
                    Text(mainText)
                        .font(.system(size: (isSmall ? 16 : 18) * padScale, weight: .semibold))
                        .foregroundStyle(.white)
                    
                    Text(secondText)
                        .font(.system(size: (isSmall ? 12 : 12) * padScale, weight: .regular))
                        .foregroundStyle(Color(red: 196 / 255, green: 196 / 255, blue: 197 / 255))
                }
               
                
                
                
                Button {
                    onModeAction(mode)
                } label: {
                    Text("Start")
                        .font(.system(size: (isSmall ? 14 : 16) * padScale, weight: .medium))
                        .foregroundStyle(.white)
                        .padding(.vertical, 14)
                        .frame(maxWidth: .infinity)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color(red: 2 / 255, green: 125 / 255, blue: 244 / 255))
                        )
                    
                    
                }
                .padding(.leading, 20)
                

            }
                        



            }
            
 

        .padding(18)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Color(red: 2 / 255, green: 125 / 255, blue: 244 / 255).opacity(0.08))
                .shadow(color: .black.opacity(0.18), radius: 16, x: 0, y: 4)
        )
        
        //            .padding(.horizontal, 24)
        //.padding(.horizontal, isSmall ? 8 : 0)
        .padding(.vertical, 6)
        
        
    }
    
}


#Preview {
    ZStack {
        BackgroundNew()
        TurboCleaningCardView(icon: "Lightning", mode: .waterRemoval, mainText: "Turbo Cleaning", secondText: "Advaced", isSmall: true) { new in
            
        }
        .padding(.horizontal, 16)
        
    }
}
