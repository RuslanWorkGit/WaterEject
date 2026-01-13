//
//  StartView.swift
//  WaterEject
//
//  Created by Ruslan Liulka on 01.08.2025.
//

import SwiftUI


struct StartView: View {
    @StateObject private var viewModel = StartViewModel()
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var paywallGate: PaywallGate
    @EnvironmentObject private var tabBarState: TabBarState
    @State private var showVolumeAlert: Bool = false
    @StateObject private var reviewFlow = ReviewFlowManager.shared
    @Environment(\.requestReview) private var requestReview
    let device: CleaningDevice
    let mode: CleaningMode
    
    var body: some View {
        let isLarge = UIScreen.main.bounds.height > 900
        
        ZStack {
            Background(startCleaning: viewModel.startCleaning)
            
            VStack(spacing: 28) {
                
                ZStack {
                    Text(device.displayName)
                        .font(.system(size: 28, weight: .bold))
                        .foregroundStyle(.white)
                    
                    HStack {
                        Button {
//                            Telemetry.shared.startBackTap(device: device, mode: mode, disabled: viewModel.startCleaning)
//                                viewModel.stopAllPlayback(reason: "back")
//                                Telemetry.shared.startCleaningEnd(device: device, mode: mode, reason: "back")
                            dismiss()
                        } label: {
                            Image(systemName: "chevron.backward")
                                .foregroundStyle(Color(red: 161 / 255, green: 192 / 255, blue: 255 / 255))
                                .font(.system(size: 23))
                        }
                        //.disabled(viewModel.startCleaning)
                        
                        Spacer()
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 8)
                .navigationBarBackButtonHidden(true)
                .background(NavigationControllerCoordinator()) // Enable swipe gesture
                
                SelectedModeCard(
                    deviceIcon: "devices",
                    title: mode.modeName,
                    isActive: viewModel.startCleaning,
                    onSettings: { print("Settings tapped") }
                )
                .padding(.horizontal, 24)
                
                
                VStack {
                    Image(device.bigImageName)
                    
                        .padding(.top, 60)
                    
                    
                }
                
                Spacer()
                
                ZStack {
                    // Таймер
                    Text("00:\(String(format: "%02d", viewModel.countdown))")
                        .font(.system(size: 48, weight: .bold))
                        .foregroundColor(.white)
                        .opacity(viewModel.startCleaning ? 1 : 0)
                    
                        .animation(.easeInOut, value: viewModel.startCleaning)
                    
                    // Кнопка
                    Button {
//                        Telemetry.shared.startPrimaryTap(device: device, mode: mode)
                        showVolumeAlert = true
//                        Telemetry.shared.startPromptShown(device: device, mode: mode)
                        
                    } label: {
                        Text("Start cleaning (25 sec)")
                            .foregroundStyle(Color.white)
                            .padding(.vertical, 14)
                            .padding(.horizontal, 88)
                            .background(
                                Capsule()
                                    .fill(Color(red: 81 / 255, green: 132 / 255, blue: 234 / 255))
                            )
                    }
                    .opacity(viewModel.startCleaning ? 0 : 1)
                    .animation(.easeInOut, value: viewModel.startCleaning)
                }
                .frame(height: 68) // Однакова висота завжди!
                .padding(.bottom, 24)
                
            }
            .padding(.horizontal, isLarge ? 0 : 16)
            
        }
        
        .onAppear {
//            Telemetry.shared.startExposure(device: device, mode: mode)
            Task { await paywallGate.presentPaywallIfNeeded(context: .startViewAuto) }
        }
        
        .onChange(of: paywallGate.presentedVariant) { oldValue, newValue in
            guard oldValue == nil, newValue != nil else { return }
//            Telemetry.shared.startPaywallRequested(auto: true)
        }
        .onDisappear {
            viewModel.stopAllPlayback(reason: "disappear")
        }
        
        

        // Єдина презентація A/B пейволів
        .fullScreenCover(item: $paywallGate.presentedVariant, onDismiss: {
            Task {
            let converted = await paywallGate.isPro()
//                            Telemetry.shared.startPaywallDismissed(converted: converted)
                        }
        }) { variant in
            switch variant {
//            case .A:
//                PaywallFirstView(onFinish: { paywallGate.dismissPaywall() })
//            case .B:
//                PaywallSecondView(onFinish: { paywallGate.dismissPaywall() })
            case .third:
                PaywallThirdView(onFinish: { paywallGate.dismissPaywall() })
            case .fourth:
                PaywallFourView(onFinish: { paywallGate.dismissPaywall() })
            case .fifth:
                PaywallFiveView(onFinish: { paywallGate.dismissPaywall() })
            }
            
            
        }
        
        
        .alert(isPresented: $showVolumeAlert) {
            Alert(
                title: Text("Set Volume to Max"),
                message: Text("For the most effective cleaning, please set your device volume to maximum."),
                primaryButton: .default(Text("OK")) {
                    
//                    Telemetry.shared.startPromptConfirm(device: device, mode: mode)

                                       // початок очищення (лог до запуску/після — на твій вибір; тут — до)
//                                       Telemetry.shared.startCleaningBegin(device: device, mode: mode, duration: 25)
                    switch mode {
                    case .sonicPulse:
                        viewModel.playCleaningSequence()
                        viewModel.startTimer()
                    case .nanoShake:
                        viewModel.playSomeWav()
                        viewModel.startTimer()
                    case .dynamicEject:
                        viewModel.playCleaningSequenceTwo()
                        viewModel.startTimer()
                    case .hydroGuard:
                        viewModel.playCleaningSequenceThree()
                        viewModel.startTimer()
                    }
                },
                secondaryButton: .cancel({
//                    Telemetry.shared.startPromptCancel(device: device, mode: mode)
                })
            )
        }
        .onChange(of: viewModel.finishedAt) { _, ts in
            guard ts != nil else { return }
            print("✅ Mode finished at \(ts!) → asking for review")
            //ReviewPrompter.recordCompletion()
//            ReviewFlowManager.shared.recordSuccessfulCleaning(
//                   device: device.displayName,
//                   mode: mode.modeName
//               )
            
            ReviewFlowManager.shared.recordSuccessfulCleaning(
                device: device.displayName,
                mode: mode.modeName
            )
            //Task { await ReviewPrompter.maybeAsk() }
        }
//        .sheet(item: $reviewFlow.sheet) { sheet in
//            switch sheet {
//            case .initialLike:
//                ReviewInitialLikeSheet(
//                    onLike: { reviewFlow.userLiked() },
//                    onDislike: { reviewFlow.userDisliked() },
//                    onLater: { reviewFlow.userLater() }
//                )
//
//            case .starRating:
//                ReviewStarsSheet(
//                    onSelect: { stars in
//                        reviewFlow.userPickedStars(stars)
//                        if stars >= 4 {
//                            requestReview()
//                        }
//                    },
//                    onLater: { reviewFlow.dismiss() }
//                )
//
//            case .feedback(let stars):
//                ReviewFeedbackSheet(
//                    stars: stars,
//                    onSubmit: { text in reviewFlow.submitFeedback(text: text, stars: stars) },
//                    onCancel: { reviewFlow.dismiss() }
//                )
//            }
//        }
        // 1) Initial like
        .alert(
            "Did the cleaning help?",
            isPresented: Binding(
                get: { reviewFlow.route == .initialLike },
                set: { if !$0, reviewFlow.route == .initialLike { reviewFlow.dismiss() } }
            )
        ) {
            
            HStack {
                Button("👍 Yes") { reviewFlow.userLiked() }
                Button("👎 No") { reviewFlow.userDisliked() }
            }
           
            Button("Later", role: .cancel) { reviewFlow.userLater() }
        } message: {
            Text("Your answer helps us improve WaterEject.")
        }
        
        .overlay {
            if reviewFlow.route == .starRating {
                StarRatingPopup(
                    onRate: { star in
                        reviewFlow.userPickedStars(star)
                        if star >= 4 {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) { requestReview() }
                        }
                    },
                    onLater: { reviewFlow.dismiss() }
                )
                .transition(.opacity.combined(with: .scale))
            }
        }
        .animation(.easeInOut(duration: 0.2), value: reviewFlow.route)

        // 3) Feedback (1 рядок)
        .alert(
            reviewFlow.feedbackStars == nil ? "What didn’t you like?" : "How can we improve?",
            isPresented: Binding(
                get: {
                    if case .feedback = reviewFlow.route { return true }
                    return false
                },
                set: { isPresented in
                    if !isPresented { reviewFlow.dismiss() }
                }
            )
        ) {
            TextField("Write a short message…", text: $reviewFlow.feedbackText)

            Button("Send") {
                let stars = reviewFlow.feedbackStars
                let text = reviewFlow.feedbackText.trimmingCharacters(in: .whitespacesAndNewlines)
                reviewFlow.submitFeedback(text: text, stars: stars)
            }
            .disabled(reviewFlow.feedbackText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)

            Button("Cancel", role: .cancel) { reviewFlow.dismiss() }
        } message: {
            if let s = reviewFlow.feedbackStars {
                Text("You rated \(s)/5. Tell us what to fix.")
            } else {
                Text("Tell us what went wrong.")
            }
        }


        
    }
}




struct SelectedModeCard: View {
    let deviceIcon: String      // ім'я зображення для іконки пристрою
    let title: String           // довга назва режиму
    var isActive: Bool = false
    let onSettings: () -> Void  // дія на натискання шестерні
    
    private var isPad: Bool { UIDevice.current.userInterfaceIdiom == .pad }
    private var padScale: CGFloat { isPad ? 1.3 : 1.0 }
    private var size: CGFloat { isPad ? 46 : 36}
    
    var body: some View {
        HStack(spacing: 14) {
            // Іконка пристрою
            Image(deviceIcon)
                .resizable()
                .scaledToFit()
                .frame(width: size, height: size)
                .padding(.leading, 4)
            
            VStack(alignment: .leading, spacing: 2) {
                Text("Selected mode:")
                    .font(.system(size: 13 * padScale, weight: .regular))
                    .foregroundStyle(.white.opacity(0.6))
                Text(title)
                    .font(.system(size: 18 * padScale, weight: .semibold))
                    .foregroundStyle(.white)
                    .lineLimit(1)
                    .truncationMode(.tail)
            }
            .padding(.vertical, 8)
            
            Spacer()
            
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 18)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.05))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(isActive ? Color(red: 81/255, green: 132/255, blue: 234/255) : Color.clear, lineWidth: 1)
            
        )
        
        
        .animation(.easeInOut(duration: 0.3), value: isActive)
    }
}

struct StarRatingPopup: View {
    let onRate: (Int) -> Void
    let onLater: () -> Void

    var body: some View {
        ZStack {
            Color.black.opacity(0.15)
                .ignoresSafeArea()
                .onTapGesture { onLater() }

            VStack(spacing: 12) {
                Text("Rate WaterEject")
                    .font(.system(size: 22, weight: .semibold))

                HStack(spacing: 12) {
                    ForEach(1...5, id: \.self) { star in
                        Button {
                            onRate(star)
                        } label: {
                            Image(systemName: "star.fill")
                                .foregroundStyle(.yellow)
                                .font(.system(size: 28))
                        }
                    }
                }

                Button("Later", role: .cancel) { onLater() }
                    .foregroundStyle(.secondary)
                    .font(.system(size: 16, weight: .medium))
            }
            .padding(25)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
            .padding(.horizontal, 24)
        }
    }
}


//#Preview {
//    StarRatingPopup { n in
//        
//    } onLater: {
//        
//    }
//
//   // StartView(device: .iPhone , mode: .nanoShake)
//}
