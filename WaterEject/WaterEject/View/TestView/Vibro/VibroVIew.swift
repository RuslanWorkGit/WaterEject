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
            
            Text("Pater")
                .multilineTextAlignment(.leading)
            
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


#Preview {
    VibroView()
}
