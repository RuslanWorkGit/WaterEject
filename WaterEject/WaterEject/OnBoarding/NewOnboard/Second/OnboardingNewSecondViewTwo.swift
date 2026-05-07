//
//  OnboardingNewSecondViewTwo.swift
//  WaterEject
//
//  Created by Ruslan Liulka on 07.05.2026.
//


import SwiftUI

struct OnboardingNewSecondViewTwo: View {
    let index: Int
    let action: () -> Void
    
    
    private func handleCTA() {
        
        action()
    }
    
    
    var body: some View {
        
        

//        OnboardNewFirstForm(ctaTitle:String(localized: "Continue"), ctaAction: handleCTA, pages: 2, pageIndex: index, fixedWidth: 260) {
        OnboardThirdForm(ctaTitle:String(localized: "Continue"), ctaAction: handleCTA, pages: 3, pageIndex: index, fixedWidth: 260) {
            Color(red: 0 / 255, green: 0 / 255, blue: 0 / 255)
                .ignoresSafeArea()
            
//            Image("FirstOnboardBGTwo")
//                .resizable()
//                .scaledToFit()
//                .ignoresSafeArea()
            
            NewOnboardLottieView()
                .scaleEffect(2)
                   .allowsHitTesting(false)
            
            VStack(spacing: 10) {
                Spacer()
                
                ZStack(alignment: .bottom) {
                   
                   
                    
                    
                }
                
                
                Text("Calibrating Sonic Frequency...")
                    .font(.custom("Montserrat-SemiBold", size: 28))
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 25)
                    .padding(.bottom, 16)
                
                Text("Generating low-frequency air pressure to push liquid out.")
                    .font(.custom("Montserrat-SemiBold", size: 16))
                    .foregroundStyle(.white.opacity(0.6))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
                
                
            }
            
        }
        
//        .background(
//            ZStack(alignment: .top) {
//                Color(red: 29 / 255, green: 29 / 255, blue: 29 / 255)
//                    .ignoresSafeArea()
//
//                Image("FirstOnboardBGOne")
//                    .resizable()
//                    .scaledToFit()
//
//                    //.scaleEffect(1.05)
//            }
//                .ignoresSafeArea()
//        )
        
    }
}

import Lottie

final class NewOnboardAnimationCache {
    static let shared = NewOnboardAnimationCache()

    let animationView: LottieAnimationView

    private init() {
        let fileURL = Bundle.main.url(
            forResource: "newLinesOnboardAnim",
            withExtension: "lottie",
            subdirectory: "Lottie"
        ) ?? Bundle.main.url(
            forResource: "newLinesOnboardAnim",
            withExtension: "lottie"
        )

        let view: LottieAnimationView

        if let fileURL {
            view = LottieAnimationView(dotLottieFilePath: fileURL.path) { animationView, error in
                guard error == nil else { return }
                animationView.loopMode = .loop
                animationView.play()
            }
        } else {
            view = LottieAnimationView(name: "newLinesOnboardAnim")
        }

        view.contentMode = .scaleAspectFit
        view.loopMode = .loop
        view.backgroundBehavior = .pauseAndRestore
        view.play()
        self.animationView = view
    }
}


struct NewOnboardLottieView: UIViewRepresentable {
    func makeUIView(context: Context) -> UIView {
        let container = UIView(frame: .zero)
        let animationView = NewOnboardAnimationCache.shared.animationView

        // Щоб при повторному створенні контейнера не було дублю субв’ю
        if animationView.superview !== container {
            animationView.removeFromSuperview()
            animationView.translatesAutoresizingMaskIntoConstraints = false
            container.addSubview(animationView)

            NSLayoutConstraint.activate([
                animationView.leadingAnchor.constraint(equalTo: container.leadingAnchor),
                animationView.trailingAnchor.constraint(equalTo: container.trailingAnchor),
                animationView.topAnchor.constraint(equalTo: container.topAnchor),
                animationView.bottomAnchor.constraint(equalTo: container.bottomAnchor)
            ])
        }

        return container
    }

    func updateUIView(_ uiView: UIView, context: Context) {
        NewOnboardAnimationCache.shared.animationView.play()
    }
}



#Preview {
    OnboardingNewSecondViewTwo(index: 1) {
        print("1")
    }
}
