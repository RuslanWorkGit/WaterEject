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
        @State private var showEdit = false

        // якщо збережено enum — показуємо його title, якщо довільний текст — показуємо як є
        private var deviceName: String {
            ChooseDevice(rawValue: selectedDeviceRaw)?.rawValue ?? selectedDeviceRaw
        }
    
    var body: some View {
        
        OnboardScaffoldNew(ctaTitle: "Continue", ctaAction: handleCTA, fixedWidth: 260) {
            
            LinearGradient(gradient: Gradient(stops: [
                .init(color: Color(red: 255/255, green: 255/255, blue: 255/255).opacity(1), location: 0),
                .init(color: Color(red: 222/255, green: 233/255, blue: 255/255).opacity(1), location: 0.5),
                .init(color: Color(red: 255/255, green: 255/255, blue: 255/255).opacity(1), location: 1.0)
            ]), startPoint: .top, endPoint: .bottom)
            .ignoresSafeArea()
            ScrollView{
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
                    
                    
                    InfoActionCard(
                        title: "Device name:",
                        value: deviceName,
                        iconName: "square.and.pencil",
                        action: { showEdit = true }
                    )
                   
                    .sheet(isPresented: $showEdit) {
                        EditNameSheet(name: $selectedDeviceRaw)
                        
                        
                    }
                    .padding(.horizontal, 32)
                }
            }
            
            
        }
    }
}

struct InfoActionCard: View {
    // Основні параметри
    let title: String
    let value: String
    var iconName: String = "square.and.pencil"     // SF Symbol
    var action: () -> Void                          // натиск на іконку

    // Стилі (можеш змінити під тему)
    var cornerRadius: CGFloat = 20
    var gradient: LinearGradient = LinearGradient(
        colors: [Color.white, Color(red: 0.92, green: 0.96, blue: 1.0)],
        startPoint: .top, endPoint: .bottom
    )
    var strokeColor: Color = Color.white.opacity(0.6)
    var iconBG: Color = .white
    var iconColor: Color = Color(red: 0.16, green: 0.28, blue: 0.73) // темно-синій

    var body: some View {
        HStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 6) {
                Text(title)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(Color(red: 0.23, green: 0.25, blue: 0.28))

                Text(value)
                    .font(.system(size: 22, weight: .bold))
                    .foregroundStyle(Color(red: 0.07, green: 0.07, blue: 0.07))
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            Button(action: action) {
                Image(systemName: iconName)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(iconColor)
                    .frame(width: 44, height: 44)
                    .background(Circle().fill(iconBG))
                    .shadow(color: .black.opacity(0.06), radius: 8, y: 2)
            }
            .buttonStyle(.plain)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .fill(gradient)
        )
        .overlay(
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .stroke(strokeColor, lineWidth: 1)
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
