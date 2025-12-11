//
//  BlueLinesView.swift
//  WaterEject
//
//  Created by Ruslan Liulka on 21.11.2025.
//

import SwiftUI
import Lottie

struct BlueLinesView: View {
    let index: Int
    let action: () -> Void
    private func handleCTA() {
        
        action()
    }
    
    var body: some View {
        
        OnboardWaterDrops(ctaTitle: "Start Cleaning", ctaAction: handleCTA, pages: 4, pageIndex: index, fixedWidth: 260) {
            
            Color(red: 225 / 255, green: 233 / 255, blue: 239 / 255).ignoresSafeArea()
            
            VStack() {
                VStack(alignment: .center) {
                    Text("Discover the Power").font(.system(size: 26, weight: .bold))
                        .foregroundStyle(.black)
                        .multilineTextAlignment(.center)
                        .padding(.top, 64)
                        //.padding(.bottom, 12)
                    
                    Text("of Frequency").font(.system(size: 26, weight: .semibold))
                        .foregroundStyle(.black)
                        .multilineTextAlignment(.center)
                        //.padding(.top, 40)
                        .padding(.bottom, 12)
                    
                    Text("Different sound waves push moisture out safely.")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(Color(red: 59/255, green: 65/255, blue: 72/255))
                        .padding(.bottom, 40)

                }
                
            
                ZStack {
                    Image("BlueLineImg")
                        .resizable()
                        .scaledToFit()
                        .padding(.horizontal, -10)
                    
                        //Lottie
                    
                    WavesLottieView()
                           .allowsHitTesting(false)
                           //.padding(.horizontal, 20) // якщо треба піджати // щоб не перехоплювала тапи
                                           // .padding(.horizontal, 20) // підлаштуй розмір за потреби
                }
                
                Spacer()
                
                
            }
            
        }
        
    }
}

import SwiftUI
import Lottie

final class WavesAnimationCache {
    static let shared = WavesAnimationCache()

    let animationView: LottieAnimationView

    private init() {
        let view = LottieAnimationView(name: "Waves")
        view.contentMode = .scaleAspectFit
        view.loopMode = .loop
        view.play()
        self.animationView = view
    }
}


struct WavesLottieView: UIViewRepresentable {
    func makeUIView(context: Context) -> UIView {
        let container = UIView(frame: .zero)
        let animationView = WavesAnimationCache.shared.animationView

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
        // Нічого не робимо — анімація вже крутиться в loop
    }
}



#Preview {
    BlueLinesView(index: 1 ,action: { print("N")})
}

