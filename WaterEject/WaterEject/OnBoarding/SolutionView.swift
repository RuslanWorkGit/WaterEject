//
//  SolutionView.swift
//  WaterEject
//
//  Created by Ruslan Liulka on 06.08.2025.
//

import SwiftUI

struct SolutionView: View {
    
    private let tests: [(icon: String, label: String)] = [
        ("circle.hexagongrid", "Stereo"),
        ("dot.radiowaves.left.and.right", "Bass"),
        ("mic", "Micro"),
        ("dot.radiowaves.left.and.right", "Vibro"),
    ]
    
    private let columns = [
        GridItem(.flexible(), spacing: 14),
        GridItem(.flexible(), spacing: 14)
    ]
    
    
    var body: some View {
        
        let isLarge = UIScreen.main.bounds.height > 900
        
        ZStack {
            Background()
            
            VStack(alignment: .center) {
                (
                    Text("Go Deeper with ")
                        .foregroundStyle(Color(red: 238 / 255, green: 255 / 255, blue: 236 / 255)) +
                    Text("Premium")
                        .foregroundStyle(Color(red: 247 / 255, green: 192 / 255, blue: 67 / 255))
                )
                .font(.system(size: 30, weight: .bold))
                .multilineTextAlignment(.center)
                .padding(.bottom, 24)
                .padding(.horizontal, 40)
                
                
                VStack(spacing: isLarge ? 12 : 8) {
                    HorizontalTextSolution(title: "Deep Cleaning mode for stubborn water", image: "slider.vertical.3", isLarge: isLarge)
                    HorizontalTextSolution(title: "Extra sound frequencies for maximum effect", image: "powermeter", isLarge: isLarge)
                    HorizontalTextSolution(title: "Faster and stronger result", image: "graduationcap", isLarge: isLarge)
                    HorizontalTextSolution(title: "Unlimited use, no limits", image: "sparkles", isLarge: isLarge)
                }
                .padding(.bottom, 94)
                .padding(.leading, 20)
                
                (
                    Text("Make Sure Your Device ")
                        .font(.system(size: 30, weight: .semibold))
                        .foregroundStyle(Color(red: 238 / 255, green: 255 / 255, blue: 236 / 255)) +
                    Text("Works Properly")
                        .font(.system(size: 30, weight: .bold))
                        .foregroundStyle(Color(red: 238 / 255, green: 255 / 255, blue: 236 / 255))
                )
                .multilineTextAlignment(.center)
                

                
                LazyVGrid(columns: columns, spacing: 0) {
                    ForEach(tests, id: \.label) { test in
                        TestCheckCard(
                            icon: test.icon,
                            label: test.label,
                            isChecked: true
                        ) 
                    }
                }
                .padding(.top, 4)
                .padding(.horizontal, 12)
                .padding(.bottom, 18)

                
            }
            .frame(maxHeight: .infinity, alignment: .top)
            .padding(.horizontal, 18)
            .padding(.top, 50)

            
        }

    }
}


struct HorizontalTextSolution: View {
    let title: String
    let image: String
    let isLarge: Bool
    
    var body: some View {
        HStack {
            Image(systemName: image)
                .resizable()
                .frame(width: isLarge ? 18 : 16, height: isLarge ? 18 : 16)
                .foregroundStyle(Color(red: 43 / 255, green: 217 / 255, blue: 156 / 255))
            Text(title)
                .font(.system(size: isLarge ? 18 : 16))
                .foregroundStyle(Color(red: 238 / 255, green: 255 / 255, blue: 246 / 255))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

#Preview {
    SolutionView()
}
