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
    var onContinue: () -> Void
    
    @State private var isExiting = false
    @State private var appearScreen = false
    private func handleCTA() {
        guard !isExiting else { return }
        withAnimation(.easeOut(duration: 0.25)) { isExiting = true }
//        isExiting = true
        // Після завершення локальної анімації — викликаємо перехід нагору
  
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
            onContinue()
        }
        
    }
    private let exitDuration: Double = 0.35
    
    private var isPad: Bool { UIDevice.current.userInterfaceIdiom == .pad }
    private var padScale: CGFloat { isPad ? 1.3 : 1.0 }
    private var size: CGFloat { isPad ? 40 : 8}
    
    @State private var pendingSelectTest = false
    @EnvironmentObject private var paywallGate: PaywallGate
    
    var body: some View {
        VStack {
            HStack(spacing: size) {
                SpeakerSwitchCard(title: "Left", imageName: "OneSpeaker", isOn: $isLeftOn)
                SpeakerSwitchCard(title: "Right", imageName: "OneSpeaker", isOn: $isRightOn)
            }
            .padding(.top, 10)
            .padding(.horizontal, 24)
            .padding(.bottom, 30)
            
            VolumeSliderView(viewModel: viewModel)
                .padding(.horizontal, 24)
            
            Spacer()
            
            HStack {
                Button {
                    Task {
                        // спочатку пробуємо вимагати Pro / показати paywall
                        let allowed = await paywallGate.requireProOrPresentPaywall(context: .testTab) // або .testTab, якщо маєш такий case
                        if allowed {
                            // вже Pro → просто переходимо на вкладку
                            if viewModel.isPlaying {
                                viewModel.pause()
                            } else {
                                viewModel.playTest(leftOn: isLeftOn, rightOn: isRightOn)
                            }
                        } else {
                            // чекаємо результату paywall
                            pendingSelectTest = true
                        }
                    }

                   
                } label: {
                    Text(viewModel.isPlaying ? "Pause" : "Start Stereo")
                        .font(.system(size: 16 * padScale, weight: .semibold))
                        .foregroundStyle(.white)
                    
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(Color(red: 81 / 255, green: 132 / 255, blue: 234 / 255))
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                }
                
                Button {
                    handleCTA()
                } label: {
                    Text("Continue")
                        .font(.system(size: 16 * padScale, weight: .semibold))
                        .foregroundStyle(Color(red: 255 / 255, green: 255 / 255, blue: 255 / 255))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(Color(red: 222 / 255, green: 233 / 255, blue: 255 / 255).opacity(0.08))
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                }
            }
            .padding(.horizontal, 24)
            .padding(.top, 12)
            .padding(.bottom, 40)
        }
        .opacity(appearScreen && !isExiting ? 1 : 0)
        
        .opacity(isExiting ? 0 : 1)
        .offset(x: isExiting ? -20 : 0)
        .animation(.spring(response: 0.55, dampingFraction: 0.85), value: appearScreen)
        .animation(.easeInOut(duration: exitDuration), value: isExiting)
        .onAppear {
            appearScreen = false
            withAnimation(.easeOut(duration: 0.35)) { appearScreen = true }
        }
        
        .onChange(of: isLeftOn) { _, _ in
            viewModel.updateRouting(leftOn: isLeftOn, rightOn: isRightOn)
        }
        .onChange(of: isRightOn) { _, _ in
            viewModel.updateRouting(leftOn: isLeftOn, rightOn: isRightOn)
        }
        .onDisappear { viewModel.stop() }
        .fullScreenCover(item: $paywallGate.presentedVariant, onDismiss: {
            Task {
                let isPro = await paywallGate.isPro()
                if isPro && pendingSelectTest {
                    if viewModel.isPlaying {
                        viewModel.pause()
                    } else {
                        viewModel.playTest(leftOn: isLeftOn, rightOn: isRightOn)
                    }
                }
                pendingSelectTest = false
                paywallGate.dismissPaywall()
            }
        }) { variant in
            switch variant {
            case .third:
                PaywallThirdView(onFinish: {
                    paywallGate.dismissPaywall()
                })
            case .fourth:
                PaywallFourView(onFinish: {
                    paywallGate.dismissPaywall()
                })
            case .fifth:
                PaywallFiveView(onFinish: {
                    paywallGate.dismissPaywall()
                })
            }
        }
    }
}

struct SpeakerSwitchCard: View {
    let title: String
    let imageName: String
    @Binding var isOn: Bool
    
    private var isPad: Bool { UIDevice.current.userInterfaceIdiom == .pad }
    private var padScale: CGFloat { isPad ? 1.3 : 1.0 }
    private var sizeVertical: CGFloat { isPad ? 32 : 18}
    
    var body: some View {
        Button(action: {
            isOn.toggle()
        }) {
            VStack(spacing: sizeVertical) {
                Text(title)
                    .font(.system(size: 20 * padScale, weight: .medium))
                    .foregroundColor(Color.white.opacity(0.7))
                Image(imageName)
                    .scaleEffect(padScale)
                
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
    
    private var isPad: Bool { UIDevice.current.userInterfaceIdiom == .pad }
    private var padScale: CGFloat { isPad ? 1.3 : 1.0 }
    
    var body: some View {
        VStack {
            HStack(alignment: .center) {
                Text("Volume")
                    .foregroundColor(.white)
                    .font(.system(size: 17 * padScale))
                
                Spacer()
                
                Text("\(Int(viewModel.volume * 100))%")
                    .font(.system(size: 17 * padScale, weight: .semibold))
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
    StereoView {
        print("hello")
    }
}
