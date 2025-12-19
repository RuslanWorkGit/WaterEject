//
//  ThirdWaveView.swift
//  WaterEject
//
//  Created by Ruslan Liulka on 08.12.2025.
//

import SwiftUI
import Lottie

struct ThirdWaveView: View {
    let action: () -> Void
    let textButton: String
    private func handleCTA() {
        
        action()
    }
    
    var body: some View {
        
        OnboardNewStyle(ctaTitle: textButton, ctaAction: handleCTA, fixedWidth: 260) {
            
            Color(red: 215 / 255, green: 222 / 255, blue: 231 / 255).ignoresSafeArea()
            
            VStack() {
                VStack(alignment: .center) {
                    Text("Hear Every Tone")
                        .font(.custom("Montserrat-SemiBold", size: 36))
                        .foregroundStyle(Color(red: 45 / 255, green: 127 / 255, blue: 249 / 255))
                        .multilineTextAlignment(.center)
                        .padding(.top, 64)
                    
                    Text("Clearly")
                        .font(.custom("Montserrat-ExtraBold", size: 44))
                        .foregroundStyle(Color(red: 45 / 255, green: 127 / 255, blue: 249 / 255))
                        .multilineTextAlignment(.center)

        
                    

                }
                
            
                //Lottie
                
                ThirdWaveLottieView()
                                        .allowsHitTesting(false)
                                        .padding(.horizontal, -10)
          // ← головний контролер розміру
//                .frame(maxWidth: .infinity)   // по ширині як екран
//                .padding(.horizontal, -10)
//                .padding(.top, 24)

                
                Spacer()
                
                (
                    Text("Scan the full range from ")
                        .foregroundStyle(.black.opacity(0.7))
                        .font(.custom("Montserrat-Medium", size: 20))
                    +
                    Text("10 ")
                        .foregroundStyle(.black.opacity(0.7))
                        .font(.custom("Montserrat-Bold", size: 20))
                    +
                    Text("to ")
                        .foregroundStyle(.black.opacity(0.7))
                        .font(.custom("Montserrat-Medium", size: 20))
                    +
                    Text("20,000 Hz ")
                        .foregroundStyle(.black.opacity(0.7))
                        .font(.custom("Montserrat-Bold", size: 20))
                    +
                    Text("to spot sound issues instantly.")
                        .foregroundStyle(.black.opacity(0.7))
                        .font(.custom("Montserrat-Medium", size: 20))
                )
                .multilineTextAlignment(.center)
                .padding(.horizontal, 34)
                .padding(.top, 42)
                .padding(.bottom, 22)
                
                
            }
            
        }
        
    }
}

final class ThirdWaveAnimationCache {
    static let shared = ThirdWaveAnimationCache()
    
    let animationView: LottieAnimationView
    
    private init() {
        let view = LottieAnimationView(name: "NewWaveLine") // твій json
        view.contentMode = .scaleAspectFit
        view.loopMode = .loop
        view.animationSpeed = 0.8
        view.play()
        self.animationView = view
    }
}

struct ThirdWaveLottieView: UIViewRepresentable {
    func makeUIView(context: Context) -> UIView {
        let container = UIView(frame: .zero)
        let animationView = ThirdWaveAnimationCache.shared.animationView
        
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
        // нічого не треба — анімація вже крутиться в loop
    }
}




#Preview {
    ThirdWaveView(action: { print("N")}, textButton: "Continue")
}
