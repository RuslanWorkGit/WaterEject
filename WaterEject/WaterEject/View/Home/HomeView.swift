//
//  HomeView.swift
//  WaterEject
//
//  Created by Ruslan Liulka on 01.08.2025.
//

import SwiftUI

struct HomeView: View {
    var body: some View {
        ZStack {
            Color(red: 19 / 255, green: 21 / 255, blue: 23 / 255)
            .ignoresSafeArea()
            
            VStack(spacing: 28) {
                HStack {
                    Text("Speaker Cleaner")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.white)
                    Spacer()
                    Button(action: {
                        print("Setting pressed")
                    }) {
                        Image(systemName: "gearshape")
                            .font(.system(size: 24))
                            .foregroundStyle(Color(red: 153 / 255, green: 153 / 255, blue: 153 / 255))
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 16)
                
                Spacer()
                
                DeviceGridView()
                
                Spacer()
            }
        }
    }
}

#Preview {
    HomeView()
}

import SwiftUI

struct DeviceButtonView: View {
    let imageName: String
    let label: String
    
    var body: some View {
        VStack(spacing: 12) {
            Image(imageName)
            //.resizable()
                //.scaledToFit()
                //.frame(width: 50, height: 64)
                .foregroundStyle(.white)
            Text(label)
                .font(.headline)
                .foregroundStyle(Color(red: 247 / 255, green: 247 / 255, blue: 247 / 255))
        }
        .frame(width: 150, height: 150)

        .background(
            ZStack {
                Circle()
                    .fill(Color(red: 19 / 255, green: 21 / 255, blue: 23 / 255))
                
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color(red: 222 / 255, green: 233 / 255, blue: 255 / 255, opacity: 0.1), Color(red: 222 / 255, green: 233 / 255, blue: 255 / 255, opacity: 0.2)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
//                    .background(
//                        Circle()
//                            .fill(Color.white.opacity(0.1))
//                            .blur(radius: 8)
//                    )
            }
        )
        .overlay(
            Circle()
                .stroke(Color.white.opacity(0.25), lineWidth: 2)
                .blur(radius: 0.5)
                .offset(x: 0, y: 1)
                .mask(
                    Circle().fill(LinearGradient(colors: [.black, .clear], startPoint: .top, endPoint: .bottom))
                )
        )

    }
}

struct DeviceGridView: View {
    var body: some View {
        VStack(spacing: 32) {
            // Верхній (центральний) елемент
            DeviceButtonView(imageName: "devices", label: "iPhone")
            
            // Два ряди по 2 елементи
            HStack(spacing: 32) {
                DeviceButtonView(imageName: "airpodsPro", label: "AirPods Pro")
                DeviceButtonView(imageName: "airpods", label: "AirPods")
            }
            HStack(spacing: 32) {
                DeviceButtonView(imageName: "airpodsMax", label: "AirPods Max")
                DeviceButtonView(imageName: "speaker", label: "Speakers")
            }
        }
    }
}
