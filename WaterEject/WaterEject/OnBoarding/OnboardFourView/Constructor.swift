//
//  Constructor.swift
//  WaterEject
//
//  Created by Ruslan Liulka on 06.11.2025.
//
import Foundation
import SwiftUI

enum ChooseDevice: String, CaseIterable, Identifiable {
    case iphone = "iPhone"
    case ipad = "iPad"
    case airPodsPro = "AirPods Pro"
    case airPods = "AirPods"
    case airPodsMax = "AirPods Max"
    case speakers = "Speakers"
    
    var id: String { rawValue }
}

enum ChooseReason: String, CaseIterable, Identifiable {
    case first = "Dropped in water 💧"
    case second = "Splashed during hand wash 💦"
    case third = "Got wet from rain ☔️"
    case fourth = "Steam after shower 🚿"
    case fifth = "Used in humid room 🌫️"
    case sixth = "Spilled drink on it ☕️"
    case seventh = "Sound became muffled 🔊"
    case eigth = "Don’t know, just sounds weird 🤔"
    
    var id: String { rawValue }
}

struct PillButtonNew: View {
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
                .contentShape(RoundedRectangle(cornerRadius: 32, style: .continuous))
            
        }
        .buttonStyle(.plain)
        .background(
            RoundedRectangle(cornerRadius: 32, style: .continuous)
                .fill(Color.black) // як на скріні
        )
        .overlay( // стрілка зверху, не зсуває текст
            Group {
                if arrow {
                    Image(systemName: "chevron.right")
                        .foregroundStyle(.white)
                        .fontWeight(.bold)
                        .padding(.trailing, 16)
                }
            },
            alignment: .trailing
        )
        .overlay(
            RoundedRectangle(cornerRadius: 32, style: .continuous)
                .stroke(Color.white.opacity(0.08), lineWidth: 1) // тонка обводка (опційно)
        )
        
    }
}

struct OnboardScaffoldNew<Content: View>: View {
    let ctaTitle: String
    let ctaAction: () -> Void
    var fixedWidth: CGFloat = 260
    @ViewBuilder let content: () -> Content
    
    var body: some View {
        ZStack { content() }
            .safeAreaInset(edge: .bottom) {
                HStack { // гарантує однакову геометрію
                    Spacer()
                    PillButtonNew(title: ctaTitle, action: ctaAction, arrow: true)
                        .frame(minHeight: 52) // ключ
                        .frame(width: fixedWidth)
                    Spacer()
                }
                
                .padding(.bottom, 30)
                
            }
    }
}
