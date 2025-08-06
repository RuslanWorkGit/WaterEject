//
//  TestsView.swift
//  WaterEject
//
//  Created by Ruslan Liulka on 06.08.2025.
//

import SwiftUI

struct TestsView: View {
    var body: some View {
        ZStack {
            Background()
            
            VStack(alignment: .center) {
                (
                    Text("Post-Cleaning Check: Make Sure Your Device Works Properly")
                        .foregroundStyle(Color(red: 238 / 255, green: 255 / 255, blue: 236 / 255))
                    
                    
                    
                    
                )
                .font(.system(size: 32, weight: .bold))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 24)
                .padding(.bottom, 4)
                
                
                Text("Test your audio with 5 simple checks")
                    .font(.system(size: 14))
                    .foregroundStyle(Color(red: 238 / 255, green: 255 / 255, blue: 236 / 255))
                    .padding(.bottom, 42)
                
                ZStack {
                    Image("Lines")
                    
                    VStack(spacing: 15) {
                        Text("32dB")
                            .font(.system(size: 80, weight: .bold))
                            .foregroundStyle(Color(red: 238 / 255, green: 255 / 255, blue: 236 / 255))
                        ZStack {
                            Image("BlueWave")
                            Image("BlackWave")
                        }
                    }
                    .offset(y: -20)
                }
                
                VStack(spacing: 18) {
                    HStack(spacing: 16) {
                        TestCheckCard(icon: "circle.hexagongrid", label: "Stereo", isChecked: true)
                        TestCheckCard(icon: "dot.radiowaves.left.and.right", label: "Bass", isChecked: true)
                    }
                    HStack(spacing: 16) {
                        TestCheckCard(icon: "mic", label: "Micro", isChecked: true)
                        TestCheckCard(icon: "dot.radiowaves.left.and.right", label: "Vibro", isChecked: true)
                    }
                    HStack(spacing: 16) {
                        TestCheckCard(icon: "circle.dotted", label: "Noise", isChecked: true)
                        Spacer() // для вирівнювання
                    }
                }
                .padding(.top, 8)
                .padding(.horizontal, 6)
                
                
                
            }
            .frame(maxHeight: .infinity, alignment: .top)
            .padding(.horizontal, 12)
            .padding(.top, 50)
            
            
            
        }
    }
}

struct TestCheckCard: View {
    let icon: String      // systemName для SFSymbols або ім'я картинки
    let label: String
    let isChecked: Bool

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.system(size: 22, weight: .medium))
                .foregroundStyle(Color(red: 56/255, green: 255/255, blue: 185/255)) // Зелено-блакитний
            Text(label)
                .font(.system(size: 22, weight: .medium))
                .foregroundStyle(Color(red: 56/255, green: 255/255, blue: 185/255))
            Spacer()
            if isChecked {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 26))
                    .foregroundStyle(Color(red: 56/255, green: 255/255, blue: 185/255))
            }
        }
        .padding(.vertical, 14)
        .padding(.horizontal, 18)
        .background(
            RoundedRectangle(cornerRadius: 22)
                .fill(Color(red: 8/255, green: 44/255, blue: 51/255, opacity: 0.32))
        )
        .frame(height: 70)
    }
}


#Preview {
    TestsView()
}
