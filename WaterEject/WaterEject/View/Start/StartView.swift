//
//  StartView.swift
//  WaterEject
//
//  Created by Ruslan Liulka on 01.08.2025.
//

import SwiftUI

struct StartView: View {
    
    @Environment(\.dismiss) private var dismiss
    @State private var selectedDevice: String?
    let device: String
    let mode: String
    
    var body: some View {
        ZStack {
            Background()
            
            VStack(spacing: 28) {
                HStack {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "chevron.backward")
                        Text("Back")
                            .font(.system(size: 17))
                    }
                    
                    Spacer()
                    
                    Text(device)
                        .font(.system(size: 28, weight: .bold))
                        .foregroundStyle(.white)
                    
                    
                    Spacer()
                    
                }
                .padding(.horizontal, 24)
                .padding(.top, 16)
                
                SelectedModeCard(
                    deviceIcon: "devices",    // або інше ім'я картинки
                    title: mode,
                    onSettings: {
                        print("Settings tapped")
                        
                    }
                )
                .padding(.horizontal, 24)
                
                
                
                Image("devices")
                    .resizable()
                    .frame(width: 201, height: 256)
                    .padding(.top, 75)
                
                Spacer()
                
            }
        }

        
    }
}



struct SelectedModeCard: View {
    let deviceIcon: String      // ім'я зображення для іконки пристрою
    let title: String           // довга назва режиму
    let onSettings: () -> Void  // дія на натискання шестерні
    
    var body: some View {
        HStack(spacing: 14) {
            // Іконка пристрою
            Image(deviceIcon)
                .resizable()
                .scaledToFit()
                .frame(width: 36, height: 36)
            
                .padding(.leading, 4)
            
            VStack(alignment: .leading, spacing: 2) {
                Text("Selected mode:")
                    .font(.system(size: 13, weight: .regular))
                    .foregroundStyle(.white.opacity(0.6))
                Text(title)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(.white)
                    .lineLimit(1)
                    .truncationMode(.tail)
            }
            .padding(.vertical, 8)
            
            Spacer()
            
            // Кнопка-іконка
            Button(action: onSettings) {
                Image(systemName: "gearshape")
                    .font(.system(size: 26))
                    .foregroundStyle(.white.opacity(0.45))
                    .padding(2)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 18)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.05))
        )
        
        
        //.padding(.top, 10)
    }
    
}


#Preview {
    StartView(device: "Iphone", mode: "Some Mode")
}
