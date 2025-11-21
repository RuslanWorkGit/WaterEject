//
//  OnboardAnimationView.swift
//  WaterEject
//
//  Created by Ruslan Liulka on 21.11.2025.
//

import SwiftUI

struct OnboardAnimationView: View {
    let someAction: () -> ()
    @State private var dropOffset: CGFloat = -300   // стартує високо
    @State private var moveOffsetX: CGFloat = 0
    @State private var textMove: CGFloat = 500
    @State private var size: CGFloat = 90
    @State private var circleWidth: CGFloat = 162
    @State private var circleOffset: CGFloat = 30
    @State private var circlePadding: CGFloat = 22
    @State private var colorOne = Color(red: 127/255, green: 180/255, blue: 231/255)
    @State private var colorTwo = Color(red: 51/255, green: 139/255, blue: 235/255)
    @State private var firstCircle: AnyShapeStyle = AnyShapeStyle(Color.white.opacity(0.6))
    @State private var secondCircle: AnyShapeStyle = AnyShapeStyle(Color.white.opacity(0.6))
    @State private var mainCircle: AnyShapeStyle = AnyShapeStyle(Color.white)
    @State private var showOnboarding = false
    @EnvironmentObject private var coordinator: AppCoordinator
    
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    colorOne,
                    colorTwo
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            WaterDrop(firstCircle: firstCircle, secondCircle: secondCircle, mainCircle: mainCircle, size: size, circleWidth: circleWidth, circleOffset: circleOffset, circlePadding: circlePadding)
                .offset(x: moveOffsetX ,y: dropOffset)
            
            Text("Water Eject")
                .font(.system(size: 26, weight: .bold))
                .foregroundStyle(.black)
                .offset(x: textMove)
        }
        .onAppear {
            // 1) Плавне "падіння" майже до кінця
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.45) {
                withAnimation(.easeOut(duration: 0.85)) {
                    dropOffset = 6        // трохи нижче фінальної точки
                }
            }
            
            

            // 2) Ледь помітний bounce до 0
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.85) {
                withAnimation(
                    .interpolatingSpring(
                        mass: 1.0,
                        stiffness: 120,
                        damping: 22,      // великий damping = майже без коливань
                        initialVelocity: 0
                    )
                ) {
                    dropOffset = 0
                }
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.65) {
                withAnimation(.easeOut(duration: 0.45)) {
                    size = 28
                    circleWidth = 62
                    circleOffset = 7
                    circlePadding = 12
                    
                    colorOne = .white
                    colorTwo = .white
                    
                    firstCircle = AnyShapeStyle(
                                LinearGradient(
                                    colors: [Color(red: 225 / 255, green: 233 / 255, blue: 239 / 255).opacity(0.4), Color(red: 190 / 255, green: 219 / 255, blue: 248 / 255)],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                ).opacity(0.5)
                    )
                    
                    secondCircle = AnyShapeStyle(
                                LinearGradient(
                                    colors: [Color(red: 225 / 255, green: 233 / 255, blue: 239 / 255).opacity(0.4), Color(red: 190 / 255, green: 219 / 255, blue: 248 / 255)],
                                    startPoint: .trailing,
                                    endPoint: .leading
                                ).opacity(0.5)
                            )
                    
                    mainCircle = AnyShapeStyle(
                                LinearGradient(
                                    colors: [Color(red: 225 / 255, green: 233 / 255, blue: 239 / 255).opacity(0.4), Color(red: 190 / 255, green: 219 / 255, blue: 248 / 255)],
                                    startPoint: .bottom,
                                    endPoint: .top,
                                    
                                ).opacity(0.8)
                            )
                }
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.6) {
                withAnimation(.easeInOut(duration: 0.4)) {
                    moveOffsetX = -80
                }
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.4) {
                withAnimation(
                    .interpolatingSpring(
                        mass: 1.0,
                        stiffness: 120,
                        damping: 18,      // великий damping = майже без коливань
                        initialVelocity: 0
                    )
                ) {
                    textMove = 40
                }
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 4.5) {
                showOnboarding = true
            }
        }
        .fullScreenCover(isPresented: $showOnboarding, onDismiss: {
            //tabBarState.isHidden = false           // повернемо таббар (якщо треба)
        }) {
            OnboardingFlowViewEight(someAction: {
                showOnboarding = false
                coordinator.showMainTabbar()
                someAction()
            })
                .environmentObject(coordinator)    // пробросимо координатор
        }
        
    }
}




struct WaterDrop<S: ShapeStyle>: View {
    let firstCircle: S
    let secondCircle: S
    let mainCircle: S
    let size: CGFloat
    let circleWidth: CGFloat
    let circleOffset: CGFloat
    let circlePadding: CGFloat
    
    var body: some View {
        ZStack {
            Circle()
                .fill(firstCircle)
                .frame(width: circleWidth)
                .offset(x: circleOffset)
            
            Image(systemName: "drop.fill")
                .font(.system(size: size))
    
                .foregroundStyle(LinearGradient(
                    colors: [Color(red: 127/255, green: 180/255, blue: 231/255),
                             Color(red: 51/255, green: 139/255, blue: 235/255)],
                    startPoint: .top, endPoint: .bottom
                    

                ))
                .padding(circlePadding)
                .background(
                    Circle()

                        .fill(mainCircle)
                )
                .zIndex(1)
            
            Circle()
                .fill(secondCircle)
                .frame(width: circleWidth)
                .offset(x: -circleOffset)
        }
    }
}

#Preview {
    OnboardAnimationView(someAction: {print("m")})
}
