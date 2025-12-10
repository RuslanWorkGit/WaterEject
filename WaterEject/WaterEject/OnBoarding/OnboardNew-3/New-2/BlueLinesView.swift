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
                    
                    LottieViewNew(name: "Waves", loopMode: .loop)
                                            .allowsHitTesting(false) // щоб не перехоплювала тапи
                                           // .padding(.horizontal, 20) // підлаштуй розмір за потреби
                }
                
                Spacer()
                
                
            }
            
        }
        
    }
}

import SwiftUI
import Lottie

struct LottieViewNew: UIViewRepresentable {
    let name: String
    let loopMode: LottieLoopMode

    init(name: String, loopMode: LottieLoopMode = .loop) {
        self.name = name
        self.loopMode = loopMode
    }

    func makeUIView(context: Context) -> some UIView {
        let view = UIView(frame: .zero)

        let animationView = LottieAnimationView(name: name)
        animationView.contentMode = .scaleAspectFit
        animationView.loopMode = loopMode
        animationView.play()

        animationView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(animationView)

        NSLayoutConstraint.activate([
            animationView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            animationView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            animationView.topAnchor.constraint(equalTo: view.topAnchor),
            animationView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        return view
    }

    func updateUIView(_ uiView: UIViewType, context: Context) {
        // тут нічого не треба, анімація вже крутиться в loop
    }
}


#Preview {
    BlueLinesView(index: 1 ,action: { print("N")})
}

