//
//  WelcomeView.swift
//  WaterEject
//
//  Created by Ruslan Liulka on 08.12.2025.
//

import SwiftUI

struct FirstWelcomeView: View {
    let action: () -> Void
    let textButton: String
    private func handleCTA() {
        
        action()
    }
    
    var body: some View {
        
        
        OnboardNewStyle(ctaTitle: textButton, ctaAction: handleCTA, fixedWidth: 260) {
            
            Color(red: 225 / 255, green: 233 / 255, blue: 239 / 255).ignoresSafeArea()
            
            VStack() {
                VStack(alignment: .center) {
                    Text("WELCOME TO WATER EJECT")
                        .font(.custom("Montserrat-ExtraBold", size: 32))
                        .foregroundStyle(Color(red: 45 / 255, green: 127 / 255, blue: 249 / 255))
                        .multilineTextAlignment(.center)
                        .padding(.top, 64)
        
                    

                }
                
            
                
                ReviewsCarouselView()
                                   .padding(.top, 150)
                                   .padding(.horizontal, 16)

                
                Spacer()
                
                
            }
            
        }
        
    }
}

#Preview {
    FirstWelcomeView(action: { print("N")}, textButton: "Continue")
}

struct NewOboardStyleButton: View {
    let title: String
    let action: () -> Void
    var arrow: Bool = false
    
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(.white)
                .frame(minHeight: 52)
                .frame(maxWidth: .infinity)
            //.contentShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            
        }
        //.buttonStyle(.plain)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color(red: 2 / 255, green: 125 / 255, blue: 244 / 255)) // як на скріні
                .innerShadow(
                    RoundedRectangle(cornerRadius: 16),
                    color: .white, opacity: 0.25,
                    x: 0, y: 1, blur: 0, spread: 2
                )
        )

        
    }
}

struct OnboardNewStyle<Content: View>: View {
    let ctaTitle: String
    let ctaAction: () -> Void
    var fixedWidth: CGFloat = 260
    @ViewBuilder let content: () -> Content
    
    var body: some View {
        ZStack { content() }
            .safeAreaInset(edge: .bottom) {
                VStack {
                    
                    HStack { // гарантує однакову геометрію
                        Spacer()
                        NewOboardStyleButton(title: ctaTitle, action: ctaAction, arrow: true)
                            .padding(.horizontal, 40)
                            .frame(minHeight: 52) // ключ
                            .frame(width: .infinity)
                        Spacer()
                    }
                    
                    
                }
                

                
        }
    }
}

enum Slide: Int, CaseIterable {
    case maria, daniel, kevin, sophie
}

final class ReviewsCarouselModel: ObservableObject {
    @Published var current: Slide = .maria
    @Published var isForward: Bool = true
}


private struct ReviewsCarouselView: View {
    @EnvironmentObject private var model: ReviewsCarouselModel
        @Environment(\.accessibilityReduceMotion) var reduceMotion

        @State private var autoAdvanceWorkItem: DispatchWorkItem?
        @State private var didShowOnce = false





    private let interval: TimeInterval = 2.0

    var body: some View {
        ZStack(alignment: .top) {
            Group {
                switch model.current {
                case .maria:
                    OnboardingReviewBlock(
                        name: "Maria",
                        title: "It saved my iPhone!",
                        bodyText: "I tried countless methods to fix my phone, but nothing worked. Then I discovered this speaker cleaner app! It brought my phone back to life!"
                    )
                case .daniel:
                    OnboardingReviewBlock(
                        name: "Daniel",
                        title: "Finally fixed the muffled sound!",
                        bodyText: "I spilled water on my phone and the speaker became super quiet. This app pushed the water out in seconds — the sound is clear again!"
                    )
                case .kevin:
                    OnboardingReviewBlock(
                        name: "Kevin",
                        title: "Saved me from going to repair!",
                        bodyText: "I thought I'd have to replace my speaker after a shower accident. This app literally saved me money — the speaker now works like new."
                    )
                case .sophie:
                    OnboardingReviewBlock(
                        name: "Sophie",
                        title: "Worked better than rice!",
                        bodyText: "I tried drying my phone for hours, but the sound was still distorted. One cycle in this app and everything was back to normal. Highly recommend!"
                    )
                }
            }
            .id(model.current)
            .transition(
                .asymmetric(
                    insertion: .move(edge: model.isForward ? .trailing : .leading)  // 👈 напрямок для появи
                        .combined(with: .opacity),
                    removal:   .move(edge: model.isForward ? .leading : .trailing)  // 👈 напрямок для зникнення
                        .combined(with: .opacity)
                )
            )
            .frame(maxWidth: .infinity,
                   maxHeight: .infinity,
                   alignment: .top)
        }
        .frame(height: 230)
        .animation(reduceMotion ? nil : .easeInOut(duration: 0.35), value: model.current)
        .contentShape(Rectangle())
        .gesture(
            DragGesture(minimumDistance: 20)
                .onEnded { value in
                    let translation = value.translation.width
                    let threshold: CGFloat = 40
                    guard abs(translation) > threshold else { return }

                    if translation < 0 {
                        // свайп ліворуч → вперед
                        goNext()
                    } else {
                        // свайп праворуч → назад
                        goPrevious()
                    }

                    restartAutoAdvance()
                }
        )
        .onAppear { restartAutoAdvance() }
        .onDisappear { autoAdvanceWorkItem?.cancel() }
    }

    // MARK: - Навігація

    private func goNext() {
        let all = Slide.allCases
        guard let idx = all.firstIndex(of: model.current) else { return }
        let next = all[(idx + 1) % all.count]

        model.isForward = true              // 👈 переходимо вперед
        model.current = next
    }

    private func goPrevious() {
        let all = Slide.allCases
        guard let idx = all.firstIndex(of: model.current) else { return }
        let prev = all[(idx - 1 + all.count) % all.count]

        model.isForward = false             // 👈 переходимо назад
        model.current = prev
    }

    // MARK: - Авто-перелистування

    private func restartAutoAdvance() {
        autoAdvanceWorkItem?.cancel()
        guard !reduceMotion else { return }

        let work = DispatchWorkItem {
            goNext()
            restartAutoAdvance()
        }
        autoAdvanceWorkItem = work
        DispatchQueue.main.asyncAfter(deadline: .now() + interval, execute: work)
    }
}



private struct OnboardingReviewBlock: View {
    let name: String
    let title: String
    let bodyText: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {

            // сама карточка
            VStack(alignment: .leading, spacing: 10) {
                HStack(alignment: .top) {
                    StarsRow()
                    Spacer()
                    Text(name)
                        .font(.custom("Montserrat-SemiBold", size: 16))
                        .foregroundColor(.black)
                }

                Text(title)
                    .font(.custom("Montserrat-ExtraBold", size: 20))
                    .foregroundColor(.black)

                Text(bodyText)
                    .font(.custom("Montserrat-Medium", size: 14))
                    .foregroundColor(.black.opacity(0.8))
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(18)
            .background(
                RoundedRectangle(cornerRadius: 28, style: .continuous)
                    .fill(Color.white)
                    .shadow(color: .black.opacity(0.10), radius: 24, x: 0, y: 10)
            )
        }
    }
}

private struct StarsRow: View {
    var body: some View {
        HStack(spacing: 4) {
            ForEach(0..<5, id: \.self) { _ in
                Image(systemName: "star.fill")
                    .font(.system(size: 16))
                    .foregroundColor(Color(red: 250/255, green: 204/255, blue: 21/255))
            }
        }
    }
}



