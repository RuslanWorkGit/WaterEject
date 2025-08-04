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
    @State private var startCleaning: Bool = false
    @State private var start: String?
    @State private var countdown: Int = 25
    @State private var timer: Timer? = nil
    let device: String
    let mode: String
    
    var body: some View {
        ZStack {
            Background()
            
            VStack(spacing: 28) {
                HStack {
                    Button {
                        dismiss()
                        startCleaning = false // Reset when going back
                    } label: {
                        Image(systemName: "chevron.backward")
                        Text("Back")
                            .font(.system(size: 17))
                    }
                    
                    Spacer()
                    
                    Text(device)
                        .font(.system(size: 28, weight: .bold))
                        .foregroundStyle(.white)
                    
                    Spacer()
                }
                .padding(.horizontal, 24)
                .padding(.top, 16)
                
                SelectedModeCard(
                    deviceIcon: "devices",
                    title: mode,
                    isActive: startCleaning,
                    onSettings: {
                        print("Settings tapped")
                    }
                )
                .padding(.horizontal, 24)
                
                VStack {
                    Image("devices")
                        .resizable()
                        .frame(width: 201, height: 256)
                        .padding(.top, 60)
                    
                    if startCleaning {
                        Image("activeDrop")
                            .offset(y: -15)
                        
                        Image("waterEllipse")
                            .offset(y: -40)
                    }
                    
                }
                
                
                Spacer()
                
                ZStack {
                    if startCleaning {
                        Text("00:\(countdown) ")
                            .font(.system(size: 48, weight: .bold))
                            .foregroundColor(.white)
                            .padding(.bottom, 40)
                            .onAppear {
                                // Запускаємо таймер лише якщо не стартував
                                viewModel.startTimer()
                            }
                            .onDisappear {
                                viewModel.stopTimer()
                            }
                    }
                    else {
                        Button {
                            startCleaning = true
                            // Add logic to reset startCleaning after 25 seconds or when cleaning ends
                            DispatchQueue.main.asyncAfter(deadline: .now() + 25) {
                                startCleaning = false
                            }
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
                    }
                }
            }
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
    StartView(device: "Iphone", mode: "Some Mode")
}
