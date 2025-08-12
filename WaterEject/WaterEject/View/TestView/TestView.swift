//
//  TestView.swift
//  WaterEject
//
//  Created by Ruslan Liulka on 08.08.2025.
//

import SwiftUI

struct TestView: View {
    
    @StateObject private var viewModel = TestViewModel()
    let onFinish: () -> Void
    
    var body: some View {
        ZStack {
            Background()
            VStack {
                
                HStack {
                    
                    Text("Audio Tests")
                        .foregroundStyle(Color(red: 247 / 255, green: 247 / 255, blue: 247 / 255))
                        .font(.system(size: 20, weight: .semibold))
                    
                    Spacer()
                    
                    Text("0/5 passed")
                        .foregroundStyle(Color(red: 196 / 255, green: 196 / 255, blue: 197 / 255))
                        .font(.system(size: 12))
                        .padding(5)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.white.opacity(0.05))
                        )
                    
                    
                }
                .padding(.horizontal, 24)
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        
                        ForEach(TestMode.allCases) { mode in
                            FeatureCard(testMode: mode, onChangeCategory: { mode in
                                viewModel.mode = mode
                            })
                            
                        }
                        
                    }
                    .padding(.horizontal, 10)
                }
                .frame(height: 140)
                .padding(.leading, 8)
                .padding(.top, -10)
                
                switch viewModel.mode {
                case .stereo:
                    StereoView()
                case .bass:
                    BassView(onContinue: { viewModel.goToNextStep()})
                case .micro:
                    MicroView()
                case .vibro:
                    VibroVIew()
                case .noise:
                    NoiseView()
                }
                
                if viewModel.mode == .bass {
                    
                } else {
                    bottomButton
                }
                
            }
            .background(Color.clear)
            
        }
        
        
    }
    
    private var bottomButton: some View {
            VStack {
                Spacer()
                let isLast = viewModel.mode == TestMode.allCases.last
                Button {
                    if isLast {
                        onFinish()            // ← повертаємо на Home
                    } else {
                        viewModel.goToNextStep()
                    }
                } label: {
                    Text(isLast ? "Finish" : "Continue")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(Color(red: 81/255, green: 132/255, blue: 234/255))
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 40) // підлаштуй під дизайн
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
        }

    
}



struct FeatureCard: View {
    let testMode: TestMode
    let onChangeCategory: (TestMode) -> Void
    
    var body: some View {
        
        Button {
            onChangeCategory(testMode)
        } label: {
            VStack(spacing: 8) {
                Image(testMode.imageName)
                
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
    TestView(onFinish: { print("HElllo") })
}
