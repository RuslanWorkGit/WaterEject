//
//  OnboardFourthFifthView.swift
//  WaterEject
//
//  Created by Ruslan Liulka on 06.11.2025.
//

import SwiftUI

struct OnboardFourthFifthView: View {
    let action: () -> Void
    private func handleCTA() {
        
        action()
    }
    
    @AppStorage("selectedDevice") private var selectedDeviceRaw: String = ChooseDevice.iphone.rawValue
    @AppStorage("selectedReason") private var selectedReasonRaw: String = ChooseReason.first.rawValue
    @AppStorage("selectedSound") private var selectedSoundRaw: String = ChooseMuffledSound.first.rawValue
    @AppStorage("selectedTime") private var selectedTimeRaw: String = ChooseTime.first.rawValue
    @State private var showEditDevice = false
    @State private var showEditReason = false
    @State private var showEditSound = false
    @State private var showEditTime = false

        // якщо збережено enum — показуємо його title, якщо довільний текст — показуємо як є
        private var deviceName: String {
            ChooseDevice(rawValue: selectedDeviceRaw)?.rawValue ?? selectedDeviceRaw
        }
    
    private var reason: String {
        ChooseReason(rawValue: selectedReasonRaw)?.rawValue ?? selectedReasonRaw
    }
    
    private var sound: String {
        ChooseMuffledSound(rawValue: selectedSoundRaw)?.rawValue ?? selectedSoundRaw
    }
    
    private var time: String {
        ChooseTime(rawValue: selectedTimeRaw)?.rawValue ?? selectedTimeRaw
    }
    
    var body: some View {
        
        OnboardScaffoldNew(ctaTitle: "Continue", ctaAction: handleCTA, fixedWidth: 260) {
            
            LinearGradient(gradient: Gradient(stops: [
                .init(color: Color(red: 255/255, green: 255/255, blue: 255/255).opacity(1), location: 0),
                .init(color: Color(red: 222/255, green: 233/255, blue: 255/255).opacity(1), location: 0.5),
                .init(color: Color(red: 255/255, green: 255/255, blue: 255/255).opacity(1), location: 1.0)
            ]), startPoint: .top, endPoint: .bottom)
            .ignoresSafeArea()
            //ScrollView{
                VStack {
                    Group {
                        
                        (
                            Text("Calibrating your device...").font(.system(size: 30, weight: .semibold))
                        )
                        .foregroundStyle(Color(red: 17/255, green: 17/255, blue: 17/255))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                        .padding(.top, 16)
                        .padding(.bottom, 12)
                        
                        Text("Choose your device to start the check-up.")
                            .font(.system(size: 16))
                            .foregroundStyle(Color(red: 59/255, green: 65/255, blue: 72/255))
                            .padding(.bottom, 42)
                    }
                    
                    Group {
                        InfoActionCard(
                            title: "Device name:",
                            value: deviceName,
                            action: { showEditDevice = true }
                        )
                        
                        .sheet(isPresented: $showEditDevice) {
                            EditNameSheet(name: $selectedDeviceRaw)
                            
                        }
                        
                        InfoActionCard(
                            title: "Situateion:",
                            value: reason,
                            action: { showEditReason = true }
                        )
                        .sheet(isPresented: $showEditReason) {
                            EditNameSheet(name: $selectedReasonRaw)
                            
                            
                        }
                        
                        InfoActionCard(
                            title: "Sound issue:",
                            value: sound,
                            action: { showEditSound = true }
                        )
                        .sheet(isPresented: $showEditSound) {
                            EditNameSheet(name: $selectedSoundRaw)
                            
                            
                        }
                        
                        InfoActionCard(
                            title: "Time since exposure:",
                            value: time,
                            action: { showEditTime = true }
                        )
                        .sheet(isPresented: $showEditTime) {
                            EditNameSheet(name: $selectedTimeRaw)
                            
                            
                        }
                        
                    }
                    
                    .padding(.horizontal, 32)
                    
                    Spacer()
                    
                    HStack {
                        Image(systemName: "checkmark")
                            .foregroundStyle(Color(red: 34/255, green: 155/255, blue: 87/255))
                        
                        Text("Dual speakers detected")
                            .font(.system(size: 16))
                            .foregroundStyle(Color(red: 34/255, green: 155/255, blue: 87/255))
                            
                    }
                    .padding(.bottom, 14)
                }
                
                
                
            //}
            
            
        }
    }
}

struct InfoActionCard: View {
    // Основні параметри
    let title: String
    let value: String
    var action: () -> Void                          // натиск на іконку

    // Стилі (можеш змінити під тему)
    var cornerRadius: CGFloat = 8
//    var gradient: LinearGradient = LinearGradient(
//        colors: [Color.white, Color(red: 0.92, green: 0.96, blue: 1.0)],
//        startPoint: .top, endPoint: .bottom
//    )
    var strokeColor: Color = Color.white.opacity(0.6)
    var iconBG: Color = .white
    var iconColor: Color = Color(red: 0.16, green: 0.28, blue: 0.73) // темно-синій

    var body: some View {
        HStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 6) {
                Text(LocalizedStringKey(title))
                    .font(.system(size: 15, weight: .regular))
                    .foregroundStyle(Color(red: 59 / 255, green: 65 / 255, blue: 72 / 255))

                Text(value)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(Color(red: 17 / 255, green: 17 / 255, blue: 17 / 255))
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            Button(action: action) {
                Image("squareAndPencil")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(iconColor)
                    .frame(width: 44, height: 44)
                    .background(
                        Circle().fill(iconBG)
                            .innerShadow(
                                Circle(),
                                color: Color(red: 17 / 255, green: 17 / 255, blue: 17 / 255), opacity: 0.05,
                                x: 0, y: -1, blur: 0, spread: 1
                            )
                            .innerShadow(
                                Circle(),
                                color: .white, opacity: 0.5,
                                x: 0, y: 1, blur: 0, spread: 1
                            )
                    )
                    .shadow(color: .black.opacity(0.06), radius: 8, y: 2)
            }
            .buttonStyle(.plain)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .fill(.white.opacity(0.35))
                .innerShadow(
                    RoundedRectangle(cornerRadius: cornerRadius),
                    color: Color(red: 17 / 255, green: 17 / 255, blue: 17 / 255), opacity: 0.05,
                    x: 0, y: -1, blur: 0, spread: 2
                )
                .innerShadow(
                    RoundedRectangle(cornerRadius: cornerRadius),
                    color: .white, opacity: 0.5,
                    x: 0, y: 1, blur: 0, spread: 2
                )
        )

        .contentShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(title) \(value)")
    }
}

struct EditNameSheet: View {
    @Binding var name: String
    @Environment(\.dismiss) var dismiss
    var body: some View {
        NavigationView {
            Form {
                TextField("Device name", text: $name)
            }
            .navigationTitle("Edit name")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}


#Preview {
    OnboardFourthFifthView(action: {print("H")})
}
