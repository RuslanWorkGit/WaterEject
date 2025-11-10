//
//  OnboardFourthFourhtView.swift
//  WaterEject
//
//  Created by Ruslan Liulka on 06.11.2025.
//

import SwiftUI

struct OnboardFourthFourhtView: View {
    let action: () -> Void
    private func handleCTA() {
        guard let time = tempSelected else {
            showAlert = true
            return
        }
        selectedTimeRaw = time.rawValue
        Telemetry.shared.logOnboardChoice(flowId: "user_onboard_v_4_info", choiceInfo: selectedTimeRaw, choiceName: "time")
        action()
    }
    
    @AppStorage("selectedTime") private var selectedTimeRaw: String = ""
    @State private var tempSelected: ChooseTime? = nil
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
            ScrollView {
                VStack {
                    Group {
                        
                        (
                            Text("How long ago did it happen?").font(.system(size: 30, weight: .semibold))
                        )
                        .foregroundStyle(Color(red: 17/255, green: 17/255, blue: 17/255))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                        .padding(.top, 16)
                        .padding(.bottom, 32)
                        
                        
                    }
                    
                    
                    ForEach(ChooseTime.allCases) { time in
                        SelectableChipOne(title: time.rawValue,
                                          isSelected: Binding(
                                            get: { tempSelected == time },
                                            set: { if $0 { tempSelected = time } }
                                          )
                                          
                        )
                    }
                    
                    Spacer()
                    
                    
                }
                .padding(.horizontal, 32)
            }
        }
        .alert("Please choose a time", isPresented: $showAlert) {
            Button("OK", role: .cancel) {}
        }
        
        
    }
    
}

#Preview {
    OnboardFourthFourhtView(action: {print("A")})
}
