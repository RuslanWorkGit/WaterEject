//
//  ImageCardView.swift
//  WaterEject
//
//  Created by Ruslan Liulka on 24.11.2025.
//


import SwiftUI

struct ImageCardView: View {

    var cards: [Color] = [
        Color(red: 2/255, green: 125/255, blue: 244/255),
        Color(red: 2/255, green: 125/255, blue: 244/255),
        Color(red: 2/255, green: 125/255, blue: 244/255),
        Color(red: 2/255, green: 125/255, blue: 244/255)
    ]
    
    @State private var textScaleX: CGFloat = 1.0
    @State private var textAnchor: UnitPoint = .center
    

    private let images = ["ManWater", "PhoneWater", "PhoneSand", "PhoneWaterTwo"]

    var text: [String] = [
        "Got caught in the rain? Got caught in the rain?",
        "AirPod took a dive in the toilet?",
        "Went swimming with your phone?",
        "Dropped your phone into the sink?"
    ]
    
    let action: () -> Void
    private func handleCTA() {
        if currentIndex < images.count - 1 {
            showNextImage()     // анімація переходу до наступного кадру
        } else {
            action()            // вже на останній картинці → йдемо на paywall
        }
    }
    @State private var dragOffset: CGSize = .zero
    @State private var showText: Bool = true
    @Binding var topCardIndex: Int
    @Binding var colorIndex: Int
    
    @State private var currentIndex = 0
    @State private var fadingOut = false
    @State private var isTransitioning = false
    @State private var imageKey = UUID()     // перезапуск анімації для нового кадру
    private let fadeOutDuration: Double = 0.5
    private let wrap = true                  // зробити цикл по колу
    
//    private var isLastCard: Bool {
//        topCardIndex >= myCards.count - 1
//    }
    
//    private func showNextImage() {
//        guard !isTransitioning else { return }
//        guard currentIndex < images.count - 1 else { return }
//
//        isTransitioning = true
//
//        // гасимо картинку + текст
//        withAnimation(.easeOut(duration: fadeOutDuration)) {
//            fadingOut = true
//            showText  = false
//        }
//
//        DispatchQueue.main.asyncAfter(deadline: .now() + fadeOutDuration) {
//            let next = currentIndex + 1
//
//            // оновлюємо індекси
//            currentIndex = next
//            topCardIndex = next
//            colorIndex   = next
//
//            // щоб AnimatedHeroImage перезапустив onAppear
//            imageKey = UUID()
//
//            // миттєво повертаємо непрозорість, а потім знову показуємо текст
//            fadingOut = false
//            withAnimation(.easeIn(duration: 0.25)) {
//                showText = true
//            }
//
//            isTransitioning = false
//        }
//    }
    private func showNextImage() {
        guard !isTransitioning else { return }
        guard currentIndex < images.count - 1 else { return }

        isTransitioning = true

        // 1) Картинка фейд-аут, текст стискається справа наліво
        withAnimation(.easeOut(duration: fadeOutDuration)) {
            fadingOut = true

            textAnchor = .leading       // стискаємось до правого краю
            textScaleX = 0.01            // майже 0, але не повний нуль
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + fadeOutDuration - 0.1) {
            let next = currentIndex + 1

            // оновлюємо індекси
            currentIndex = next
            topCardIndex = next
            colorIndex   = next

            // перезапускаємо анімацію картинки
            imageKey = UUID()
            fadingOut = false

            // 2) готуємо новий текст: вузький, зліва
            textAnchor = .leading
            textScaleX = 0.01

            // 3) розтискаємо зліва направо
            withAnimation(.easeOut(duration: 0.6)) {
                textScaleX = 1.0
            }

            isTransitioning = false
        }
    }



    var width: CGFloat = 220
    var height: CGFloat = 160

    var body: some View {
        
        OnboardCustomNew(ctaTitle: "Start Cleaning", ctaAction: handleCTA, fixedWidth: 260) {
            
            Color(red: 225 / 255, green: 233 / 255, blue: 239 / 255).ignoresSafeArea()
            
            VStack() {
                VStack(alignment: .leading) {
                    
                    (
                        Text("Let's ").font(.system(size: 30, weight: .bold))
                            .foregroundStyle(.black) +
                        Text("protect ").font(.system(size: 30, weight: .bold))
                            .foregroundStyle(Color(red: 2/255, green: 125/255, blue: 244/255)) +
                        Text("your \nspeaker ").font(.system(size: 30, weight: .bold))
                            .foregroundStyle(.black)
      
                    )
                    
                    .multilineTextAlignment(.leading)
                    //.padding(.horizontal, 16)
                    .padding(.top, 40)
                    .padding(.bottom, 8)
                    
//                    Text("Choose your device to start the check-up.")
//                        .font(.system(size: 16))
//                        .foregroundStyle(.black.opacity(0.6))
//                        .padding(.bottom, 0)
                }
                
                
                
                
                VStack(spacing: 4) {          // 🔹 мінімальний відступ між картинкою і текстом
                    AnimatedHeroImage(
                        name: images[currentIndex],
                        fromSize: 350,
                        toSize: 250,
                        startDelay: currentIndex == 0 ? 0.5 : 0.0,
                        transformTime: 0.6,
                        blurTime: 0.35,
                        blurRadius: 14,
                        cornerRadius: 16
                    )
                    .id(imageKey)
                    .opacity(fadingOut ? 0 : 1)
                     

                    Text(text[currentIndex])
                        .font(.system(size: 20, weight: .semibold))
                        .multilineTextAlignment(.center)
                        .lineLimit(nil)
                        .fixedSize(horizontal: false, vertical: true)
                        .foregroundStyle(.black)
                        .frame(width: .infinity)
                        .padding(.vertical, 8)
                        .scaleEffect(x: textScaleX, y: 1.0, anchor: textAnchor)
                        .padding(.top, -50)
                }
                
                Spacer()
            }
        }
        .contentShape(Rectangle())
        .onAppear {
            currentIndex = topCardIndex      // щоб з батьківським станом було однаково
        }



    }
    
    
    func anim() {
        let delay: CGFloat = 0.45        // затримка як у жесті
        let targetOffset = height * -1.33  // куди "вилітає" картка вправо
        
        withAnimation(.smooth(duration: 0.3)) {
            showText = false
           
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            withAnimation(.smooth(duration: 0.1)) {
                if colorIndex != 2 {
                    colorIndex += 1
                } else {
                    colorIndex = 0
                }
                                
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(.smooth(duration: 0.5)) {
                    showText = true
                }
            }

        }

        // 1) виносимо верхню картку вправо
        withAnimation(.smooth(duration: 0.7)) {
            dragOffset.height = targetOffset
           
        }

        // 2) після невеликої паузи змінюємо індекс і повертаємо в нуль
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            withAnimation(.smooth(duration: 0.8)) {
                topCardIndex += 1
                dragOffset = .zero
                
                
            }
        }
    }

}

struct AnimatedHeroImage: View {
    let name: String
    // Геометрія та таймінги
    var fromSize: CGFloat = 250      // максимальний розмір (контейнер)
    var toSize: CGFloat = 150        // у скільки разів візуально зменшити
    var startDelay: Double = 0.5
    var transformTime: Double = 0.9
    var blurTime: Double = 0.45
    var blurRadius: CGFloat = 14
    
    var cornerRadius: CGFloat = 16
    var showShadow: Bool = true
    
    @State private var animateTransform = false   // масштаб + поворот
    @State private var removeBlur = false         // зняття блюра

    var body: some View {
        let shape = RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
        let scale = animateTransform ? (toSize / fromSize) : 1.0   // 1 → 0.7, наприклад

        ZStack {
            Image(name)
                .resizable()
                .scaledToFill()
                .animation(.easeOut(duration: blurTime), value: removeBlur)
        }
        .opacity(animateTransform ? 1 : 0)
        .frame(width: fromSize, height: fromSize)      // 🔹 КОНТЕЙНЕР ФІКСОВАНОГО РОЗМІРУ
        .clipShape(shape)
        .shadow(color: .black.opacity(showShadow ? 0.08 : 0), radius: 12, x: 0, y: 6)
        .rotationEffect(.degrees(animateTransform ? 0 : 12))
        .scaleEffect(scale)                            // 🔹 анімація “зменшення”
        .blur(radius: animateTransform ? 0 : 20)
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + startDelay) {
                withAnimation(.spring(response: 1.4,
                                      dampingFraction: 0.88,
                                      blendDuration: 0.2)) {
                    animateTransform = true
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + transformTime) {
                    withAnimation(.easeOut(duration: blurTime)) {
                        removeBlur = true
                    }
                }
            }
        }
        .onDisappear {
            animateTransform = false
            removeBlur = false
        }
    }
}



struct StatusCardView3: View {
    let imageName: String
    
    private var accent: Color {
        // #027DF4
        Color(red: 2/255, green: 125/255, blue: 244/255)
    }
    
    var body: some View {
        VStack {
            
            Image(imageName)
                .resizable()
                .scaledToFit()
                .frame(width: 200)
        }

    }
}

#Preview {
    ImageCardView(
        action: { print("N") },
        topCardIndex: .constant(0),
        colorIndex: .constant(0)
        
    )
}
