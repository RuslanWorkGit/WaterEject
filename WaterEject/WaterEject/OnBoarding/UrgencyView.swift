//
//  UrgencyView.swift
//  WaterEject
//
//  Created by Ruslan Liulka on 06.08.2025.
//

import SwiftUI

struct UrgencyView: View {
    var body: some View {
        ZStack {
            Background()
            
            VStack(alignment: .center) {
                (
                    Text("Left untreated, water can")
                        .foregroundStyle(Color(red: 238 / 255, green: 255 / 255, blue: 236 / 255)) +
                    Text(" permanently ")
                        .foregroundStyle(Color(red: 247 / 255, green: 192 / 255, blue: 67 / 255)) +
                    Text("damage sound!")
                        .foregroundStyle(Color(red: 238 / 255, green: 255 / 255, blue: 236 / 255))
                )
                .font(.system(size: 32, weight: .bold))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 24)
                .padding(.bottom, 54)
                
                ComparisonTable()

                
                
            }
            .frame(maxHeight: .infinity, alignment: .top)
            .padding(.horizontal, 12)
            .padding(.top, 50)
            
        }
    }
}

struct ComparisonTable: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header
            HStack {
                Text("Broken")
                    .foregroundStyle(.white)
                    .font(.system(size: 18, weight: .semibold))
                Spacer()
                Text("Normal")
                    .foregroundStyle(.white)
                    .font(.system(size: 18, weight: .semibold))
                Spacer()
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 12)
            
            //Divider().background(.white.opacity(0.07))
            
            ForEach(tableData) { row in
                Text(row.category)
                    .font(.system(size: 10))
                    .foregroundStyle(Color(red: 196 / 255, green: 196 / 255, blue: 197 / 255))
                    .padding(.horizontal, 24)
                    .padding(.top, 8)
                HStack(alignment: .top, spacing: 0) {
                    // Broken
                    
                    HStack(spacing: 7) {
                        
                        
                        Image(systemName: "exclamationmark.circle.fill")
                            .foregroundStyle(Color(red: 247/255, green: 192/255, blue: 67/255))
                        Text(row.broken)
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(Color(red: 247/255, green: 192/255, blue: 67/255))
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    
                    // Normal
                    HStack(spacing: 7) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundStyle(Color(red: 43/255, green: 217/255, blue: 156/255))
                        Text(row.normal)
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(Color(red: 43/255, green: 217/255, blue: 156/255))
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding(.vertical, 13)
                .padding(.horizontal, 24)
                
                Divider().background(.white.opacity(0.07))
            }
        }
//        .background(
//            RoundedRectangle(cornerRadius: 22)
//                .fill(Color.white.opacity(0.02))
//        )
        .padding(.horizontal, 8)
    }
}

// Дані для таблиці (можеш розширити)
struct ComparisonRow: Identifiable {
    let id = UUID()
    let broken: String
    let normal: String
    let category: String
}

let tableData: [ComparisonRow] = [
    .init(broken: "200–10,000 Hz", normal: "20–20,000 Hz", category: "Frequency Response"),
    .init(broken: "> ±4 dB", normal: "±1 dB", category: "Channel Balance (L/R)"),
    .init(broken: "< 60 dB", normal: "> 90 dB", category: "Signal-to-Noise Ratio (SNR)"),
    .init(broken: "60–80 dB SPL", normal: "90–100 dB SPL", category: "Output Volume Level"),
    .init(broken: "> 100 ms", normal: "< 50 ms", category: "Impulse Response Decay")
]


#Preview {
    UrgencyView()
}
