//
//  TestView.swift
//  WaterEject
//
//  Created by Ruslan Liulka on 08.08.2025.
//

import SwiftUI

struct TestView: View {
    
    @StateObject var viewModel = TestViewModel()
    @State private var isLeftOn = false
    @State private var isRightOn = true
    
    var body: some View {
        ZStack {
            Background()
            VStack {
                
                HStack {
                    
                    Text("Audio Tests")
                        .foregroundStyle(Color(red: 247 / 255, green: 247 / 255, blue: 247 / 255))
                        .font(.system(size: 20, weight: .semibold))
                    
                    Spacer()
                    
                    Text("0/5 passed")
                        .foregroundStyle(Color(red: 196 / 255, green: 196 / 255, blue: 197 / 255))
                        .font(.system(size: 12))
                        .padding(5)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.white.opacity(0.05))
                        )
                    
                    
                }
                .padding(.horizontal, 24)
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        
                        ForEach(TestMode.allCases) { mode in
                            FeatureCard(iconName: mode.imageName, label: mode.testName)
                        }
                        
                    }
                    .padding(.horizontal, 10)
                }
                .frame(height: 140)
                .padding(.leading, 8)
                .padding(.top, -10)
                
                HStack(spacing: 8) {
                    SpeakerSwitchCard(title: "Left", imageName: "OneSpeaker", isOn: $isLeftOn)
                    SpeakerSwitchCard(title: "Right", imageName: "OneSpeaker", isOn: $isRightOn)
                }
                .padding(.top, 10)
                .padding(.horizontal, 24)
                .padding(.bottom, 30)
                
                VolumeSliderView(viewModel: viewModel)
                
                
                Spacer()
            }
            .background(Color.clear)
            
        }

        
    }
}



struct FeatureCard: View {
    let iconName: String
    let label: String
    
    var body: some View {
        VStack(spacing: 8) {
            Image(iconName)
            
            Text(label)
                .font(.system(size: 15))
                .foregroundStyle(Color(red: 179 / 255, green: 179 / 255, blue: 179 / 255))
        }
        .frame(width: 96, height: 72)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.03))
        )
    }
}

struct SpeakerSwitchCard: View {
    let title: String
    let imageName: String
    @Binding var isOn: Bool
    
    var body: some View {
        Button(action: {
            isOn.toggle()
        }) {
            VStack(spacing: 18) {
                Text(title)
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(Color.white.opacity(0.7))
                Image(imageName)
                
                Toggle("", isOn: $isOn)
                    .labelsHidden()
                    .toggleStyle(SwitchToggleStyle(tint: .green))
                    .scaleEffect(1.2)
                    .padding(.top, 10)
            }
            //.frame(width: 220)
            //.padding(.vertical, 8)
            
            .background(Color.clear) // якщо треба тінь або фон, можна додати тут
            .contentShape(Rectangle()) // Щоб область натискання була на всю картку
        }
        .buttonStyle(.plain) // Щоб не було анімації кнопки
        
    }
}

struct VolumeSliderView: View {
    @ObservedObject var viewModel: TestViewModel
    
    var body: some View {
        VStack {
            HStack(alignment: .center) {
                Text("Volume")
                    .foregroundColor(.white)
                    .font(.system(size: 17))
                
                Spacer()
                
                Text("\(Int(viewModel.volume * 100))%")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 2)
                    .background(Color.white.opacity(0.13))
                    .clipShape(Capsule())
            }
            .padding(.horizontal, 24)
        }
        //        Slider(
        //            value: $viewModel.volume,
        //            in: 0...1,
        //            step: 0.01
        //        )
        //        .accentColor(Color(red: 105/255, green: 150/255, blue: 255/255))
        //        .frame(height: 20)
        //        .padding(.horizontal, 24)
        
        VStack(spacing: 24) {
            Slider(value: $viewModel.volume, in: 0...1)
                .accentColor(.blue)
            // Вставляємо невидимий SystemVolumeSlider (саме він керує системною гучністю)
            SystemVolumeSlider(volume: $viewModel.volume)
                .frame(width: 0, height: 0) // непомітний
        }
        .onAppear {
            try? AVAudioSession.sharedInstance().setActive(true)
        }
        
        
    }
}

import SwiftUI
import MediaPlayer

struct SystemVolumeSlider: UIViewRepresentable {
    @Binding var volume: Float
    
    private let volumeView = MPVolumeView(frame: .zero)
    
    func makeUIView(context: Context) -> MPVolumeView {
        volumeView.showsVolumeSlider = false // Слайдер не видно
        volumeView.alpha = 0.01 // Робимо непомітним
        return volumeView
    }
    
    func updateUIView(_ uiView: MPVolumeView, context: Context) {
        setSystemVolume(volume)
    }
    
    private func setSystemVolume(_ value: Float) {
        // Знаходимо слайдер і рухаємо його thumb
        guard let slider = volumeView.subviews.compactMap({ $0 as? UISlider }).first else { return }
        DispatchQueue.main.async {
            slider.value = value
        }
    }
}



#Preview {
    TestView()
}
