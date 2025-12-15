//
//  MeetOneView.swift
//  WaterEject
//
//  Created by Ruslan Liulka on 11.12.2025.
//

import SwiftUI

struct MeetOneView: View {
    let index: Int
    let action: () -> Void
    @Binding var expandedIndex: Int
    private func handleCTA() {
        stopAutoCycle()
        action()
    }

    @State private var cardsCycleTask: Task<Void, Never>? = nil
    
    // загальний час одного повного циклу для групи (секунди)
    private let cardCycleDuration: Double = 1.8
    
    private func startAutoCycle() {
            // На всяк випадок скасовуємо попередній
            cardsCycleTask?.cancel()
            
            cardsCycleTask = Task {
                while !Task.isCancelled {
                    try? await Task.sleep(
                        nanoseconds: UInt64(cardCycleDuration * 1_000_000_000)
                    )
                    if Task.isCancelled { break }
                    
                    await MainActor.run {
                        withAnimation(.spring(response: 0.55, dampingFraction: 0.85)) {
                            expandedIndex = (expandedIndex + 1) % 3
                        }
                    }
                }
            }
        }

        private func stopAutoCycle() {
            cardsCycleTask?.cancel()
            cardsCycleTask = nil
        }

    
    var body: some View {
        
        let isSmall = UIScreen.main.bounds.height < 700
        let isLarge = UIScreen.main.bounds.height > 900
        
        OnboardWaterDrops(ctaTitle: "Start Cleaning", ctaAction: handleCTA, pages: 4, pageIndex: index, fixedWidth: 260) {
            
            Color(red: 225 / 255, green: 233 / 255, blue: 239 / 255).ignoresSafeArea()
            
            VStack() {
                VStack(alignment: .center) {
                    Text("Meet the Cleaning Modes")
                        .font(.system(size: 32, weight: .bold))
                        .multilineTextAlignment(.center)
                        .lineLimit(nil)
                        .fixedSize(horizontal: false, vertical: true)
                        .foregroundStyle(.black)
                        .padding(.horizontal, 16)
                        .padding(.top, 44)

        
                    //.padding(.bottom, 12)
                    
                    
                    
                    Text("Each one is tuned for a specific purpose — from deep water ejection to frequency modulation.")
                        .font(.system(size: 18, weight: .semibold))
                        .multilineTextAlignment(.center)
                        .lineLimit(nil)
                        .fixedSize(horizontal: false, vertical: true)
                        .foregroundStyle(Color(red: 59/255, green: 65/255, blue: 72/255))
                        .padding(.horizontal, 20)
                        .padding(.bottom, 22)
                    
                }
                
                
                Image("MeetLineOnboard")
                    .resizable()
                    .scaledToFit()
                
                HStack(spacing: 12) {
                    ModeInfoCard(
                        iconName: "slider",
                        title: "Frequency Control",
                        subtitle: "Adjust pitch for different device",
                        isExpanded: expandedIndex == 0
                    )
                    
                    ModeInfoCard(
                        iconName: "music",
                        title: "Intensity Boost",
                        subtitle: "Select Bass or Loudness  ",
                        isExpanded: expandedIndex == 1
                    )
                    
                    ModeInfoCard(
                        iconName: "userSetting",
                        title: "Custom Profiles",
                        subtitle: "Save your favorite settings for future use",
                        isExpanded: expandedIndex == 2
                    )
                }
                .padding(.horizontal, 20)
                
                Spacer()
                
                
            }
            .onAppear {
                startAutoCycle()
            }
            .onDisappear {
                stopAutoCycle()
            }
            
            
        }
        
    }
    
}


struct ModeInfoCard: View {
    let iconName: String
    let title: String
    let subtitle: String
    let isExpanded: Bool
    
    var body: some View {
        HStack(spacing: 6) {
            // Синій квадрат з іконкою
            ZStack {
                
                
                Image(iconName)
                    .frame(width: 16, height: 16)
                    .foregroundColor(.white)
            }
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 6, style: .continuous)
                    .fill(Color(red: 38/255, green: 127/255, blue: 255/255))
            )
            // .frame(width: 48, height: 48)
            
            // Текст показуємо тільки коли розгорнута
            if isExpanded {
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.black)
                    
                    Text(subtitle)
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(Color(red: 90/255, green: 96/255, blue: 104/255))
                }
                .transition(.opacity.combined(with: .move(edge: .trailing)))
            }
            
            
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 12)
        //.frame(maxWidth: isExpanded ? 260 : 80, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color.white)
                .shadow(color: .black.opacity(0.06), radius: 14, x: 0, y: 6)
        )
        //.animation(.spring(response: 0.75, dampingFraction: 0.85), value: isExpanded)
    }
}



#Preview {
    MeetOneView(index: 2 ,action: { print("N")}, expandedIndex: .constant(0))
}
