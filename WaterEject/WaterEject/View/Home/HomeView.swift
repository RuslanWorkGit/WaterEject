//
//  HomeView.swift
//  WaterEject
//
//  Created by Ruslan Liulka on 01.08.2025.
//

import SwiftUI

struct HomeView: View {
    //@State private var showModesScreen = false
    @State private var selectedDevice: String?
    
    var body: some View {
        ZStack {
            
            Background()
            
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
                
                DeviceGridView { device in
                    selectedDevice = device
                    //showModesScreen = true
                }
                
                Spacer()

            }
        }
        .fullScreenCover(item: $selectedDevice, content: { device in
            ModesView(device: device)
        })

    }
}

#Preview {
    HomeView()
}

import SwiftUI

struct DeviceButtonView: View {
    let imageName: String
    let label: String
    let action: (String) -> Void
    
    var body: some View {
        Button(action: { action(label) }) {
            ZStack {
                // Фон та overlay — ВСЕРЕДИНІ Button!
                Circle()
                    .fill(Color(red: 19 / 255, green: 21 / 255, blue: 23 / 255))
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(red: 222 / 255, green: 233 / 255, blue: 255 / 255, opacity: 0.1),
                                Color(red: 222 / 255, green: 233 / 255, blue: 255 / 255, opacity: 0.2)
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                Circle()
                    .stroke(Color.white.opacity(0.25), lineWidth: 2)
                    .blur(radius: 0.5)
                    .offset(x: 0, y: 1)
                    .mask(
                        Circle().fill(
                            LinearGradient(colors: [.black, .clear], startPoint: .top, endPoint: .bottom)
                        )
                    )
                
                VStack(spacing: 12) {
                    Image(imageName)
                        .foregroundStyle(.white)
                    Text(label)
                        .font(.headline)
                        .foregroundStyle(Color(red: 247 / 255, green: 247 / 255, blue: 247 / 255))
                }
            }
            .frame(width: 150, height: 150)
        }
        .buttonStyle(.plain) // Щоб не було сірого ефекту system button
    }
}

struct DeviceGridView: View {
    let onDeviceTap: (String) -> Void
    
    var body: some View {
        VStack(spacing: 32) {
            // Верхній (центральний) елемент
            DeviceButtonView(imageName: "devices", label: "iPhone", action: onDeviceTap)
            
            // Два ряди по 2 елементи
            HStack(spacing: 32) {
                DeviceButtonView(imageName: "airpodsPro", label: "AirPods Pro", action: onDeviceTap)
                DeviceButtonView(imageName: "airpods", label: "AirPods", action: onDeviceTap)
            }
            HStack(spacing: 32) {
                DeviceButtonView(imageName: "airpodsMax", label: "AirPods Max", action: onDeviceTap)
                DeviceButtonView(imageName: "speaker", label: "Speakers", action: onDeviceTap)
            }
        }


    }
}

extension String: Identifiable {
    public var id: String { self }
}
