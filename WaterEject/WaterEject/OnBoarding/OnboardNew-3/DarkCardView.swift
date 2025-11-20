//
//  DarkCardView.swift
//  WaterEject
//
//  Created by Ruslan Liulka on 19.11.2025.
//

import SwiftUI

struct DarkCardView: View {

    var cards: [Color] = [
        Color(red: 2/255, green: 125/255, blue: 244/255),
        Color(red: 2/255, green: 125/255, blue: 244/255),
        Color(red: 2/255, green: 125/255, blue: 244/255),
        Color(red: 2/255, green: 125/255, blue: 244/255)
    ]
    
    var myCards: [StatusCardView2] = [
        StatusCardView2(imageName: "BlackCardOne"),
        StatusCardView2(imageName: "BlackCardTwo"),
        StatusCardView2(imageName: "BlackCardThree"),
        StatusCardView2(imageName: "BlackCardFour")
    ]

    var text: [String] = [
        "Did water get inside?",
        "Does it sound distorted?",
        "Worried it’s damaged?",
        "Ready to fix your speaker"
    ]
    let action: () -> Void
    private func handleCTA() {
       
        //anim()
        if isLastCard {
            action()
        } else {
            anim()
        }
        //action()
    }
    @State private var dragOffset: CGSize = .zero
    @State private var showText: Bool = true
//    @State private var topCardIndex: Int = 0
//    @State private var colorIndex: Int = 0
    
    @Binding var topCardIndex: Int
    @Binding var colorIndex: Int
    
    private var isLastCard: Bool {
        topCardIndex >= myCards.count - 1
    }

    var width: CGFloat = 220
    var height: CGFloat = 160

    var body: some View {
        
        OnboardCustomNew(ctaTitle: "Start Cleaning", ctaAction: handleCTA, fixedWidth: 260) {
            
            Color.black.ignoresSafeArea()
            
            VStack {
                VStack(alignment: .leading) {
                    
                    (
                        Text("Let's ").font(.system(size: 26, weight: .semibold))
                            .foregroundStyle(.white) +
                        Text("protect ").font(.system(size: 26, weight: .semibold))
                            .foregroundStyle(Color(red: 2/255, green: 125/255, blue: 244/255)) +
                        Text("your \nspeaker ").font(.system(size: 26, weight: .semibold))
                            .foregroundStyle(.white)
      
                    )
                    
                    .multilineTextAlignment(.leading)
                    .padding(.top, 40)
                    .padding(.bottom, 12)
                    
                    Text("Choose your device to start the check-up.")
                        .font(.system(size: 16))
                        .foregroundStyle(Color(red: 59/255, green: 65/255, blue: 72/255))
                        .padding(.bottom, 200)
                }
                
                ZStack {
                    ForEach(myCards.indices, id: \.self) { index in
                        let visualIndex = (index - topCardIndex + myCards.count) % myCards.count
                        let progress = min(abs(dragOffset.height) / 150, 1)
                        let signedProgress = (dragOffset.height >= 0 ? 1 : -1) * progress
                        
                        myCards[index]                         // 👈 підставляємо картку
                            .frame(width: width, height: height)
                            .offset(
                                x: visualIndex == 0 ? 0 : Double(visualIndex) * -10,
                                y: visualIndex == 0 ? -dragOffset.height * 0.9 : Double(visualIndex) * -15
                            )
                            .zIndex(Double(myCards.count - visualIndex))
                            .rotationEffect(
                                .degrees(
                                    visualIndex == 0
                                    ? Double(visualIndex) * 30 - progress * 35
                                    : 0
                                ),
                                anchor: .bottom
                            )
                            .offset(x: visualIndex == 0 ? 0 : Double(visualIndex) * -3)
                            .contentShape(Rectangle())
                    }
                }
                .offset(x: 20)
                
                Text(text[colorIndex])
                    .frame(width: 220)
                    .foregroundStyle(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(
                        Capsule()
                            .fill(cards[topCardIndex])     // кольори можна лишити тільки для бейджа
                    )
                    .opacity(showText ? 1 : 0)
                    //.padding(.top, 220)
                
                Spacer()
            }
        }
        .contentShape(Rectangle())
//        .onTapGesture {
//            let delay: CGFloat = 0.4        // затримка як у жесті
//            let targetOffset = height * -1.33  // куди "вилітає" картка вправо
//            
//            withAnimation(.smooth(duration: 0.5)) {
//                showText = false
//               
//            }
//            
//            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
//                withAnimation(.smooth(duration: 0.8)) {
//                    if colorIndex != 2 {
//                        colorIndex += 1
//                    } else {
//                        colorIndex = 0
//                    }
//                    showText = true
//                    
//                }
//            }
//
//            // 1) виносимо верхню картку вправо
//            withAnimation(.smooth(duration: 0.7)) {
//                dragOffset.height = targetOffset
//               
//            }
//
//            // 2) після невеликої паузи змінюємо індекс і повертаємо в нуль
//            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
//                withAnimation(.smooth(duration: 0.8)) {
//                    topCardIndex = (topCardIndex + 1) % cards.count
//                    dragOffset = .zero
//                    
//                    
//                }
//            }
//        }

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

#Preview {
    DarkCardView(
        action: { print("N") },
        topCardIndex: .constant(3),
        colorIndex: .constant(3)
        
    )
}

import SwiftUI

// MARK: - Reusable Card

struct StatusCardView2: View {
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
                .frame(width: 240)
        }

    }
}

struct NewOboardButton: View {
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
                .fill(Color(red: 81 / 255, green: 132 / 255, blue: 234 / 255)) // як на скріні
                .innerShadow(
                    RoundedRectangle(cornerRadius: 16),
                    color: .white, opacity: 0.25,
                    x: 0, y: 1, blur: 0, spread: 2
                )
        )

        
    }
}


struct OnboardCustomNew<Content: View>: View {
    let ctaTitle: String
    let ctaAction: () -> Void
    var fixedWidth: CGFloat = 260
    @ViewBuilder let content: () -> Content
    
    var body: some View {
        ZStack { content() }
            .safeAreaInset(edge: .bottom) {
                HStack { // гарантує однакову геометрію
                    Spacer()
                    NewOboardButton(title: ctaTitle, action: ctaAction, arrow: true)
                        .padding(.horizontal, 32)
                        .frame(minHeight: 52) // ключ
//                        .frame(width: fixedWidth)
                    Spacer()
                }
                
                .padding(.bottom, 30)
                
            }
    }
}
