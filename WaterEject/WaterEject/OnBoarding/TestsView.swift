//
//  TestsView.swift
//  WaterEject
//
//  Created by Ruslan Liulka on 06.08.2025.
//

import SwiftUI

struct TestsView: View {
    
    @StateObject var viewModel = TestsViewModel()
    
    
    var body: some View {
        let isLarge = UIScreen.main.bounds.height > 900
        
        ZStack {
            Background()
            
            VStack(alignment: .center) {
                (
                    Text("Repair costs ")
                        .foregroundStyle(Color(red: 238 / 255, green: 255 / 255, blue: 236 / 255)) +
                    Text("$199")
                        .foregroundStyle(Color(red: 255 / 255, green: 153 / 255, blue: 153 / 255)) +
                    Text(".")
                        .foregroundStyle(Color(red: 238 / 255, green: 255 / 255, blue: 236 / 255))
                )
                .font(.system(size: 30, weight: .bold))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
                
                (
                    Text("Or just use Water Eject.")
                        .foregroundStyle(Color(red: 238 / 255, green: 255 / 255, blue: 236 / 255))
                )
                .font(.system(size: 30, weight: .bold))
                .multilineTextAlignment(.center)
                .padding(.bottom, isLarge ? 100 : 80)
                .padding(.horizontal, 40)
                
                
                
                
                Text("Repair $199 ❌")
                    .font(.system(size: 20, weight: .medium))
                    .foregroundStyle(Color(red: 255 / 255, green: 153 / 255, blue: 153 / 255))
                    .padding(.horizontal, 18)
                    .padding(.vertical, 10)
                    .background(
                        RoundedRectangle(cornerRadius: 24, style: .continuous)
                            .fill(
                                LinearGradient(colors: [
                                    Color(red: 0.18, green: 0.16, blue: 0.17).opacity(0.95),
                                    Color(red: 0.10, green: 0.09, blue: 0.10).opacity(0.95)
                                ], startPoint: .topLeading, endPoint: .bottomTrailing)
                            )
                    )
                    .overlay(
                        // тонкий “скляний” бордер
                        RoundedRectangle(cornerRadius: 24, style: .continuous)
                            .stroke(Color.white.opacity(0.08), lineWidth: 1)
                    )
                    .shadow(color: .black.opacity(0.35), radius: 14, x: 0, y: 10) // м’яка тінь
                    .rotationEffect(.degrees(-5)) // легкий нахил як на макеті
                    .padding(.bottom, isLarge ? 4 : 4)
                
                
                
                Image("premiumText-1")
                    .offset(y: -20)
                    .scaleEffect(isLarge ? 1.1 : 1)
                
                HStack(spacing: 34) {
                    Image("smallGreenMark")
                        .scaleEffect(isLarge ? 1.2 : 1)
                    
                    Image("Aprove")
                        .offset(y: -50)
                        .scaleEffect(isLarge ? 1.2 : 1)
                    
                    Image("smallGreenMark")
                        .scaleEffect(isLarge ? 1.2 : 1)
                }
                .padding(.bottom, 44)
                

                Text("Get your device back to loud and clear sound without paying hundreds at a service center!")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(Color(red: 43 / 255, green: 217 / 255, blue: 156 / 255))
                    .padding(.horizontal, 60)
                    .multilineTextAlignment(.center)
                    
                
                
                
                
            }
            .frame(maxHeight: .infinity, alignment: .top)
            .padding(.horizontal, 12)
            .padding(.top, 50)
            
            
            
        }
    }
}


struct TestCheckCard: View {
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
                    .foregroundStyle(Color(red: 43/255, green: 217/255, blue: 156/255))
                Text(label)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(Color(red: 43/255, green: 217/255, blue: 156/255))
                Spacer()
            }
            .padding(.vertical, 18)
            .padding(.horizontal, 18)
            
            // Checkmark у правому верхньому куті
            Image(systemName: isChecked ? "checkmark.circle.fill" : "circle")
                .font(.system(size: 16))
                .foregroundStyle(Color(red: 43/255, green: 217/255, blue: 156/255))
                .padding(8) // змісти від країв
        }
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(red: 43/255, green: 217/255, blue: 156/255, opacity: 0.14))
        )
        .frame(height: 70)
    }
    
    
}



#Preview {
    TestsView()
}
