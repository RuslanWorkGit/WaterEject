//
//  OnboardFourthThirdView.swift
//  WaterEject
//
//  Created by Ruslan Liulka on 06.11.2025.
//

import SwiftUI

struct OnboardFourthThirdView: View {
    let action: () -> Void
    private func handleCTA() {
        guard let sound = tempSelected else {
            showAlert = true
            return
        }
        selectedSoundRaw = sound.rawValue
        //Telemetry.shared.logOnboardChoice(flowId: "user_onboard_v_4_info", choiceInfo: selectedSoundRaw, choiceName: "sound")
        action()
    }
    
    @AppStorage("selectedSound") private var selectedSoundRaw: String = ""
    @State private var tempSelected: ChooseMuffledSound? = nil
    @State private var showAlert = false
    
    
    var body: some View {
        
        
        
        
        OnboardScaffoldNew(ctaTitle: "Continue", ctaAction: handleCTA, fixedWidth: 260) {
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
                            Text("How muffled is the sound?").font(.system(size: 30, weight: .semibold))
                        )
                        .foregroundStyle(Color(red: 17/255, green: 17/255, blue: 17/255))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                        .padding(.top, 16)
                        .padding(.bottom, 24)
                        
                    }
                    
                    
                    ForEach(ChooseMuffledSound.allCases) { sound in
                        SelectableChipTwo(title: sound.rawValue,
                                          subtitle: sound.subtitle,
                                          isSelected: Binding(
                                            get: { tempSelected == sound },
                                            set: { if $0 { tempSelected = sound } }
                                          )
                                          
                        )
                    }
                    
                    Spacer()
                    
                    
                }
                .padding(.horizontal, 32)
            }
        }
        .alert("Please make a choice", isPresented: $showAlert) {
            Button("OK", role: .cancel) {}
        }
        
        
    }
}

struct SelectableChipTwo: View {
    let title: String
    let subtitle: String
    @Binding var isSelected: Bool
    
    var body: some View {
        Button {
            isSelected.toggle()
        } label: {
            HStack(spacing: 12) {
                Image(isSelected ? "fillCheckmark" : "emptyCheckmark")
                
//                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
//                    .imageScale(.large)
//                    .font(.system(size: 18, weight: .semibold))
//                    .foregroundStyle(isSelected ? Color(red: 81 / 255, green: 132 / 255, blue: 234 / 255) : Color(red: 195 / 255, green: 198 / 255, blue: 205 / 255))
                
                VStack(alignment: .leading) {
                    
                    Text(LocalizedStringKey(title))
                        .font(.system(size: 15, weight: .medium))
                        .foregroundStyle(Color(red: 17 / 255, green: 17 / 255, blue: 17 / 255))
                    
                    
                    Text(LocalizedStringKey(subtitle))
                        .font(.system(size: 14, weight: .regular))
                        .foregroundStyle(Color(red: 59 / 255, green: 65 / 255, blue: 72 / 255))
                    
                }
                
                
                Spacer(minLength: 0)
            }
            .padding(.vertical, 19)
            .padding(.horizontal, 14)
            .contentShape(RoundedRectangle(cornerRadius: 16))
        }
        .buttonStyle(.plain)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.white))
                .innerShadow(
                    RoundedRectangle(cornerRadius: 16),
                    color: Color(red: 17 / 255, green: 17 / 255, blue: 17 / 255), opacity: 0.05,
                    x: 0, y: -1, blur: 0, spread: 2
                )
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
    OnboardFourthThirdView(action: {print("O")})
}
