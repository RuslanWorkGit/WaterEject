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
    @State private var pendingMode: NewCleaningMode?
    
    @AppStorage(SevenDayPlanProgress.daysKey)
    private var completedDays: Int = 0
    @State private var now = Date()
    
    private var unlockedMaxDay: Int {
        if SevenDayPlanProgress.canStartNextDay(now: now) {
            return min(completedDays + 1, 7)   // можна почати “наступний” день
        } else {
            return min(completedDays, 7)       // сьогодні вже пройшли — чекаємо до наступної доби
        }
    }
    
    private func isLocked(day: Int) -> Bool {
        day > unlockedMaxDay
        // якщо хочеш “доступний лише поточний день”, зроби так:
        // day != unlockedMaxDay
    }
    
    let onStart: (NewCleaningMode) -> Void
    
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
                
                
                
                VStack(alignment: .leading ,spacing: 4) {
                    ForEach(1...7, id: \.self) { day in
                        
                        HStack {
                            
//                            Circle()
//                                .fill(.red)
//                                .frame(width: 24, height: 24)
                            
                            Circle()
                                    .fill(day <= completedDays ? Color(red: 2/255, green: 125/255, blue: 244/255) : Color(red: 49 / 255, green: 66 / 255, blue: 80 / 255))
                                    .stroke(
                                        day == completedDays + 1 ? Color(red: 2 / 255, green: 125 / 255, blue: 244 / 255) : .clear,
                                        style: StrokeStyle(lineWidth: 1, lineCap: .round, lineJoin: .round)
                                    )
                                    .frame(width: 24, height: 24)
                                    .anchorPreference(key: TimelineCentersKey.self, value: .center) { [day: $0] }
                                    .frame(width: 28, alignment: .center) // колонка під Circle (щоб було рівно)


                            
                            NewCleaningModeCard(
                                icon: "NewWaterDrop",
                                mode: .waterRemoval,
                                deviceIcon: "SmallDynamic",
                                firstHesh: "#Clean",
                                deviceColor: Color(red: 56/255, green: 255/255, blue: 185/255),
                                secondHesh: "#LowFrequance",
                                time: "60 seconds",
                                isSmall: isSmall,
                                isLocked: isLocked(day: day),
                                lockAssetName: "Lock"
                            ) { mode in
                                startIfAllowed(mode)
                            }

                        }
                        
                        
                    }
                                        
                    
                }
                .backgroundPreferenceValue(TimelineCentersKey.self) { anchors in
                    GeometryReader { proxy in
                        let points: [CGPoint] = (1...7).compactMap { day in
                            anchors[day].map { proxy[$0] }
                        }

                        Path { path in
                            guard let first = points.first else { return }
                            path.move(to: first)
                            for p in points.dropFirst() {
                                path.addLine(to: p)
                            }
                        }
                        .stroke(
                            Color(red: 49 / 255, green: 66 / 255, blue: 80 / 255),
                            style: StrokeStyle(lineWidth: 2, lineCap: .round, lineJoin: .round)
                        )
                    }
                }
                .padding(.horizontal, isSmall ? 24 : isMini ? 20 : isLarge ? 16 : 24)
                //.padding(.top, 32)
                .padding(.top, 12)
            }
            .scrollIndicators(.never)
        }
        .onReceive(Timer.publish(every: 30, on: .main, in: .common).autoconnect()) { now = $0 }

        .ignoresSafeArea()
        //                .contentMargins(.horizontal, isSmall ? 48 : isMini ? 40 : isLarge ? 16 : 32)
        
        
        
        
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .navigationBar)
        .background(NavigationControllerCoordinator())
        
        .fullScreenCover(isPresented: $showSpecialOffer) {
            SpecialOfferView(
                onFinish: { showSpecialOffer = false },
                placeWhereBuy: "SevenDaysModesView"
            )
            .environmentObject(paywallGate)
        }
    }
    
    private func startIfAllowed(_ mode: NewCleaningMode) {
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

private struct TimelineCentersKey: PreferenceKey {
    static var defaultValue: [Int: Anchor<CGPoint>] = [:]

    static func reduce(value: inout [Int: Anchor<CGPoint>], nextValue: () -> [Int: Anchor<CGPoint>]) {
        value.merge(nextValue(), uniquingKeysWith: { $1 })
    }
}



#Preview {
    SevenDaysModesView { new in
        
    }
}
