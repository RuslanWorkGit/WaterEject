//
//  StereoView.swift
//  WaterEject
//
//  Created by Ruslan Liulka on 08.08.2025.
//

import SwiftUI

struct StereoView: View {
    @StateObject var viewModel = StereoViewModel()
    @State private var isLeftOn = false
    @State private var isRightOn = true
    
    var body: some View {
        VStack {
            HStack(spacing: 8) {
                SpeakerSwitchCard(title: "Left", imageName: "OneSpeaker", isOn: $isLeftOn)
                SpeakerSwitchCard(title: "Right", imageName: "OneSpeaker", isOn: $isRightOn)
            }
            .padding(.top, 10)
            .padding(.horizontal, 24)
            .padding(.bottom, 30)
            
            VolumeSliderView(viewModel: viewModel)
                .padding(.horizontal, 24)
        }
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
                    .tint(Color.blue)
                    .scaleEffect(1.2)
                    .padding(.top, 10)
            }

            
            .background(Color.clear) // якщо треба тінь або фон, можна додати тут
            .contentShape(Rectangle()) // Щоб область натискання була на всю картку
        }
        .buttonStyle(.plain) // Щоб не було анімації кнопки
        
    }
}

struct VolumeSliderView: View {
    @ObservedObject var viewModel: StereoViewModel
    
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
    StereoView()
}
