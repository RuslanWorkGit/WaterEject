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
        
        OnboardWaterDrops(ctaTitle: textButton, ctaAction: handleCTA, pages: 0, fixedWidth: 260) {
            
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
                
                LottieSwiftUIView(
                    name: "NewWaveLine",
                    loopMode: .loop,
                    speed: 0.8,
                    contentMode: .scaleAspectFit
                )
          // ← головний контролер розміру
                .frame(maxWidth: .infinity)   // по ширині як екран
                .padding(.horizontal, -10)
                .padding(.top, 24)
                

                
//                Image("OnboardWaves")
//                    .resizable()
//                    .scaledToFit()
//                    .padding(.horizontal, -10)
                
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

struct LottieSwiftUIView: UIViewRepresentable {
    let name: String
    var loopMode: LottieLoopMode = .loop
    var speed: CGFloat = 1.0
    var contentMode: UIView.ContentMode = .scaleAspectFit

    func makeUIView(context: Context) -> UIView {
        let container = UIView()
        container.backgroundColor = .clear

        let animationView = LottieAnimationView(name: name)
        animationView.translatesAutoresizingMaskIntoConstraints = false
        animationView.loopMode = loopMode
        animationView.animationSpeed = speed
        animationView.contentMode = contentMode
        animationView.backgroundBehavior = .pauseAndRestore

        container.addSubview(animationView)

        // Жорстко фіксуємо розмір анімації всередині контейнера
        NSLayoutConstraint.activate([
            animationView.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            animationView.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            animationView.widthAnchor.constraint(equalTo: container.widthAnchor, multiplier: 1),
            animationView.heightAnchor.constraint(equalTo: container.heightAnchor, multiplier: 1)
        ])

        animationView.play()
        return container
    }

    func updateUIView(_ uiView: UIView, context: Context) {
        // якщо треба оновлювати speed / loopMode — можна знайти animationView по subviews
    }
}





#Preview {
    ThirdWaveView(action: { print("N")}, textButton: "Continue")
}
