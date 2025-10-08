//
//  OnboardingFlowViewTwo.swift
//  WaterEject
//
//  Created by Ruslan Liulka on 27.09.2025.
//


import SwiftUI

struct OnboardingFlowViewTwo: View {
    @AppStorage("hasSeenOnboarding") var hasSeenOnboarding = false
    @AppStorage("onb_last_shown_ts") private var onbLastShownTS: Double = 0

    @State private var currentStep: OnboardingStepTwo = .start
    @State private var prevStep: OnboardingStepTwo? = nil          // ← старий екран (фон)
    @State private var incomingStep: OnboardingStepTwo? = nil      // ← новий екран (оверлей)
    @State private var overlayX: CGFloat = 0                       // ← офсет оверлея
    @State private var isAnimating = false
    @State private var isForward = true

    @EnvironmentObject var coordinator: AppCoordinator
    @Environment(\.dismiss) private var dismiss
    
    @State private var childAnimate = false
    private let slideDuration: Double = 0.5

    var body: some View {
        GeometryReader { geo in
            ZStack {
                // 1) Постійний фон по актуальному кроку
                background(for: currentStep).ignoresSafeArea()

                // 2) Старий екран — залишається на місці під час анімації
                if let p = prevStep {
                    screen(for: p, startAnimations: false, staticDisplay: true)
                        .id(p)
                        .frame(width: geo.size.width, height: geo.size.height)  // ✅ фіксуємо розмір
//                                        .ignoresSafeArea()
                        .zIndex(0)
                } else {
                    // якщо немає prevStep, показуємо поточний як базовий
                    screen(for: currentStep, startAnimations: true, staticDisplay: false)
                        .id(currentStep)
                        .frame(width: geo.size.width, height: geo.size.height)  // ✅
//                                        .ignoresSafeArea()
                        .zIndex(0)
                }

                // 3) Новий екран — в’їжджає зверху поверх старого
                if let inc = incomingStep {
                    screen(for: inc, startAnimations: childAnimate, staticDisplay: false)
                        .id(inc)
                        .frame(width: geo.size.width, height: geo.size.height)  // ✅
//                                        .ignoresSafeArea()
                        .offset(x: overlayX)         // ← тільки він рухається
                        .zIndex(1)
                        .onAppear {
                            // стартуємо за межами екрана справа/зліва
                            overlayX = (isForward ? 1 : -1) * geo.size.width
                            withAnimation(.easeInOut(duration: slideDuration)) {
                                            overlayX = 0
                                        }
                            DispatchQueue.main.asyncAfter(deadline: .now() + slideDuration) {
                                            childAnimate = true
                                        }
                        }
                }
            }
            .task {
                onbLastShownTS = Date().timeIntervalSince1970
                Telemetry.shared.onboardingStart()
            }
        }
    }

    // MARK: - Навігація
    private func goTo(_ step: OnboardingStepTwo, forward: Bool) {
        guard !isAnimating, step != currentStep else { return }
        isAnimating = true
        isForward = forward
        childAnimate = false

        // фіксуємо старий і запускаємо оверлей
        prevStep = currentStep
        incomingStep = step

        // після короткої затримки (кінець пружини) — фіксуємо новий current і чистимо тимчасові
        //let delay = 0.7
        DispatchQueue.main.asyncAfter(deadline: .now() + slideDuration) {
            currentStep = step
            prevStep = nil
//            incomingStep = nil
//            isAnimating = false
            if step != .paywall {
                       incomingStep = nil
                   }
                   isAnimating = false
        }
    }

    private func finishOnboarding() {
        Telemetry.shared.onboardingFinish()
        hasSeenOnboarding = true
        dismiss()
        coordinator.showMainTabbar()
    }

    // Виклики з дочірніх екранів
    private func goToNextStep() {
        if let idx = OnboardingStepTwo.allCases.firstIndex(of: currentStep),
           idx + 1 < OnboardingStepTwo.allCases.count {
            goTo(OnboardingStepTwo.allCases[idx + 1], forward: true)
        }
    }

    // MARK: - Рендер екрана та фону
    @ViewBuilder
    private func screen(for step: OnboardingStepTwo, startAnimations: Bool = true, staticDisplay: Bool = false) -> some View {
        switch step {
        case .start:
            StartOnboardView(action: { goTo(.women, forward: true) }, startAnimations: startAnimations, staticDisplay: staticDisplay)
        case .women:
            WomenOnboardView(action: { goTo(.wallet, forward: true) }, startAnimations: startAnimations, staticDisplay: staticDisplay)
        case .wallet:
            SaveOnboardNew(action: { goTo(.paywall, forward: true) }, startAnimations: startAnimations, staticDisplay: staticDisplay)
        case .paywall:
            PaywallThirdView(onFinish: finishOnboarding)
        }
    }

    @ViewBuilder
    private func background(for s: OnboardingStepTwo) -> some View {
        switch s {
        case .start:
            LinearGradient(colors: [Color(red: 94/255, green: 148/255, blue: 1),
                                    Color(red: 56/255, green: 114/255, blue: 229/255)],
                           startPoint: .top, endPoint: .bottom)
        case .women, .wallet:
            LinearGradient(colors: [.white,
                                    Color(red: 201/255, green: 214/255, blue: 238/255)],
                           startPoint: .top, endPoint: .bottom)
        case .paywall:
            Color.black
        }
    }
}
