//
//  SevenDaysModesView.swift
//  WaterEject
//
//  Created by Ruslan Liulka on 23.12.2025.
//

import SwiftUI

struct SevenDaysModesView: View {
    @EnvironmentObject private var paywallGate: PaywallGate
    @Environment(\.dismiss) private var dismiss
    @State private var showSpecialOffer = false
    @State private var pendingMode: CleaningMode?

    let onStart: (CleaningMode) -> Void

    var body: some View {
        let isSmall = UIScreen.main.bounds.height < 700
        let isMini = UIScreen.main.bounds.height < 850
        let isLarge = UIScreen.main.bounds.height > 900
        let headerHeight: CGFloat = 200

        ZStack(alignment: .top) {
            
            BackgroundNew()

            ScrollView {
                
                VStack(spacing: 12) {
                    SevenDaysHeaderView(
                        headerHeight: headerHeight,
                        title: "7-day cleaning Plan",
                        subtitle: "Perform a complete cleaning by daily cleaning",
                        onBack: { dismiss() }
                    )
                }
                
                
                
                VStack(spacing: 12) {
                    
                    
                    NewCleaningModeCard(
                        icon: "Drop",
                        mode: .sonicPulse,
                        deviceIcon: "SmallDynamic",
                        deviceName: "Speaker",
                        deviceColor: Color(red: 56/255, green: 255/255, blue: 185/255),
                        freq: "175HZ Vibro",
                        time: "25 seconds",
                        isSmall: isSmall,
                        onModeAction: { mode in startIfAllowed(mode) }
                    )
                    
                    NewCleaningModeCard(
                        icon: "Dynamic",
                        mode: .nanoShake,
                        deviceIcon: "SmallDynamic",
                        deviceName: "Speaker",
                        deviceColor: Color(red: 56/255, green: 255/255, blue: 185/255),
                        freq: "175HZ Vibro",
                        time: "25 seconds",
                        isSmall: isSmall,
                        onModeAction: { mode in startIfAllowed(mode) }
                    )
                    
                    NewCleaningModeCard(
                        icon: "Drop",
                        mode: .dynamicEject,
                        deviceIcon: "SmallDrop",
                        deviceName: "Water",
                        deviceColor: Color(red: 161/255, green: 225/255, blue: 255/255),
                        freq: "175HZ Vibro",
                        time: "25 seconds",
                        isSmall: isSmall,
                        onModeAction: { mode in startIfAllowed(mode) }
                    )
                    
                    NewCleaningModeCard(
                        icon: "Drop",
                        mode: .hydroGuard,
                        deviceIcon: "SmallWave",
                        deviceName: "Speaker",
                        deviceColor: Color(red: 161/255, green: 225/255, blue: 255/255),
                        freq: "175HZ Vibro",
                        time: "25 seconds",
                        isSmall: isSmall,
                        onModeAction: { mode in startIfAllowed(mode) }
                    )
                }
                .padding(.horizontal, isSmall ? 48 : isMini ? 40 : isLarge ? 16 : 32)
                //.padding(.top, 32)
                .padding(.top, 12)
            }
                }
        .ignoresSafeArea()
//                .contentMargins(.horizontal, isSmall ? 48 : isMini ? 40 : isLarge ? 16 : 32)
                .scrollIndicators(.never)
            

        
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .navigationBar)
        .background(NavigationControllerCoordinator())
//        .toolbar {
//            ToolbarItem(placement: .principal) {
//                VStack {
//                    Text("7-day cleaning Plan")
//                        .font(.system(size: 24, weight: .bold))
//                        .foregroundColor(.white)
//                    
//                    Text("7-day cleaning Plan")
//                        .font(.system(size: 12, weight: .regular))
//                        .foregroundColor(.white)
//                }
//               
//            }
//            
//
//            ToolbarItem(placement: .topBarLeading) {
//                Button { dismiss() } label: {
//                    Image(systemName: "chevron.backward")
//                        .foregroundStyle(Color(red: 161/255, green: 192/255, blue: 255/255))
//                        .font(.system(size: 23))
//                }
//            }
//        }
        .tint(Color(red: 161/255, green: 192/255, blue: 255/255))
        .fullScreenCover(isPresented: $showSpecialOffer) {
            SpecialOfferView(
                onFinish: { showSpecialOffer = false },
                placeWhereBuy: "SevenDaysModesView"
            )
            .environmentObject(paywallGate)
        }
    }

    private func startIfAllowed(_ mode: CleaningMode) {
        Task {
            pendingMode = mode
            if await paywallGate.isPro() {
                onStart(mode)
            } else {
                paywallGate.currentContext = .modesTap
                showSpecialOffer = true
            }
        }
    }
}


struct CurvedHeaderShape: Shape {
    var curveHeight: CGFloat = 40     // наскільки "глибокий" вигин
    var curveLift: CGFloat = 0         // якщо треба підняти/опустити вигин

    func path(in rect: CGRect) -> Path {
        var p = Path()

        p.move(to: .init(x: rect.minX, y: rect.minY))
        p.addLine(to: .init(x: rect.maxX, y: rect.minY))
        p.addLine(to: .init(x: rect.maxX, y: rect.maxY - curveHeight + curveLift))

        // крива вниз (контрольна точка нижче, щоб був "пузир")
        p.addQuadCurve(
            to: .init(x: rect.minX, y: rect.maxY - curveHeight + curveLift),
            control: .init(x: rect.midX, y: rect.maxY + curveHeight + curveLift)
        )

        p.closeSubpath()
        return p
    }
}



//struct SevenDaysHeaderView: View {
//    let title: String
//    let subtitle: String
//    let onBack: () -> Void
//
//    var body: some View {
//        GeometryReader { geo in
//            let top = geo.safeAreaInsets.top
//            let headerHeight: CGFloat = 200
//
//            ZStack(alignment: .top) {
//                CurvedHeaderShape(curveHeight: 40)
//                    .fill(Color(red: 28/255, green: 74/255, blue: 115/255))
//                    .frame(height: headerHeight)
//                    .ignoresSafeArea(edges: .top)
//
//                // Back + title/subtitle
//                VStack(spacing: 10) {
//
//                    Text(title)
//                        .font(.system(size: 34, weight: .bold))
//                        .foregroundStyle(.white)
//                        .multilineTextAlignment(.center)
//
//                    Text(subtitle)
//                        .font(.system(size: 16, weight: .regular))
//                        .foregroundStyle(Color.white.opacity(0.85))
//                        .multilineTextAlignment(.center)
//                        .padding(.horizontal, 24)
//                }
//                //.padding(.top,46) // відступ під статусбар + "навігаційну" зону
//            }
//            .frame(height: headerHeight)
//        }
//        .frame(height: 200) // має збігатися з headerHeight
//    }
//}

struct SevenDaysHeaderView: View {
    let headerHeight: CGFloat
    let title: String
    let subtitle: String
    let onBack: () -> Void

    var body: some View {
        GeometryReader { geo in
            let top = geo.safeAreaInsets.top

            ZStack(alignment: .leading) {
                CurvedHeaderShape(curveHeight: 30)
                    .fill(Color(red: 28/255, green: 74/255, blue: 115/255))
                    .frame(height: headerHeight)
                

                VStack(spacing: 10) {
                    Spacer().frame(height: top + 22)

                    Text(title)
                        .font(.system(size: 24, weight: .bold))
                        .foregroundStyle(.white)
                        .multilineTextAlignment(.center)

                    Text(subtitle)
                        .font(.system(size: 14))
                        .foregroundStyle(Color.white.opacity(0.85))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 24)
                }
                .frame(maxWidth: .infinity)

                Button(action: onBack) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 24, weight: .semibold))
                        .foregroundStyle(.white)
                        .frame(width: 44, height: 44)

                }
                //.padding(.top, top + 10)
                .padding(.leading, 16)
            }
        }
        .frame(height: headerHeight)
        .ignoresSafeArea(edges: .top) // щоб синій зайшов під статусбар
    }
}



#Preview {
    SevenDaysModesView { new in
        
    }
}
