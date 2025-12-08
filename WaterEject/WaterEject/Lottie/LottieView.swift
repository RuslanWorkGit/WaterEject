//
//  LottieView.swift
//  WaterEject
//
//  Created by Ruslan Liulka on 26.09.2025.
//

//import SwiftUI
//import Lottie
//
//struct LottieView: UIViewRepresentable {
//    let name: String
//    var loopMode: LottieLoopMode = .loop
//    var speed: CGFloat = 0.8
//
//    func makeUIView(context: Context) -> LottieAnimationView {
//        let v = LottieAnimationView(name: name)   // шукає JSON у Bundle
//        v.loopMode = loopMode
//        v.animationSpeed = speed
//        v.contentMode = .scaleAspectFit
//        v.backgroundBehavior = .pauseAndRestore
//        v.play()
//        return v
//    }
//
//    func updateUIView(_ uiView: LottieAnimationView, context: Context) {
//        // за потреби оновлюй speed/loopMode
//    }
//}
