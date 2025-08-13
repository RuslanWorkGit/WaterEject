//
//  VibroVIew.swift
//  WaterEject
//
//  Created by Ruslan Liulka on 08.08.2025.
//

import SwiftUI

struct VibroView: View {
    @StateObject private var viewModel = VibroViewModel()
    
    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                Image("Lines")
                
                VStack(spacing: 15) {
                    Text("Vibro")
                        .font(.system(size: 80, weight: .bold))
                        .foregroundStyle(Color(red: 238 / 255, green: 255 / 255, blue: 236 / 255))
                    ZStack {
                        Image("Heart")
                    }
                }
                .offset(y: -20)
            }
            
            Text("Patern")
                .font(.system(size: 14))
                .foregroundStyle(.white.opacity(0.9))
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 24)
                .padding(.top, 6)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    
                    ForEach(VibroModel.allCases) { mode in
                        VibroCard(testMode: mode, onChangeCategory: { mode in
                            viewModel.vibroMode = mode
                        })
                        
                    }
                    
                }
                .padding(.horizontal, 10)
            }
            .frame(height: 140)
            .padding(.leading, 8)
            .padding(.top, -10)
            
            Text("Intensity")
                .font(.system(size: 14))
                .foregroundStyle(.white.opacity(0.9))
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 24)
                .padding(.top, 8)
            
            HStack(spacing: 12) {
                ForEach(IntensityLevel.allCases) { level in
                    IntensityPill(
                        level: level,
                        isSelected: viewModel.intensity == level
                    ) {
                        viewModel.intensity = level
                    }
                }
            }
            .padding(.horizontal, 12)
            .padding(.top, 4)
            
            
        }
    }
}

struct VibroCard: View {
    let testMode: VibroModel
    let onChangeCategory: (VibroModel) -> Void
    
    var body: some View {
        
        Button {
            onChangeCategory(testMode)
        } label: {
            VStack(spacing: 8) {
                Image(systemName: testMode.imageName)
                
                Text(testMode.testName)
                    .font(.system(size: 15))
                    .foregroundStyle(Color(red: 179 / 255, green: 179 / 255, blue: 179 / 255))
            }
            .frame(width: 96, height: 72)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white.opacity(0.03))
            )
        }
        
        
    }
}

// MARK: - Reusable pill button

struct IntensityPill: View {
    let level: IntensityLevel
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            ZStack(alignment: .topTrailing) {
                Text(level.title)
                    .font(.system(size: 15, weight: .semibold))
                    .padding(.horizontal, 18)
                    .padding(.vertical, 10)
                    .frame(minWidth: 104, alignment: .center)
                    .background(
                        Capsule()
                            .fill(isSelected ? Color.green.opacity(0.18) : Color.clear)
                    )
                    .overlay(
                        Capsule()
                            .stroke(isSelected ? Color.green : Color.white.opacity(0.25), lineWidth: 1)
                    )
                    .foregroundStyle(isSelected ? Color.green : Color.white.opacity(0.9))
                
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(Color.green)
                        .background(Color.black.opacity(0.6).clipShape(Circle()))
                        .offset(x: 6, y: -6)
                }
            }
        }
        .buttonStyle(.plain)
    }
}



#Preview {
    VibroView()
}
