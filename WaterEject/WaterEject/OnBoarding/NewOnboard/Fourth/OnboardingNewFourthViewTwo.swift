//
//  OnboardingNewFourthViewTwo.swift
//  WaterEject
//
//  Created by Ruslan Liulka on 07.05.2026.
//

import SwiftUI

struct OnboardingNewFourthViewTwo: View {
    let index: Int
    let action: () -> Void
    
    
    private func handleCTA() {
        
        action()
    }
    
    
    var body: some View {
        
        

//        OnboardNewFirstForm(ctaTitle:String(localized: "Continue"), ctaAction: handleCTA, pages: 2, pageIndex: index, fixedWidth: 260) {
        OnboardFourthForm(ctaTitle:String(localized: "Continue"), ctaAction: handleCTA, pages: 3, pageIndex: index, fixedWidth: 260) {
//            Color(red: 255 / 255, green: 255 / 255, blue: 255 / 255)
//                .ignoresSafeArea()
            
//            Image("FifthOnboardBGOne")
//                .resizable()
//                .scaledToFit()
//                .ignoresSafeArea()
            
            NewOnboardWhiteLottieView()
                .scaleEffect(2)
                   .allowsHitTesting(false)

            
            VStack(spacing: 10) {
                Spacer()
                
                ZStack(alignment: .bottom) {
                   
                   
                    
                    
                }
                
                
                Text("Calibrating Sonic Frequency...")
                    .font(.custom("Montserrat-SemiBold", size: 26))
                    .foregroundStyle(.black)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 16)

                
                Text("Generating low-frequency air pressure to push liquid out.")
                    .font(.custom("Montserrat-SemiBold", size: 16))
                    .foregroundStyle(.black.opacity(0.6))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 30)
                
                
            }
            
        }
        
        .background(
            ZStack(alignment: .bottom) {
                Color(red: 22 / 255, green: 125 / 255, blue: 244 / 255)
                    .ignoresSafeArea()

                Image("FourhtOnboardBGTwo")
                    .resizable()
                    .scaledToFit()
                    .ignoresSafeArea()

                    //.scaleEffect(1.05)
            }
                .ignoresSafeArea()
        )
        
    }
}

import Lottie

final class NewOnboardWhiteAnimationCache {
    static let shared = NewOnboardWhiteAnimationCache()

    let animationView: LottieAnimationView

    private init() {
        let fileURL = Bundle.main.url(
            forResource: "newLinesOnboardAnimWhite",
            withExtension: "lottie",
            subdirectory: "Lottie"
        ) ?? Bundle.main.url(
            forResource: "newLinesOnboardAnimWhite",
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


struct NewOnboardWhiteLottieView: UIViewRepresentable {
    func makeUIView(context: Context) -> UIView {
        let container = UIView(frame: .zero)
        let animationView = NewOnboardWhiteAnimationCache.shared.animationView

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
    OnboardingNewFourthViewTwo(index: 1) {
        print("1")
    }
}
