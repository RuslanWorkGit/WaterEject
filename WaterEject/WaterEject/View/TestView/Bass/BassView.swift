//
//  BassView.swift
//  WaterEject
//
//  Created by Ruslan Liulka on 08.08.2025.
//

import SwiftUI

struct BassView: View {
    @StateObject private var vm = BassViewModel()
    var onContinue: () -> Void
    
    var body: some View {
        
        VStack(spacing: 24) {
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
            
            HStack(spacing: 56) {
                VStack {
                    Text("55.3")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundStyle(Color(red: 247 / 255, green: 247 / 255, blue: 247 / 255))
                    Text("average")
                        .font(.system(size: 12))
                        .foregroundStyle(Color(red: 196 / 255, green: 196 / 255, blue: 197 / 255))
                }
                VStack {
                    Text("27.8")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundStyle(Color(red: 247 / 255, green: 247 / 255, blue: 247 / 255))
                    Text("min")
                        .font(.system(size: 12))
                        .foregroundStyle(Color(red: 196 / 255, green: 196 / 255, blue: 197 / 255))
                }
                VStack {
                    Text("121.9")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundStyle(Color(red: 247 / 255, green: 247 / 255, blue: 247 / 255))
                    Text("max")
                        .font(.system(size: 12))
                        .foregroundStyle(Color(red: 196 / 255, green: 196 / 255, blue: 197 / 255))
                }
            }
            .offset(y: -40)
            .padding(.bottom, -20)
            
            LazyVGrid(columns: [GridItem(.flexible(), spacing: 16),
                                GridItem(.flexible(), spacing: 16)],
                      spacing: 16) {
                ForEach(vm.clips) { clip in
                    TestClipCard(
                        title: clip.title,
                        isPlaying: vm.isPlaying(clip),
                        isFinished: vm.isFinished(clip),
                        action: { vm.togglePlay(clip) }
                    )
                }
            }
                      .padding(.horizontal, 24)
            
            Spacer(minLength: 8)
            
            Button(action: onContinue) {
                Text("Continue")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(vm.allDone ? Color(red: 81/255, green: 132/255, blue: 234/255) : Color.white.opacity(0.12))
                    )
            }
            .disabled(!vm.allDone)
            .padding(.horizontal, 24)
            .padding(.bottom, 40)
        }
        .onDisappear { vm.stop() }
        
        
    }
    
}

struct TestClipCard: View {
    let title: String
    let isPlaying: Bool
    let isFinished: Bool
    let action: () -> Void
    
    private let shape = RoundedRectangle(cornerRadius: 16, style: .continuous)
    private let base = Color(red: 222/255, green: 233/255, blue: 255/255)
    
    var body: some View {
        Button(action: action) {
            ZStack(alignment: .center) {
                
                if (isPlaying && isFinished) == false {
                    
                    shape.fill(
                        LinearGradient(
                            gradient: Gradient(stops: [
                                .init(color: base.opacity(0.35), location: 0.0),
                                .init(color: base.opacity(1.00), location: 1.0)
                            ]),
                            startPoint: .top, endPoint: .bottom
                        )
                    )
                    .opacity(0.15)
                    
                    
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(Color.white.opacity(0.25), lineWidth: 2)
                        .blur(radius: 0.5)
                        .offset(x: 0, y: 1)
                        .mask(
                            RoundedRectangle(cornerRadius: 14).fill(
                                LinearGradient(colors: [.black, .clear], startPoint: .top, endPoint: .bottom)
                            )
                        )
                    
                }
                
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(
                        isPlaying
                        ? Color(red: 81/255, green: 132/255, blue: 234/255).opacity(0.14)
                        : isFinished
                        ? Color(red: 43/255, green: 217/255, blue: 156/255).opacity(0.14)
                        : Color.clear
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .stroke(
                                isPlaying
                                ? Color.blue.opacity(0.6)
                                : (isFinished
                                   ? Color(red: 43/255, green: 217/255, blue: 156/255)
                                   : Color.white.opacity(0.12)),
                                lineWidth: isPlaying ? 2 : 1
                            )
                    )
            
                
                VStack(spacing: 10) {
                    Image(systemName: isPlaying ? "pause.fill" : "play.fill")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundStyle(
                            isFinished
                            ? Color(red: 43/255, green: 217/255, blue: 156/255)
                            : Color(red: 81/255, green: 132/255, blue: 234/255)
                        )
                    
                    Text(title)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(
                            isFinished ? Color(red: 247/255, green: 247/255, blue: 247/255)
                            : isPlaying ? Color(red: 81/255, green: 132/255, blue: 234/255)
                            : Color(red: 247/255, green: 247/255, blue: 247/255)
                        )
                }
                .padding(18)
            }
            // ВАЖЛИВО: робимо клікабельною всю картку
            .frame(maxWidth: .infinity, minHeight: 84)
            .contentShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            .overlay(alignment: .topTrailing) {
                if isFinished {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(Color(red: 43/255, green: 217/255, blue: 156/255))
                        .padding(8)
                }
            }
            .animation(.easeInOut(duration: 0.2), value: isPlaying)
            
        }
        .buttonStyle(.plain)
        
    }
}


#Preview {
    BassView {
        print("Hello")
    }
}
