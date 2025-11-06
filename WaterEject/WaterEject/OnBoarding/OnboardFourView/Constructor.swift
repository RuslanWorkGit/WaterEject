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

enum ChooseMuffledSound: String, CaseIterable, Identifiable {
    case first = "Almost normal"
    case second = "Slightly muffled"
    case third = "Noticeably quieter"
    case fourth = "Crackling sound"
    case fifth = "Distorted or hollow"
    case sixth = "Barely audible"
    case seventh = "No sound at all"
    
    var id: String { rawValue }
    
    var subtitle: String {
            switch self {
            case .first:   return "just a tiny change in sound"
            case .second:  return "a bit softer or less clear"
            case .third:   return "volume feels lower"
            case .fourth:  return "small pops or gurgles"
            case .fifth:   return "unnatural sound"
            case .sixth:   return "very low clarity"
            case .seventh: return "completely silent"
            }
        }
}

enum ChooseTime: String, CaseIterable, Identifiable {
    case first = "Just now"
    case second = "15 min ago"
    case third = "1 hour ago"
    case fourth = "Today"
    case fifth = "Yesterday"
    case sixth = "2+ days ago"
    case seventh = "No sound at all"
    
    var id: String { rawValue }
}

//struct PillButtonNew: View {
//    let title: String
//    let action: () -> Void
//    var arrow: Bool = false
//    
//    
//    var body: some View {
//        Button(action: action) {
//            Text(title)
//                .font(.system(size: 18, weight: .semibold))
//                .foregroundStyle(.white)
//                .frame(minHeight: 52)
//                .frame(maxWidth: .infinity)
//                .contentShape(RoundedRectangle(cornerRadius: 32, style: .continuous))
//            
//        }
//        .buttonStyle(.plain)
//        .background(
//            RoundedRectangle(cornerRadius: 32, style: .continuous)
//                .fill(Color.black) // як на скріні
//        )
//        .overlay( // стрілка зверху, не зсуває текст
//            Group {
//                if arrow {
//                    Image(systemName: "chevron.right")
//                        .foregroundStyle(.white)
//                        .fontWeight(.bold)
//                        .padding(.trailing, 16)
//                }
//            },
//            alignment: .trailing
//        )
//        .overlay(
//            RoundedRectangle(cornerRadius: 32, style: .continuous)
//                .stroke(Color.white.opacity(0.08), lineWidth: 1) // тонка обводка (опційно)
//        )
//        
//    }
//}

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
                        .padding(.horizontal, 32)
                        .frame(minHeight: 52) // ключ
//                        .frame(width: fixedWidth)
                    Spacer()
                }
                
                .padding(.bottom, 30)
                
            }
    }
}
