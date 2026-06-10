//
//  Untitled.swift
//  WaterEject
//
//  Created by Ruslan Liulka on 24.12.2025.
//

import SwiftUI


struct BigCardStartCleaningView: View {
    let icon: String
    let mode: NewCleaningMode
    let day: String
    let mainText: String
    let deviceIcon: String
    let firstHesh: String
    let deviceColor: Color
    let secondHesh: String
    let time: String
    let isSmall: Bool
    let onModeAction: (NewCleaningMode) -> Void
    
    private var isPad: Bool { UIDevice.current.userInterfaceIdiom == .pad }
    private var padScale: CGFloat { isPad ? 1.3 : 1.0 }
    private var padScaleImage: CGFloat { isPad ? 1.5 : 1.0 }
    
    var body: some View {
        
        VStack(alignment: .leading, spacing: 32) {
            HStack(alignment: .center, spacing: 16) {
                ZStack {
                    
                    Image(icon)
                        .scaleEffect(padScale)
                        .padding(18 * padScale)
                        .background(
                            Circle()
                                .fill(Color(red: 2 / 255, green: 125 / 255, blue: 244 / 255).opacity(0.08))
                        )

        
                    
                }
                .frame(width: 48, height: 48)
                
                Text(day)
                    .font(.system(size: (isSmall ? 16 : 18) * padScale, weight: .medium))
                    .foregroundStyle(.white)
                

            }
            
            VStack(alignment: .leading, spacing: 2) {
                HStack {
                    Text(mainText)
                        .font(.system(size: (isSmall ? 38 : 42) * padScale, weight: .bold))
                        .foregroundStyle(.white)
                        .padding(.top, 32)
                        .fixedSize(horizontal: false, vertical: true)
                    
                    
                }
            }
            .padding(.bottom, 10)
            
            
            VStack(alignment: .leading) {
                
                Text("Today’s areas")
                    .font(.system(size: (isSmall ? 12 : 12) * padScale, weight: .medium))
                    .foregroundStyle(.white)
                
                HStack(spacing: 10) {
                    
                    Text(firstHesh)
                        .font(.system(size: (isSmall ? 12 : 12) * padScale, weight: .medium))
                        .foregroundStyle(.white.opacity(0.6))
                        .foregroundStyle(Color(red: 196 / 255, green: 196 / 255, blue: 197 / 255))
                        .padding(.horizontal, 6)
                        .padding(.vertical, 5)
                        .background(Color(red: 2 / 255, green: 125 / 255, blue: 244 / 255).opacity(0.08))
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                    
                    Text(secondHesh)
                        .font(.system(size: (isSmall ? 12 : 12) * padScale))
                        .foregroundStyle(.white.opacity(0.6))
                        .foregroundStyle(Color(red: 196 / 255, green: 196 / 255, blue: 197 / 255))
                        .padding(.horizontal, 6)
                        .padding(.vertical, 5)
                        .background(Color(red: 2 / 255, green: 125 / 255, blue: 244 / 255).opacity(0.08))
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                    
                    
                }
            
            
                VStack {
                    Button {
                        onModeAction(mode)
                    } label: {
                        Text("Start Cleaning")
                            .font(.system(size: (isSmall ? 14 : 16) * padScale, weight: .medium))
                            .foregroundStyle(.white)
                            .padding(.vertical, 14)
                            .frame(maxWidth: .infinity)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color(red: 2 / 255, green: 125 / 255, blue: 244 / 255))
                            )
                        
                        
                    }
                    
                    Text("Best after rain or water exposure")
                        .font(.system(size: (isSmall ? 12 : 12) * padScale))
                        .foregroundStyle(.white.opacity(0.6))
                    
                }


            }
            
            
            
            
        }
        .overlay(alignment: .topTrailing, content: {
            Image("PhoneIcone")
                .resizable()
                .scaledToFit()
                .offset(x: 18, y: -18)
                .frame(width: 220 * padScaleImage)
            
        })
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
        BigCardStartCleaningView(icon: "NewWaterDrop", mode: .waterRemoval, day: "Day 1", mainText: "Water \nRemovel", deviceIcon: "SmallWave", firstHesh: "#Clean", deviceColor: Color(red: 161/255, green: 225/255, blue: 255/255), secondHesh: "#LowFrequency", time: "25 seconds", isSmall: true) { new in
            
        }
        .padding(.horizontal, 16)
        
    }
}
