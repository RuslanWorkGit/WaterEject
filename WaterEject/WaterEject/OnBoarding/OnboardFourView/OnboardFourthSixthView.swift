//
//  OnboardFourthSixthView.swift
//  WaterEject
//
//  Created by Ruslan Liulka on 06.11.2025.
//

import SwiftUI

struct OnboardFourthSixthView: View {
    let action: () -> Void
    private func handleCTA() {
        selectedDeviceRaw = tempSelected.rawValue
        action()
    }
    
    @AppStorage("selectedDevice") private var selectedDeviceRaw: String = ChooseDevice.iphone.rawValue
    @State private var tempSelected: ChooseDevice = .iphone
    

    var body: some View {


            
            
        OnboardScaffoldSix(ctaTitle: "Start Cleaning", ctaAction: handleCTA, fixedWidth: 260) {

            LinearGradient(gradient: Gradient(stops: [
                .init(color: Color(red: 255/255, green: 255/255, blue: 255/255).opacity(1), location: 0),
                .init(color: Color(red: 222/255, green: 255/255, blue: 240/255).opacity(1), location: 0.5),
                .init(color: Color(red: 255/255, green: 255/255, blue: 255/255).opacity(1), location: 1.0)
            ]), startPoint: .top, endPoint: .bottom)
            .ignoresSafeArea()
                VStack {
                    
                    Image("OnboardAccept")
                    Group {
                        
                        (
                            Text("Calibration complete!").font(.system(size: 48, weight: .bold))

                        )
                        .foregroundStyle(Color(red: 17/255, green: 17/255, blue: 17/255))
                        .multilineTextAlignment(.center)
                        //.padding(.horizontal, 40)
                        .padding(.top, 32)
                        .padding(.bottom, 12)
                        
                        Group {
                            (
                            Text("Your device is ready \n") +
                            Text("for safe cleaning.")
                            )
                            .multilineTextAlignment(.center)
                                .font(.system(size: 16))
                                .foregroundStyle(Color(red: 59/255, green: 65/255, blue: 72/255))
                                
                        }
                        
                    }
                    
                    

                    
                    
                }
                .padding(.horizontal, 60)
            
        }
        .onAppear {
            tempSelected = ChooseDevice(rawValue: selectedDeviceRaw) ?? .iphone
        }

        
    }

}

struct PillButtonSix: View {
    let title: String
    let action: () -> Void
    var arrow: Bool = false
    
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(Color(red: 17 / 255, green: 17 / 255, blue: 17 / 255))
                .frame(minHeight: 52)
                .frame(maxWidth: .infinity)
                //.contentShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            
        }
        //.buttonStyle(.plain)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color(red: 43 / 255, green: 217 / 255, blue: 156 / 255)) // як на скріні
                .innerShadow(
                    RoundedRectangle(cornerRadius: 16),
                    color: .white, opacity: 0.25,
                    x: 0, y: 1, blur: 0, spread: 2
                )
        )
        .overlay(
            Group {
                if arrow {
                    Image(systemName: "arrow.right")
                        .foregroundStyle(Color(red: 17 / 255, green: 17 / 255, blue: 17 / 255))

                        .padding(.trailing, 16)
                }
            },
            alignment: .trailing
        )

        
    }
}

//struct PillButtonNewi: View {
//    let title: String
//    let action: () -> Void
//    var arrow: Bool = false
//    
//    
//    var body: some View {
//        Button(action: action) {
//            Text(title)
//                .font(.system(size: 18, weight: .semibold))
//                .foregroundStyle(.white)
//                .frame(minHeight: 52)
//                .frame(maxWidth: .infinity)
//            //.contentShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
//            
//        }
//        //.buttonStyle(.plain)
//        .background(
//            RoundedRectangle(cornerRadius: 16, style: .continuous)
//                .fill(Color(red: 81 / 255, green: 132 / 255, blue: 234 / 255)) // як на скріні
//                .innerShadow(
//                    RoundedRectangle(cornerRadius: 16),
//                    color: .white, opacity: 0.25,
//                    x: 0, y: 1, blur: 0, spread: 2
//                )
//        )
//        .overlay( // стрілка зверху, не зсуває текст
//            Group {
//                if arrow {
//                    Image(systemName: "arrow.right")
//                        .foregroundStyle(.white)
//                    
//                        .padding(.trailing, 16)
//                }
//            },
//            alignment: .trailing
//        )
//        
//    }
//}


struct OnboardScaffoldSix<Content: View>: View {
    let ctaTitle: String
    let ctaAction: () -> Void
    var fixedWidth: CGFloat = 260
    @ViewBuilder let content: () -> Content
    
    var body: some View {
        ZStack(alignment: .center) { content() }
            .safeAreaInset(edge: .bottom) {
                HStack { // гарантує однакову геометрію
                    Spacer()
                    PillButtonSix(title: ctaTitle, action: ctaAction, arrow: true)
                        .padding(.horizontal, 32)
                        .frame(minHeight: 52) // ключ
//                        .frame(width: fixedWidth)
                    Spacer()
                }
                
                .padding(.bottom, 30)
                
            }
    }
}

#Preview {
    OnboardFourthSixthView(action: {print("N")})
}
