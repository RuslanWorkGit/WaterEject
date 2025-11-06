//
//  OnboardFourthFirstView.swift
//  WaterEject
//
//  Created by Ruslan Liulka on 06.11.2025.
//

import SwiftUI

struct OnboardFourthFirstView: View {
    let action: () -> Void
    private func handleCTA() {
        selectedDeviceRaw = tempSelected.rawValue
        action()
    }
    
    @AppStorage("selectedDevice") private var selectedDeviceRaw: String = ChooseDevice.iphone.rawValue
    @State private var tempSelected: ChooseDevice = .iphone
    
//    @AppStorage("selectedDevice") private var selectedDeviceRaw: String = ChooseDevice.iphone.rawValue
//        private var selectedDevice: ChooseDevice {
//            get { ChooseDevice(rawValue: selectedDeviceRaw) ?? .iphone }
//            set { selectedDeviceRaw = newValue.rawValue }
//        }
//    
    var body: some View {


            
            
        OnboardScaffold(ctaTitle: "Continue", ctaAction: handleCTA, fixedWidth: 260) {
            // увесь твій контент екрану, БЕЗ кнопки!
            LinearGradient(gradient: Gradient(stops: [
                .init(color: Color(red: 255/255, green: 255/255, blue: 255/255).opacity(1), location: 0),
                .init(color: Color(red: 222/255, green: 233/255, blue: 255/255).opacity(1), location: 0.5),
                .init(color: Color(red: 255/255, green: 255/255, blue: 255/255).opacity(1), location: 1.0)
            ]), startPoint: .top, endPoint: .bottom)
            .ignoresSafeArea()
            
            VStack {
                Group {
                    
                    (
                        Text("What device are we rescuing? ").font(.system(size: 30, weight: .semibold))
                        + Text("💦").font(.system(size: 30, weight: .medium))
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
                
                
                ForEach(ChooseDevice.allCases) { device in
                    SelectableChip(title: device.rawValue,
                                   isSelected: Binding(
                                               get: { tempSelected == device },
                                               set: { if $0 { tempSelected = device } }
                                           )
                                    
                    )
                }
                
                Spacer()
            
                
            }
            .padding(.horizontal, 32)
        }
        .onAppear {
            tempSelected = ChooseDevice(rawValue: selectedDeviceRaw) ?? .iphone
        }

        
    }
}

struct SelectableChip: View {
    let title: String
    @Binding var isSelected: Bool
    
    var body: some View {
        Button {
            isSelected.toggle()
        } label: {
            HStack(spacing: 12) {
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .imageScale(.large)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(isSelected ? Color(red: 81 / 255, green: 132 / 255, blue: 234 / 255) : Color(red: 195 / 255, green: 198 / 255, blue: 205 / 255))

                Text(title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(Color(red: 17 / 255, green: 17 / 255, blue: 17 / 255))

                Spacer(minLength: 0)
            }
            .padding(.vertical, 19)
            .padding(.horizontal, 14)
            .contentShape(RoundedRectangle(cornerRadius: 16))
        }
        .buttonStyle(.plain)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(isSelected ? Color(red: 81 / 255, green: 132 / 255, blue: 234 / 255) : Color.white.opacity(0),
                        lineWidth: isSelected ? 1 : 1)
        )
        .animation(.easeInOut(duration: 0.15), value: isSelected)
    }
}


#Preview {
    OnboardFourthFirstView(action: {print("N")})
}
