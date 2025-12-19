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
        guard let choice = tempSelected else {
            showAlert = true
            return
        }
        selectedDeviceRaw = choice.rawValue
        //Telemetry.shared.logOnboardChoice(flowId: "user_onboard_v_4_info", choiceInfo: selectedDeviceRaw, choiceName: "device")
        action()
    }
    
    @AppStorage("selectedDevice") private var selectedDeviceRaw: String = ""
    @State private var tempSelected: ChooseDevice? = nil
    @State private var showAlert = false
    
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
                        SelectableChipOne(title: device.rawValue,
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
        }
        .alert("Please choose a device", isPresented: $showAlert) {
            Button("OK", role: .cancel) {}
        }
        //        .onAppear {
        //            tempSelected = ChooseDevice(rawValue: selectedDeviceRaw) ?? .iphone
        //        }
        
        
    }
}

struct PillButtonNew: View {
    let title: String
    let action: () -> Void
    var arrow: Bool = false
    
    
    var body: some View {
        Button(action: {
            let generator = UIImpactFeedbackGenerator(style: .medium)
            
            generator.prepare()
            generator.impactOccurred()
            
            action()
        }) {
            Text(title)
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(.white)
                .frame(minHeight: 52)
                .frame(maxWidth: .infinity)
            //.contentShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            
        }
        //.buttonStyle(.plain)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color(red: 81 / 255, green: 132 / 255, blue: 234 / 255)) // як на скріні
                .innerShadow(
                    RoundedRectangle(cornerRadius: 16),
                    color: .white, opacity: 0.25,
                    x: 0, y: 1, blur: 0, spread: 2
                )
        )
        .overlay( // стрілка зверху, не зсуває текст
            Group {
                if arrow {
                    Image(systemName: "arrow.right")
                        .foregroundStyle(.white)
                    
                        .padding(.trailing, 16)
                }
            },
            alignment: .trailing
        )
        //        .overlay(
        //            RoundedRectangle(cornerRadius: 16, style: .continuous)
        //                .stroke(Color.white.opacity(0.08), lineWidth: 1) // тонка обводка (опційно)
        //        )
        
    }
}

struct SelectableChipOne: View {
    let title: String
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
                .fill(.white)
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


extension View {
    /// Figma-like inner shadow (overlay + mask)
    func innerShadow<S: Shape>(
        _ shape: S,
        color: Color = .black,
        opacity: Double = 1,
        x: CGFloat = 0,
        y: CGFloat = 0,
        blur: CGFloat = 6,
        spread: CGFloat = 0
    ) -> some View {
        overlay(
            shape
                .stroke(color.opacity(opacity), lineWidth: max(spread, 0.0001))
                .offset(x: x, y: y)
                .blur(radius: blur)
                .mask(shape)
        )
    }
}
#Preview {
    OnboardFourthFirstView(action: {print("N")})
}
