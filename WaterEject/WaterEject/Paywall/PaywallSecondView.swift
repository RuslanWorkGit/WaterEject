//
//  PaywallSecondView.swift
//  WaterEject
//
//  Created by Ruslan Liulka on 13.08.2025.
//

import SwiftUI


struct PaywallSecondView: View {
    
    @StateObject private var viewModel = PaywallViewModel()
    @State private var selectedPlan: Int = 1
    
    let onFinish: () -> Void
    let deviceImages = ["devices", "airpods", "airpodsPro", "airpodsMax", "speaker"]
    var repeatedImages: [String] {
        Array(repeating: deviceImages, count: 10).flatMap { $0 }
    }
    
    var body: some View {
        
        ZStack(alignment: .topTrailing) {
            
            
            
            
            ZStack {
                Background()
                
                VStack(alignment: .center) {
                    
                    AutoScrollingDevicesSquare(images: deviceImages)
                                       .padding(.top, 8)
                                       .padding(.bottom, 42)
                    

                    
                    (
                        Text("Premium Access")
                            .foregroundStyle(Color(red: 238 / 255, green: 255 / 255, blue: 236 / 255))
                        
                    )
                    .font(.system(size: 32, weight: .bold))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)
                    .padding(.bottom, 20)
                    
                    VStack(spacing: 11) {
                        HorizontalText(title: "Auto & Manual cleaning modes", image: "slider.vertical.3")
                        HorizontalText(title: "5 pro-level sound tests", image: "powermeter")
                        HorizontalText(title: "Scientifically proven methods", image: "graduationcap")
                        HorizontalText(title: "All future features + No Ads", image: "sparkles")
                    }
                    
                    .padding(.leading, 90)
                    
                    VStack(spacing: 24) {
                        PaywallSecondPlanCard(
                            title: "7 days",
                            price: "$3.99/week",
                            sublabel: nil,
                            saveText: "only $0.57/day",
                            isSelected: selectedPlan == 0,
                            onTap: { selectedPlan = 0 }
                        )
                        PaywallSecondPlanCard(
                            title: "12 months",
                            price: "$12.99/year",
                            sublabel: "Best Value",
                            saveText: "only $0.03/day",
                            isSelected: selectedPlan == 1,
                            onTap: { selectedPlan = 1 }
                        )
                    }
                    .padding(.top, 40)
                    .padding(.bottom, 42)
                    
                    Button {
                        viewModel.buyWithRevenueCat()
                        onFinish()
                    } label: {
                        Text("Continue")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(Color(red: 13 / 255, green: 64 / 255, blue: 46 / 266))
                        
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                        
                            .background(Color(red: 43 / 255, green: 217 / 255, blue: 156 / 255))
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                        
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 26)
                    
                    HStack {
                        Image(systemName: "checkmark.shield")
                            .foregroundColor(Color(.gray))
                        Text("Cancel Anytime. Secure with App Store.")
                            .font(.system(size: 13))
                            .foregroundColor(Color(.gray))
                            .multilineTextAlignment(.center)
                    }
                    .padding(0)
                    
                    
                    HStack(spacing: 30) {
                        Button("Restore") {
                            //                    webViewURL = URL(string: "https://shorturl.at/GbC20")
                            //                    isPresentingWebView = true
                        }
                        .font(.footnote)
                        .foregroundColor(.gray)
                        
                        Button("Terms") {
                            //                    webViewURL = URL(string: "https://shorturl.at/3pyRn")
                            //                    isPresentingWebView = true
                        }
                        .font(.footnote)
                        .foregroundColor(.gray)
                        
                        Button("Privacy") {
                            //Task { await viewModel.restorePurchases() }
                        }
                        .font(.footnote)
                        .foregroundColor(.gray)
                    }

                    
                }
                .frame(maxHeight: .infinity, alignment: .top)
                .padding(.horizontal, 12)
                .padding(.top, 50)
                

                
            }
            
            Button(action: {
                viewModel.closePaywall()
                onFinish()
            }) {
                Image(systemName: "xmark")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(Color(red: 179 / 255, green: 179 / 255, blue: 179 / 255))
                    .padding(14)
            }
            .padding(.top, 20)
            .padding(.trailing, 18)
        }
    }
    
}

struct HorizontalText: View {
    let title: String
    let image: String
    
    var body: some View {
        HStack {
            Image(systemName: image)
                .resizable()
                .frame(width: 16, height: 16)
                .foregroundStyle(Color(red: 43 / 255, green: 217 / 255, blue: 156 / 255))
            Text(title)
                .font(.system(size: 15))
                .foregroundStyle(Color(red: 238 / 255, green: 255 / 255, blue: 246 / 255))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct PaywallSecondPlanCard: View {
    let title: String
    let price: String
    let sublabel: String?
    let saveText: String
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 16) {
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(isSelected ? Color(red: 43/255, green: 217/255, blue: 156/255) : Color.gray.opacity(0.3))
                    .font(.system(size: 28, weight: .light))
                
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(title)
                            .font(.system(size: 20, weight: .bold))
                            .foregroundStyle(Color(red: 238/255, green: 255/255, blue: 246/255))
                        Spacer()

                    }
                    Text(price)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(Color(red: 196/255, green: 196/255, blue: 196/255))
                }
                
      
                
                VStack {
                    if let sublabel = sublabel {
                        Text(sublabel)
                            .font(.system(size: 12))
                            .padding(.horizontal, 6)
                            .padding(.vertical, 4)
                            .background(Color(red: 43/255, green: 217/255, blue: 156/255).opacity(0.14))
                            .foregroundStyle(Color(red: 43/255, green: 217/255, blue: 156/255))
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                    }
                    
                    Text(saveText)
                        .font(.system(size: 10))
                        .foregroundStyle(Color(red: 196/255, green: 196/255, blue: 197/255))

                }
            }
            .padding(.horizontal, 16)
            .frame(maxWidth: .infinity, minHeight: 72, maxHeight: 72)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(isSelected ? Color(red: 43/255, green: 217/255, blue: 156/255) : Color.clear, lineWidth: 1)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color.white.opacity(0.05))
                    )
                    .shadow(color: isSelected ? Color(red: 43/255, green: 217/255, blue: 156/255, opacity: 0.08) : .clear, radius: 8, x: 0, y: 4)
            )
        }
        .buttonStyle(.plain)
        .padding(.horizontal, 4)
    }
}



/// Квадрат 124×124 з автоматичним горизонтальним скролом девайсів
struct AutoScrollingDevicesSquare: View {
    let images: [String]

    // Тюнінг
    private let boxSize: CGFloat = 124
    private let corner: CGFloat  = 24
    private let itemSize: CGFloat = 92     // розмір картинок всередині
    private let spacing: CGFloat  = 12
    private let speed: CGFloat    = 22     // точки/сек (змінюй під себе)

    @State private var start = Date()

    var body: some View {
        ZStack {
            // Бекграунд та обводки як на макеті
            RoundedRectangle(cornerRadius: corner)
                .fill(
                    LinearGradient(
                        colors: [
                            Color(red: 20 / 255, green: 23 / 255, blue: 26 / 255, opacity: 0.1),
                            Color(red: 222 / 255, green: 233 / 255, blue: 255 / 255, opacity: 0.2)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )

                )
                .frame(width: boxSize, height: boxSize)
            
            RoundedRectangle(cornerRadius: corner )
                .stroke(Color.white.opacity(0.25), lineWidth: 2)
                .blur(radius: 0.5)
                .offset(x: 0, y: 1)
                .mask(
                    RoundedRectangle(cornerRadius: corner).fill(
                        LinearGradient(colors: [.black, .clear], startPoint: .top, endPoint: .bottom)
                    )
                )
            
                .frame(width: boxSize, height: boxSize)

            RoundedRectangle(cornerRadius: corner + 8)
                .stroke(Color.white.opacity(0.5), lineWidth: 1)
                .frame(width: boxSize + 24, height: boxSize + 24)

            RoundedRectangle(cornerRadius: corner + 4)
                .stroke(Color(red: 43/255, green: 217/255, blue: 156/255), lineWidth: 2)
                .frame(width: boxSize + 8, height: boxSize + 8)
                


            // Контент з автоскролом
            TimelineView(.animation) { context in
                let elapsed = CGFloat(context.date.timeIntervalSince(start))
                let contentWidth = (itemSize + spacing) * CGFloat(images.count)
                // Зсув вліво; модуль по ширині блоку — безшовний цикл
                let x = -((elapsed * speed).truncatingRemainder(dividingBy: contentWidth))

                HStack(spacing: spacing) {
                    // Дублюємо масив для безперервності
                    ForEach(images + images, id: \.self) { name in
                        Image(name)
         
                    }
                }
                .offset(x: x)
                .frame(width: boxSize, height: boxSize, alignment: .leading)
                .clipped()
            }
            .clipShape(RoundedRectangle(cornerRadius: corner))
            .onAppear { start = Date() }
        }
        .frame(width: boxSize, height: boxSize)
    }
}


#Preview(body: {
    PaywallSecondView(onFinish: {print("hello")})
})
