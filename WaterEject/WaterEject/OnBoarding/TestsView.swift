//
//  TestsView.swift
//  WaterEject
//
//  Created by Ruslan Liulka on 06.08.2025.
//

import SwiftUI

struct TestsView: View {
    
    @StateObject var viewModel = TestsViewModel()
    
    // Дані для grid
    private let tests: [(icon: String, label: String)] = [
        ("circle.hexagongrid", "Stereo"),
        ("dot.radiowaves.left.and.right", "Bass"),
        ("mic", "Micro"),
        ("dot.radiowaves.left.and.right", "Vibro"),
        ("circle.dotted", "Noise")
    ]
    
    // Дві колонки (гнучкі)
    private let columns = [
        GridItem(.flexible(), spacing: 14),
        GridItem(.flexible(), spacing: 14)
    ]
    
    var body: some View {
        ZStack {
            Background()
            
            VStack(alignment: .center) {
                (
                    Text("Post-Cleaning Check: Make Sure Your Device Works Properly")
                        .foregroundStyle(Color(red: 238 / 255, green: 255 / 255, blue: 236 / 255))
                    
                    
                    
                    
                )
                .font(.system(size: 32, weight: .bold))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 24)
                .padding(.bottom, 4)
                
                
                Text("Test your audio with 5 simple checks")
                    .font(.system(size: 14))
                    .foregroundStyle(Color(red: 238 / 255, green: 255 / 255, blue: 236 / 255))
                    .padding(.bottom, 42)
                
                ZStack {
                    Image("Lines")
                    
                    VStack(spacing: 15) {
                        Text("32dB")
                            .font(.system(size: 80, weight: .bold))
                            .foregroundStyle(Color(red: 238 / 255, green: 255 / 255, blue: 236 / 255))
                        ZStack {
                            Image("BlueWave")
                            Image("BlackWave")
                        }
                    }
                    .offset(y: -20)
                }
                
                
//                LazyVGrid(columns: columns, spacing: 0) {
//                    ForEach(tests, id: \.label) { test in
//                        TestCheckCard(
//                            icon: test.icon,
//                            label: test.label,
//                            isChecked: viewModel.checked[test.label] ?? false
//                        ) {
//                            viewModel.toggle(test.label)
//                        }
//                    }
//                }
//                .padding(.top, 4)
//                .padding(.horizontal, 12)
//                .padding(.bottom, 18)
                
                
                
            }
            .frame(maxHeight: .infinity, alignment: .top)
            .padding(.horizontal, 12)
            .padding(.top, 50)
            
            
            
        }
    }
}

struct TestCheckCard: View {
    let icon: String
    let label: String
    let isChecked: Bool
//    let onTap: () -> Void
    
    var body: some View {
  
            ZStack(alignment: .topTrailing) {
                // Основний контент
                HStack(spacing: 14) {
                    Image(systemName: icon)
                        .font(.system(size: 15, weight: .medium))
                        .foregroundStyle(Color(red: 43/255, green: 217/255, blue: 156/255))
                    Text(label)
                        .font(.system(size: 15, weight: .medium))
                        .foregroundStyle(Color(red: 43/255, green: 217/255, blue: 156/255))
                    Spacer()
                }
                .padding(.vertical, 18)
                .padding(.horizontal, 18)
                
                // Checkmark у правому верхньому куті
                Image(systemName: isChecked ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 16))
                    .foregroundStyle(Color(red: 43/255, green: 217/255, blue: 156/255))
                    .padding(8) // змісти від країв
            }
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(red: 43/255, green: 217/255, blue: 156/255, opacity: 0.14))
            )
            .frame(height: 70)
        }

    
}



#Preview {
    TestsView()
}
