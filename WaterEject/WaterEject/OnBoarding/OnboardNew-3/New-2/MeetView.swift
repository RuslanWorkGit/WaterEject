//
//  MeetView.swift
//  WaterEject
//
//  Created by Ruslan Liulka on 21.11.2025.
//

import SwiftUI

struct MeetView: View {
    let index: Int
    let action: () -> Void
    private func handleCTA() {
        
        action()
    }
    
    @State private var group13Trigger: Int = 0
    @State private var group24Trigger: Int = 0

    // загальний час одного повного циклу для групи (секунди)
    private let cardCycleDuration: Double = 2.5
    
    var body: some View {
        
        let isSmall = UIScreen.main.bounds.height < 700
        let isLarge = UIScreen.main.bounds.height > 900
        
        OnboardWaterDrops(ctaTitle: "Start Cleaning", ctaAction: handleCTA, pages: 4, pageIndex: index, fixedWidth: 260) {
            
            Color(red: 225 / 255, green: 233 / 255, blue: 239 / 255).ignoresSafeArea()
            
            VStack() {
                VStack(alignment: .center) {
                    Text("Meet the Cleaning Modes")
                        .font(.system(size: 26, weight: .bold))
                        .foregroundStyle(.black)
                        .multilineTextAlignment(.center)
                        .padding(.top, 64)
                    //.padding(.bottom, 12)
                    
                    
                    
                    Text("Each one is tuned for a specific purpose — from deep water ejection to frequency modulation.")
                        .font(.system(size: 12, weight: .semibold))
                        .multilineTextAlignment(.center)
                        .foregroundStyle(Color(red: 59/255, green: 65/255, blue: 72/255))
                        .padding(.horizontal, 20)
                        .padding(.bottom, 80)
                    
                }
                
                
                
                ZStack{
                    Image("PhoneOnboard")
                        .resizable()
                        .scaledToFit()
                        .scaleEffect(0.8)
                        .zIndex(2)
                    
                    // ГРУПА 1: First + Third
//                                       FloatingCardView(
//                                           imageName: "FirstCard",
//                                           baseOffset: CGSize(width: isLarge ? -130 : -110, height: isLarge ? -200 : -180),
//                                           floatAmplitude: 6,
//                                           rotationAmplitude: -3,
//                                           cycleDuration: cardCycleDuration,
//                                           trigger: group13Trigger
//                                       )
//                                       .zIndex(1)
//
//                                       FloatingCardView(
//                                           imageName: "ThirdCard",
//                                           baseOffset: CGSize(width: isLarge ? -140 : -120, height: isLarge ? 50 : 30),
//                                           floatAmplitude: 6,
//                                           rotationAmplitude: -3,
//                                           cycleDuration: cardCycleDuration,
//                                           trigger: group13Trigger
//                                       )
//                                       .zIndex(1)
//
//                                       // ГРУПА 2: Second + Fourth
//                                       FloatingCardView(
//                                           imageName: "SecondCard",
//                                           baseOffset: CGSize(width: isLarge ? 160 : 140, height: isLarge ? -100 : -80),
//                                           floatAmplitude: 6,
//                                           rotationAmplitude: 3,
//                                           cycleDuration: cardCycleDuration,
//                                           trigger: group24Trigger
//                                       )
//                                       .zIndex(1)
//
//                                       FloatingCardView(
//                                           imageName: "FourthCard",
//                                           baseOffset: CGSize(width: isLarge ? 140 : 120, height: isLarge ? 130 : 120),
//                                           floatAmplitude: 6,
//                                           rotationAmplitude: 3,
//                                           cycleDuration: cardCycleDuration,
//                                           trigger: group24Trigger
//                                       )
//                                       .zIndex(3)
                    
                    FloatingCardView(
                            imageName: "FirstCard",
                            baseOffset: CGSize(width: isLarge ? -130 : -110,
                                               height: isLarge ? -200 : -180),
                            floatAmplitude: 6,
                            rotationAmplitude: -3,
                            animationDuration: 2.2,
                            initialDelay: 0.0
                        )
                        .zIndex(1)

                        FloatingCardView(
                            imageName: "SecondCard",
                            baseOffset: CGSize(width: isLarge ? 160 : 140,
                                               height: isLarge ? -100 : -80),
                            floatAmplitude: 7,
                            rotationAmplitude: 3,
                            animationDuration: 2.9,
                            initialDelay: 0.3
                        )
                        .zIndex(1)

                        FloatingCardView(
                            imageName: "ThirdCard",
                            baseOffset: CGSize(width: isLarge ? -140 : -120,
                                               height: isLarge ? 50 : 30),
                            floatAmplitude: 5,
                            rotationAmplitude: -2.5,
                            animationDuration: 2.6,
                            initialDelay: 0.15
                        )
                        .zIndex(1)

                        FloatingCardView(
                            imageName: "FourthCard",
                            baseOffset: CGSize(width: isLarge ? 140 : 120,
                                               height: isLarge ? 130 : 120),
                            floatAmplitude: 8,
                            rotationAmplitude: 3.5,
                            animationDuration: 2.4,
                            initialDelay: 0.45
                        )
                        .zIndex(3)
                                   }
                
                Spacer()
                
                
            }
            .task {
                try? await Task.sleep(nanoseconds: 0_500_000_000)
                
                await runGroupLoop()
            }
            
        }
        
    }
    
    private func runGroupLoop() async {
        while true {
            // 1) Анімуємо 1 & 3
            group13Trigger += 1
            try? await Task.sleep(nanoseconds: UInt64(cardCycleDuration * 1_000_000_000))

            // 2) Анімуємо 2 & 4
            group24Trigger += 1
            try? await Task.sleep(nanoseconds: UInt64(cardCycleDuration * 1_000_000_000))
        }
    }
}




//struct FloatingCardView: View {
//    let imageName: String
//    let baseOffset: CGSize      // базове розташування в ZStack
//    let floatAmplitude: CGFloat // наскільки вгору/вниз ходить
//    let rotationAmplitude: Double // макс. кут повороту (в градусах)
//    let cycleDuration: Double   // повний цикл: вниз+поворот → назад
//
//    /// Кожна зміна trigger запускає один повний цикл анімації
//    let trigger: Int
//
//    @State private var isForward = false
//
//    var body: some View {
//        Image(imageName)
//            // обертання навколо центру
//            .rotationEffect(
//                .degrees(isForward ? rotationAmplitude : -rotationAmplitude),
//                anchor: .center
//            )
//            // рух вгору / вниз
//            .offset(
//                x: baseOffset.width,
//                y: baseOffset.height + (isForward ? -floatAmplitude : floatAmplitude)
//            )
//            // реагуємо на зміну trigger
//            .onChange(of: trigger) { _ in
//                runOneCycle()
//            }
//    }
//
//    private func runOneCycle() {
//        // половина часу — вперед, половина — назад
//        let half = cycleDuration / 2
//
//        // фаза "вперед"
//        withAnimation(.easeInOut(duration: half)) {
//            isForward = true
//        }
//
//        // фаза "назад"
//        DispatchQueue.main.asyncAfter(deadline: .now() + half) {
//            withAnimation(.easeInOut(duration: half)) {
//                isForward = false
//            }
//        }
//    }
//}

struct FloatingCardView: View {
    let imageName: String
    let baseOffset: CGSize          // базове положення в ZStack
    let floatAmplitude: CGFloat     // наскільки вгору/вниз ходить
    let rotationAmplitude: Double   // макс. кут повороту
    let animationDuration: Double   // тривалість повного ходу «вниз-вгору»
    let initialDelay: Double        // стартова затримка, щоб не були в фазі

    @State private var isUp = false

    var body: some View {
        Image(imageName)
            .rotationEffect(
                .degrees(isUp ? rotationAmplitude : -rotationAmplitude),
                anchor: .center
            )
            .offset(
                x: baseOffset.width,
                y: baseOffset.height + (isUp ? -floatAmplitude : floatAmplitude)
            )
            .onAppear {
                // невеликий рандом, щоб ще більше розсинхронити
                let extraJitter = Double.random(in: 0...0.4)

                withAnimation(
                    .easeInOut(duration: animationDuration)
                        .delay(initialDelay + extraJitter)
                        .repeatForever(autoreverses: true)
                ) {
                    isUp = true
                }
            }
    }
}



#Preview {
    MeetView(index: 2 ,action: { print("N")})
}
