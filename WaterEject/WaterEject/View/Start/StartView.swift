//
//  StartView.swift
//  WaterEject
//
//  Created by Ruslan Liulka on 01.08.2025.
//

import SwiftUI

struct StartView: View {
    @StateObject private var viewModel = StartViewModel()
    @Environment(\.dismiss) private var dismiss
    @State private var showVolumeAlert: Bool = false
    let device: CleaningDevice
    let mode: CleaningMode
    
    var body: some View {
        ZStack {
            Background(startCleaning: viewModel.startCleaning)
            
            VStack(spacing: 28) {
                
                ZStack {
                    Text(device.displayName)
                        .font(.system(size: 28, weight: .bold))
                        .foregroundStyle(.white)
                    
                    HStack {
                        Button {
                            dismiss()
                            viewModel.stopTimer()
                        } label: {
                            Image(systemName: "chevron.backward")
                                .foregroundStyle(viewModel.startCleaning ? Color(red: 161 / 255, green: 192 / 255, blue: 255 / 255, opacity: 0.35) : Color(red: 161 / 255, green: 192 / 255, blue: 255 / 255))
                            Text("Back")
                                .font(.system(size: 17))
                                .foregroundStyle(viewModel.startCleaning ? Color(red: 161 / 255, green: 192 / 255, blue: 255 / 255, opacity: 0.35) : Color(red: 161 / 255, green: 192 / 255, blue: 255 / 255))
                        }
                        .disabled(viewModel.startCleaning)
                        
                        Spacer()
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 8)
                
                SelectedModeCard(
                    deviceIcon: "devices",
                    title: mode.modeName,
                    isActive: viewModel.startCleaning,
                    onSettings: { print("Settings tapped") }
                )
                .padding(.horizontal, 24)
                
                
                VStack {
                    Image(device.bigImageName)

                        .padding(.top, 60)
                    
    
                }
                
                Spacer()
                
                ZStack {
                    // Таймер
                    Text("00:\(String(format: "%02d", viewModel.countdown))")
                        .font(.system(size: 48, weight: .bold))
                        .foregroundColor(.white)
                        .opacity(viewModel.startCleaning ? 1 : 0)
            
                        .animation(.easeInOut, value: viewModel.startCleaning)

                    // Кнопка
                    Button {
                        showVolumeAlert = true

                    } label: {
                        Text("Start cleaning (25 sec)")
                            .foregroundStyle(Color.white)
                            .padding(.vertical, 14)
                            .padding(.horizontal, 88)
                            .background(
                                Capsule()
                                    .fill(Color(red: 81 / 255, green: 132 / 255, blue: 234 / 255))
                            )
                    }
                    .opacity(viewModel.startCleaning ? 0 : 1)
                    .animation(.easeInOut, value: viewModel.startCleaning)
                }
                .frame(height: 68) // Однакова висота завжди!
                .padding(.bottom, 24)

            }
        }
        .alert(isPresented: $showVolumeAlert) {
            Alert(
                title: Text("Set Volume to Max"),
                message: Text("For the most effective cleaning, please set your device volume to maximum."),
                primaryButton: .default(Text("OK")) {
                    switch mode {
                    case .sonicPulse:
                        viewModel.playCleaningSequence()
                        viewModel.startTimer()
                    case .nanoShake:
                        viewModel.playSomeWav()
                        viewModel.startTimer()
                    case .dynamicEject:
                        viewModel.playCleaningSequenceTwo()
                        viewModel.startTimer()
                    case .hydroGuard:
                        viewModel.playCleaningSequenceThree()
                        viewModel.startTimer()
                    case .microCheck:
                        viewModel.startTimer()
                    }
                },
                secondaryButton: .cancel()
            )
        }

    }
}




struct SelectedModeCard: View {
    let deviceIcon: String      // ім'я зображення для іконки пристрою
    let title: String           // довга назва режиму
    var isActive: Bool = false
    let onSettings: () -> Void  // дія на натискання шестерні
    
    var body: some View {
        HStack(spacing: 14) {
            // Іконка пристрою
            Image(deviceIcon)
                .resizable()
                .scaledToFit()
                .frame(width: 36, height: 36)
                .padding(.leading, 4)
            
            VStack(alignment: .leading, spacing: 2) {
                Text("Selected mode:")
                    .font(.system(size: 13, weight: .regular))
                    .foregroundStyle(.white.opacity(0.6))
                Text(title)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(.white)
                    .lineLimit(1)
                    .truncationMode(.tail)
            }
            .padding(.vertical, 8)
            
            Spacer()
            
            // Кнопка-іконка
            Button(action: onSettings) {
                Image(systemName: "gearshape")
                    .font(.system(size: 26))
                    .foregroundStyle(.white.opacity(0.45))
                    .padding(2)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 18)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.05))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(isActive ? Color(red: 81/255, green: 132/255, blue: 234/255) : Color.clear, lineWidth: 1)
            
        )
        //        .overlay(
        //            RoundedRectangle(cornerRadius: 12)
        //                .shadow(color: isActive ? Color(red: 81/255, green: 132/255, blue: 234/255, opacity: 1) : .clear, radius: 24, x: 0, y: 0)
        //        )
        
        .animation(.easeInOut(duration: 0.3), value: isActive)
    }
}

#Preview {
    StartView(device: .iPhone , mode: .nanoShake)
}
