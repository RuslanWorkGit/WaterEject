//
//  NewCleanModeCard.swift
//  WaterEject
//
//  Created by Ruslan Liulka on 23.12.2025.
//

import SwiftUI


struct NewCleaningModeCard: View {
    // Пропси для повторного використання
    let mode: NewCleaningMode
    let isSmall: Bool
    let isLocked: Bool
    let lockAssetName: String
    let onModeAction: (NewCleaningMode) -> Void
    
    private var isPad: Bool { UIDevice.current.userInterfaceIdiom == .pad }
    private var padScale: CGFloat { isPad ? 1.3 : 1.0 }
    
    
    init(
        mode: NewCleaningMode,
        isSmall: Bool,
        isLocked: Bool = false,
        lockAssetName: String = "Lock",
        onModeAction: @escaping (NewCleaningMode) -> Void
    ) {
        self.mode = mode
        self.isSmall = isSmall
        self.isLocked = isLocked
        self.lockAssetName = lockAssetName
        self.onModeAction = onModeAction
    }
    
    var body: some View {
        
        Button {
            onModeAction(mode)
        } label: {
            VStack(alignment: .leading, spacing: 8) {
                HStack(alignment: .top, spacing: 12) {
                    ZStack {
                        
                        if isLocked {
                            Image(lockAssetName) // твій asset
                                .scaleEffect(padScale)
                                .padding(18 * padScale)
                                .background(
                                    Circle()
                                        .fill(Color(red: 2 / 255, green: 125 / 255, blue: 244 / 255).opacity(0.08))
                                )
                        } else {
                            Image(mode.iconAssetName)
                                .scaleEffect(padScale)
                                .padding(18 * padScale)
                                .background(
                                    Circle()
                                        .fill(Color(red: 2 / 255, green: 125 / 255, blue: 244 / 255).opacity(0.08))
                                )
                            
                        }
                        
                        // IconCard(icon: icon)
                        
                    }
                    .frame(width: 48, height: 48)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        HStack {
                            Text(mode.modeName)
                                .font(.system(size: (isSmall ? 14 : 16) * padScale, weight: .semibold))
                                .foregroundStyle(.white)
                            
                        }
                        Text(mode.explainText)
                            .multilineTextAlignment(.leading)
                            .font(.system(size: (isSmall ? 10 : 10) * padScale))
                            .foregroundColor(Color.white.opacity(0.8))
                    }
                    .padding(.bottom, 10)
                }
                
                Divider().background(Color.white.opacity(0.1))
                
                HStack(spacing: 6) {
                    
                    ForEach(Array(mode.tags.prefix(2)), id: \.self) { tag in
                        Text(tag)
                            .font(.system(size: (isSmall ? 12 : 12) * padScale, weight: .medium))
                            .foregroundStyle(Color(red: 196/255, green: 196/255, blue: 197/255))
                            .padding(.horizontal, 6)
                            .lineLimit(1)
                            .padding(.vertical, 5)
                            .background(Color(red: 2/255, green: 125/255, blue: 244/255).opacity(0.08))
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                        
                    }
                    
                    
                    Spacer()
                    Image(systemName: "clock")
                        .font(.system(size: (isSmall ? 14 : 16) * padScale, weight: .regular))
                        .foregroundStyle(Color(red: 2 / 255, green: 125 / 255, blue: 244 / 255))
                    Text(mode.durationText)
                    //.font(.system(size: 12))
                        .font(.system(size: (isSmall ? 10 : 12) * padScale, weight: .medium))
                        .foregroundStyle(Color(red: 2 / 255, green: 125 / 255, blue: 244 / 255))
                    
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
        .disabled(isLocked)
        
    }
    
}

//#Preview {
//    ZStack {
//        BackgroundNew()
//        NewCleaningModeCard(icon: "NewWaterDrop", mode: .waterRemoval, deviceIcon: "SmallWave", firstHesh: "#Clean", deviceColor: Color(red: 161/255, green: 225/255, blue: 255/255), secondHesh: "#LowFrequency", time: "25 seconds", isSmall: true) { new in
//
//        }
//        .padding(.horizontal, 16)
//
//    }
//}
