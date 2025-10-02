//
//  TestOnboardNew.swift
//  WaterEject
//
//  Created by Ruslan Liulka on 26.09.2025.
//

import SwiftUI

struct TestOnboardNew: View {
    
    private let tests: [(icon: String, label: String)] = [
        ("circle.hexagongrid", "Stereo"),
        ("dot.radiowaves.left.and.right", "Bass"),
        ("mic", "Micro"),
        ("dot.radiowaves.left.and.right", "Vibro"),
    ]
    
    private let columns = [
        GridItem(.flexible(), spacing: 14),
        GridItem(.flexible(), spacing: 14)
    ]
    
    let action: () -> Void
    
    @State private var isExiting = false
    
    private func handleCTA() {
        guard !isExiting else { return }
        withAnimation(.easeOut(duration: 0.35)) { isExiting = true }
        // Після завершення локальної анімації — викликаємо перехід нагору
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
            action()
        }
    }
    
    // Один параметр, щоб легко змінювати час
    private let exitDuration: Double = 0.35
    
    var body: some View {
        OnboardScaffold(ctaTitle: "Continue", ctaAction: handleCTA, fixedWidth: 260) {
            // увесь твій контент екрану, БЕЗ кнопки!
//            LinearGradient(
//                colors: [Color.white,
//                         Color(red: 201/255, green: 214/255, blue: 238/255)],
//                startPoint: .top, endPoint: .bottom
//            )
//            .ignoresSafeArea()
            
            VStack {
                (
                    Text("Clean done? ")
                        .foregroundStyle(Color(red: 17 / 255, green: 17 / 255, blue: 17 / 255))
                        .font(.system(size: 32, weight: .regular))
                    +
                    Text("Let’s test your device fast ")
                        .foregroundStyle(Color(red: 17 / 255, green: 17 / 255, blue: 17 / 255))
                        .font(.system(size: 32, weight: .medium))
                    +
                    Text("👀")
                        .font(.system(size: 32, weight: .bold))
                )
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
                .padding(.top, 42)
                .padding(.bottom, 22)
                
                Text("Speakers, mic, sensors — all covered.")
                    .font(.system(size: 16))
                    .foregroundStyle(Color(red: 59 / 255, green: 65 / 255, blue: 72 / 255))
                Text("Do 5 quick tests and relax!")
                    .font(.system(size: 16))
                    .foregroundStyle(Color(red: 59 / 255, green: 65 / 255, blue: 72 / 255))
                
                Image("Graph")
                    .resizable()
                    .scaledToFit()
                    .padding(.horizontal, 28)
                    .padding(.top, 72)
                    .padding(.bottom, 42)
                
                LazyVGrid(columns: columns, spacing: 0) {
                    ForEach(tests, id: \.label) { test in
                        TestCheckCardOnboard(
                            icon: test.icon,
                            label: test.label,
                            isChecked: true
                        )
                    }
                }
                .padding(.top, 14)
                .padding(.horizontal, 22)
                
                
                TestCheckCardOnboard(
                    icon: "dot.radiowaves.left.and.right",
                    label: "Test",
                    isChecked: true
                )
                .frame(alignment: .center)
                .frame(width: UIScreen.main.bounds.width / 2 - 16)
                .padding(.bottom, 24)
                
                Spacer()
                
            }
            .opacity(isExiting ? 0 : 1)
            .offset(y: isExiting ? 16 : 0)
            .animation(.easeInOut(duration: exitDuration), value: isExiting)
        }
    }
}

struct TestCheckCardOnboard: View {
    let icon: String
    let label: String
    let isChecked: Bool
    //    let onTap: () -> Void
    
    var body: some View {
        
        ZStack(alignment: .topTrailing) {
            // Основний контент
            HStack(spacing: 14) {
                Image(systemName: icon)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(Color(red: 17/255, green: 17/255, blue: 17/255))
                Text(label)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(Color(red: 17/255, green: 17/255, blue: 17/255))
                Spacer()
            }
            .padding(.vertical, 18)
            .padding(.horizontal, 18)
            
            // Checkmark у правому верхньому куті
            Image(systemName: isChecked ? "checkmark.circle.fill" : "circle")
                .font(.system(size: 16))
                .foregroundStyle(Color(red: 81/255, green: 132/255, blue: 234/255))
                .padding(8) // змісти від країв
        }
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(LinearGradient(
                    colors: [Color.white.opacity(0.35),
                             Color.white.opacity(0.15)],
                    startPoint: .top, endPoint: .bottom
                ))
        )
        .frame(height: 70)
    }
    
    
}

#Preview {
    TestOnboardNew(action: {print("hello")})
}
