//
//  TestView.swift
//  WaterEject
//
//  Created by Ruslan Liulka on 08.08.2025.
//

import SwiftUI

struct TestView: View {
    
    @StateObject private var viewModel = TestViewModel()
    let onBack: () -> Void       // ← новий колбек
    let onFinish: () -> Void
    
    @State private var loggedModes: Set<TestMode> = []
    @State private var didLogStart = false
    
    var body: some View {
        ZStack {
            Background()
            VStack {
                
                HStack {
                    Button(action: onBack) {
                        Image(systemName: "chevron.backward")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundStyle(Color(red: 161/255, green: 192/255, blue: 255/255))
                    }
                    
                    Text("Audio Tests")
                        .foregroundStyle(Color(red: 247 / 255, green: 247 / 255, blue: 247 / 255))
                        .font(.system(size: 20, weight: .semibold))
                    
                    Spacer()
                    
                    Text("\(viewModel.completedModesTest.count) / 4 passed")
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
                            FeatureCard(testMode: mode,
                                        isSelected: viewModel.mode == mode,
                                        isCompleted: viewModel.completedModesTest.contains(mode),
                                        onChangeCategory: { mode in
                                viewModel.mode = mode
                            })
                            
                        }
                        
                    }
                    .padding(.horizontal, 10)
                }
                .frame(height: 140)
                .padding(.leading, 8)
                //.padding(.top, -10)
                
                switch viewModel.mode {
                case .stereo:
                    StereoView(onContinue: { viewModel.goToNextStep()})
                case .bass:
                    BassView(onContinue: { viewModel.goToNextStep()})
                case .micro:
                    MicroView(onContinue: { viewModel.goToNextStep()})
                case .vibro:
                    VibroView(onContinue: { onFinish() })
                    
                }
                
                
                
                
            }
            .padding(.horizontal, 14)
            .background(Color.clear)
            
        }
        .navigationBarBackButtonHidden(true)
        .background(BackSwipeEnabler(onBack: onBack))
        .onAppear {
            // Старт усієї сесії тестів
            if !didLogStart {
//                Telemetry.shared.testStart()
                didLogStart = true
            }
            // Лог для поточного екрану (першого)
            logCurrentModeIfNeeded()
        }
        .onChange(of: viewModel.mode) { _, _ in
            // Лог при переході між екранами
            logCurrentModeIfNeeded()
        }
        
        
    }
    
    private func logCurrentModeIfNeeded() {
        let mode = viewModel.mode
        guard !loggedModes.contains(mode) else { return }
//        Telemetry.shared.testScreenOpen(mode)
        loggedModes.insert(mode)
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
    let isSelected: Bool
    let isCompleted: Bool
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
                    .fill(isCompleted ? Color(red: 43 / 255, green: 217 / 255, blue: 156 / 255).opacity(0.14) : isSelected ? Color(red: 81 / 255, green: 132 / 255, blue: 234 / 255).opacity(0.14) : Color.white.opacity(0.03))
            )
        }
        .background(
            RoundedRectangle(cornerRadius: 16)
                .stroke(isCompleted ? Color(red: 43 / 255, green: 217 / 255, blue: 156 / 255) : Color.clear, lineWidth: 1)
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
}


#Preview {
    TestView(onBack: {print("hello")},onFinish: { print("HElllo") })
}
