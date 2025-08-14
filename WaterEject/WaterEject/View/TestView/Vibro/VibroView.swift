//
//  VibroVIew.swift
//  WaterEject
//
//  Created by Ruslan Liulka on 08.08.2025.
//

import SwiftUI

struct VibroView: View {
    @StateObject private var viewModel = VibroViewModel()
    var onContinue: () -> Void
    
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
                    
                    ForEach(VibroModel.allCases, id: \.self) { mode in
                        VibroCard(testMode: mode,
                                  isSelected: viewModel.vibroMode == mode,
                                  isCompleted: viewModel.completedModes.contains(mode),
                                  onChangeCategory: { selected in
                            viewModel.vibroMode = selected
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
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 12)
            .padding(.top, 6)
            
            Button {
                viewModel.playVibro()
            } label: {
                Label("Play Vibro", systemImage: "play.fill")
                    .font(.system(size: 17, weight: .semibold))
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)
            }
            .buttonStyle(.borderedProminent)
            .tint(.blue)
            .padding(.top, 12)
            
            Button(action: onContinue) {
                Text("Continue")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color(red: 81/255, green: 132/255, blue: 234/255))
                    )
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 40)
            
            
        }
    }
}

struct VibroCard: View {
    let testMode: VibroModel
    let isSelected: Bool
    let isCompleted: Bool
    let onChangeCategory: (VibroModel) -> Void
    
    var body: some View {
        Button {
            onChangeCategory(testMode)
        } label: {
            VStack(spacing: 8) {
                Image(systemName: testMode.imageName)
                    .foregroundStyle(isCompleted ? Color(red: 43 / 255, green: 217 / 255, blue: 156 / 255) : isSelected ? Color(red: 161 / 255, green: 192 / 255, blue: 255 / 255) : Color(red: 179/255, green: 179/255, blue: 179/255))
                Text(testMode.testName)
                    .font(.system(size: 15))
                    .foregroundStyle(isCompleted ? Color(red: 43 / 255, green: 217 / 255, blue: 156 / 255) : isSelected ? Color(red: 161 / 255, green: 192 / 255, blue: 255 / 255) : Color(red: 179/255, green: 179/255, blue: 179/255))
            }
            .frame(width: 96, height: 72)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(isCompleted ? Color(red: 43 / 255, green: 217 / 255, blue: 156 / 255).opacity(0.14) : isSelected ? Color(red: 81 / 255, green: 132 / 255, blue: 234 / 255).opacity(0.14) : Color.white.opacity(0.05))
                
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(isCompleted ? Color(red: 43 / 255, green: 217 / 255, blue: 156 / 255) : Color.clear,
                            lineWidth: 1)
            )
            .overlay(alignment: .topTrailing) {
                if isCompleted {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(.green)
                        .padding(6)
                }
            }
            .contentShape(RoundedRectangle(cornerRadius: 16))
            .animation(.easeInOut(duration: 0.15), value: isSelected)
            .animation(.easeInOut(duration: 0.15), value: isCompleted)
            
        }
        .buttonStyle(.plain)
    }
}


// MARK: - Reusable pill button

struct IntensityPill: View {
    let level: IntensityLevel
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 10) {
                Text(level.title)
                    .font(.system(size: 15, weight: .semibold))
                
                
                    .foregroundStyle(isSelected ? Color(red: 238 / 255, green: 255 / 255, blue: 246 / 255) :Color(red: 161 / 255, green: 192 / 255, blue:  255 / 255))
                
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(Color(red: 43 / 255, green: 217 / 255, blue: 156 / 255))
                }
            }
            .padding(.horizontal, 16)
            
            .padding(.vertical, 10)
            .frame(maxWidth: .infinity, minHeight: 32)
            .background(
                Capsule()
                    .fill(isSelected ? Color(red: 43 / 255, green: 217 / 255, blue: 156 / 255).opacity(0.14) : Color.clear)
            )
            .overlay(
                Capsule()
                    .stroke(isSelected ? Color(red: 43 / 255, green: 217 / 255, blue: 156 / 255) : Color(red: 81 / 255, green: 132 / 255, blue: 234 / 255), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
        .contentShape(Capsule())
    }
}



#Preview {
    VibroView {
        print("hello")
    }
}
