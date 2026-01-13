//
//  SevenDaysPlanCard.swift
//  WaterEject
//
//  Created by Ruslan Liulka on 23.12.2025.
//

import SwiftUI

struct SevenDayPlanCardView: View {
    let completedDays: Int
    let onTap: () -> Void

    private let active = Color(red: 2 / 255, green: 125 / 255, blue: 244 / 255)
    private let inactiveStroke = Color.white.opacity(0.22)
    private let inactiveText = Color.white.opacity(0.60)
    
    private var isPad: Bool { UIDevice.current.userInterfaceIdiom == .pad }
    private var padScale: CGFloat { isPad ? 1.4 : 1.0 }
    private var circle: CGFloat { isPad ? 44 : 32 }

    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 16) {

                HStack(alignment: .center, spacing: 10) {
                    VStack(alignment: .leading, spacing: 3) {
                        Text("7-day cleaning Plan:")
                            .font(.system(size: 16 * padScale, weight: .semibold))
                            .foregroundStyle(.white)

                        Text("Perform a complete cleaning by daily cleaning")
                            .font(.system(size: 12 * padScale, weight: .regular))
                            .foregroundStyle(Color.white)
                            .lineLimit(2)
                    }

                    Spacer(minLength: 8)

                        
                        Image(systemName: "chevron.right")
                            .font(.system(size: 20 * padScale, weight: .semibold))
                            .foregroundStyle(Color(red: 161 / 255, green: 192 / 255, blue: 255 / 255))
                    
                    
                }
                
                Divider().background(Color.white.opacity(0.1))
                

                HStack {
                    ForEach(1...7, id: \.self) { day in
                        dayCircle(day: day, isCompleted: day <= completedDays)
                            .frame(maxWidth: .infinity)
                        
                    }
                }

            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(Color(red: 28 / 255, green: 45 / 255, blue: 61 / 255))
            )

        }
        .buttonStyle(.plain)
    }

    @ViewBuilder
    private func dayCircle(day: Int, isCompleted: Bool) -> some View {
        ZStack {
            Circle()
                .stroke(isCompleted ? active : inactiveStroke, lineWidth: 2)
                .frame(width: circle, height: circle)

            Text("\(day)")
                .font(.system(size: 13 * padScale, weight: .semibold))
                .foregroundStyle(isCompleted ? .white : inactiveText)
        }
    }
}

#Preview {
    SevenDayPlanCardView(completedDays: 1, onTap: {
        
    })
}
