//
//  OnboardingFlowViewNine.swift
//  WaterEject
//
//  Created by Ruslan Liulka on 24.11.2025.
//

import SwiftUI

struct OnboardingFlowViewNine: View {
    private let flowId = "onboard_9_steps"
    private let onboardId = OnboardTag.v9.rawValue
    
    @AppStorage("hasSeenOnboarding") var hasSeenOnboarding = false
    //@AppStorage("onb_last_shown_ts") private var onbLastShownTS: Double = 0

    @State private var currentStep: OnboardingStepNine = .stepOne
    @State private var prevStep: OnboardingStepNine? = nil          // ← старий екран (фон)
    @State private var incomingStep: OnboardingStepNine? = nil      // ← новий екран (оверлей)
    @State private var overlayX: CGFloat = 0                       // ← офсет оверлея
    @State private var isAnimating = false
    @State private var isForward = true
    
    @State private var topCardIndex: Int = 0
    @State private var colorIndex: Int = 0
    
    @State private var stepsVisited: [String] = []
    
    

    @EnvironmentObject var coordinator: AppCoordinator
    @Environment(\.dismiss) private var dismiss
    
    
    
    @State private var childAnimate = false
    private let slideDuration: Double = 0.5
    
    
    private func appendStep(_ step: OnboardingStepNine) {
        let id = screenId(for: step)
        if stepsVisited.last != id { stepsVisited.append(id) }
    }
    
    @State private var paywallShown = false

    private func persist(tag: OnboardTag) {
        OnboardingSessionStore.shared.save(tag: tag, steps: stepsVisited, paywallShown: paywallShown)
        OnboardTag.saveAsLast(tag)
    }

    var body: some View {
        GeometryReader { geo in
            ZStack {

                // 2) Старий екран — залишається на місці під час анімації
                if let p = prevStep {
                    screen(for: p, startAnimations: false, staticDisplay: true)
                        .id(p)
                        .frame(width: geo.size.width, height: geo.size.height)  // ✅ фіксуємо розмір
                        .zIndex(0)
                } else {
                    // якщо немає prevStep, показуємо поточний як базовий
                    screen(for: currentStep, startAnimations: true, staticDisplay: false)
                        .id(currentStep)
                        .frame(width: geo.size.width, height: geo.size.height)  // ✅
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
//                            withAnimation(.interactiveSpring(response: 0.5, dampingFraction: 0.9)) {
//                                overlayX = 0
//                            }
                        }
                }
            }
            .task {
                //onbLastShownTS = Date().timeIntervalSince1970
                //Telemetry.shared.onboardFlowMark(.v41)
                
                Telemetry.shared.onboardStarted(onboardId: onboardId)
                
                Telemetry.shared.onbFlowStart(flowId: flowId)
                Telemetry.shared.onbScreenView(flowId: flowId, screenId: screenId(for: currentStep))
                
                appendStep(currentStep)
            }
            .onChange(of: topCardIndex) { newValue in
                // newValue: 1 → друга картка, 2 → третя, 3 → четверта
                let stepIndex = newValue + 1           // бо перша картка = step_1
                let screenId = "step_\(stepIndex)"     // "step_2", "step_3", "step_4"
                
                // не дублюємо, якщо вже останній такий самий
                if stepsVisited.last != screenId {
                    stepsVisited.append(screenId)
                }
                
                // окремий лог перегляду "підкроку"
                Telemetry.shared.onbScreenView(flowId: flowId, screenId: screenId)
            }
        }
    }

    // MARK: - Навігація
    private func goTo(_ step: OnboardingStepNine, forward: Bool) {
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
            incomingStep = nil
            isAnimating = false
            
            Telemetry.shared.onbScreenView(flowId: flowId, screenId: screenId(for: step))
            
            if step != .paywall {
//                       incomingStep = nil
                // Telemetry.shared.onbScreenView(flowId: flowId, screenId: screenId(for: step))
                
                appendStep(step)
                persist(tag: .v5)
            } else {
                PaywallGate.shared.currentContext = .onboarding
            }

        }
    }

    private func finishOnboarding() {
        Telemetry.shared.onboardingFinish()
        //hasSeenOnboarding = true
        dismiss()
        coordinator.showMainTabbar()
    }
    

    // Виклики з дочірніх екранів
    private func goToNextStep() {
        if let idx = OnboardingStepNine.allCases.firstIndex(of: currentStep),
           idx + 1 < OnboardingStepNine.allCases.count {
            goTo(OnboardingStepNine.allCases[idx + 1], forward: true)
        }
    }
    
    // MARK: - Screen IDs для аналітики
    private func screenId(for step: OnboardingStepNine) -> String {
        
        switch step {
        case .stepOne:
            return "step_1"
        case .paywall:
            return "paywall"
        }

    }

    // MARK: - Рендер екрана та фону
    @ViewBuilder
    private func screen(for step: OnboardingStepNine, startAnimations: Bool = true, staticDisplay: Bool = false) -> some View {
        switch step {
        case .stepOne:
            //StartOnboardView(action: { goTo(.wallet, forward: true) }, startAnimations: startAnimations, staticDisplay: staticDisplay)
            ImageCardView(action: { goTo(.paywall, forward: true) },
                         topCardIndex: $topCardIndex,
                         colorIndex: $colorIndex,
                         )
            //OnboardFourthFirstView(action: { goTo(.paywall, forward: true) })
        
        case .paywall:
            
            PaywallAB.shared
                   .onboardingPaywallView(
                       for: .v9,                       // тег онборду (Onbord_v_3.3)
                       onFinish: finishOnboarding,
                       startDelay: slideDuration + 0.0,
                       stepsVisited: stepsVisited
                   )
                   .onAppear {
                       paywallShown = true
                       persist(tag: .v9)
                   }

//            PaywallFourView(
//                    onFinish: finishOnboarding,
//                    onboardId: onboardId,
//                    startDelay: slideDuration + 0.1,   // 0.55 s
//                    summaryTag: .v5,
//                    stepsVisited: stepsVisited
//                    
//                )
//            .onAppear {
//                    //Telemetry.shared.onbScreenView(flowId: flowId, screenId: "paywall")
//                    paywallShown = true        // <-- тут, а не вище
//                    persist(tag: .v5)      // якщо зберігаєш прогрес
//                
//            }
        }
    }

}
