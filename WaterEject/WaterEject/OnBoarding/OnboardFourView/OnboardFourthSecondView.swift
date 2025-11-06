//
//  OnboardFourthSecondView.swift
//  WaterEject
//
//  Created by Ruslan Liulka on 06.11.2025.
//

import SwiftUI

struct OnboardFourthSecondView: View {
    let action: () -> Void
    private func handleCTA() {
        selectedDeviceRaw = tempSelected.rawValue
        action()
    }
    
    @AppStorage("selectedDevice") private var selectedDeviceRaw: String = ChooseReason.first.rawValue
    @State private var tempSelected: ChooseReason = .first
    
    var body: some View {
        
        
        
        
        OnboardScaffold(ctaTitle: "Continue", ctaAction: handleCTA, fixedWidth: 260) {
            // увесь твій контент екрану, БЕЗ кнопки!
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
                        Text("What happened to your iPhone?").font(.system(size: 30, weight: .semibold))
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
                
                
                ForEach(ChooseReason.allCases) { reason in
                    SelectableChip(title: reason.rawValue,
                                   isSelected: Binding(
                                    get: { tempSelected == reason },
                                    set: { if $0 { tempSelected = reason } }
                                   )
                                   
                    )
                }
                
                Spacer()
                
                
            }
            .padding(.horizontal, 32)
        }
        }
        .onAppear {
            tempSelected = ChooseReason(rawValue: selectedDeviceRaw) ?? .first
        }
    }
}

#Preview {
    OnboardFourthSecondView(action: {print("H")})
}
