//
//  MicroView.swift
//  WaterEject
//
//  Created by Ruslan Liulka on 08.08.2025.
//

// MicroView.swift
import SwiftUI

struct MicroView: View {
    @StateObject private var viewModel = MicroViewModel()
    var onContinue: () -> Void

    /// висота шторки як частка висоти екрана
    private let detent: CGFloat = 0.55
    
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

    var body: some View {
        ZStack {
            Background()
            
            // Основний контент
            content


            if viewModel.showSheet {
                Color.black.opacity(0.35)
                    .ignoresSafeArea()
                    .transition(.opacity)
                    .onTapGesture { viewModel.dismissSheetAndReset() }
            }

            // Кастомна нижня шторка + мікрофон поверх
            if viewModel.showSheet {
                GeometryReader { geo in
                    let screenH = geo.size.height
                    let panelH  = screenH * detent - 20
                    let topY    = screenH - panelH      // y верхнього краю панелі
                    let micSize: CGFloat = 140

                    // САМА ПАНЕЛЬ
                    VStack {
                        RecordingSheetView(vm: viewModel) {
                            viewModel.dismissSheetAndReset()
                        }
                    }
                    .frame(width: geo.size.width - 25, height: panelH)
                    .background(
                        RoundedRectangle(cornerRadius: 24)
                            .fill(LinearGradient(colors: [Color(red: 31 / 255, green: 33 / 255, blue: 35 / 255),
                                                          Color(red: 23 / 255, green: 24 / 255, blue: 26 / 255)], startPoint: .topLeading, endPoint: .bottomTrailing))
                            .ignoresSafeArea(edges: .bottom)
                    )
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
                    .transition(.move(edge: .bottom).combined(with: .opacity))

                    // МІКРОФОН НАД КРАЄМ ПАНЕЛІ
                    ZStack {
                        Image("RedMicrophone")

                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                    // ставимо центр кола трохи вище верхнього краю панелі
                    .offset(y: topY - micSize/2)
                    .allowsHitTesting(false)   // кліки йдуть у панель
                }
                //.ignoresSafeArea()
                .animation(.easeOut(duration: 0.25), value: viewModel.showSheet)
            }
        }
        .padding(.horizontal, -12)
    }
    


    // MARK: - Основний контент списку + кнопка
    private var content: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Recordings")
                .font(.system(size: 20, weight: .semibold))
                .foregroundStyle(.white)
                .padding(.horizontal, 24)

            ScrollView {
                LazyVStack(spacing: 12) {
                    ForEach(viewModel.recordings) { rec in
                        RecordingRow(
                            rec: rec,
                            isPlaying: viewModel.currentlyPlaying == rec,
                            onPlayPause: {
                                if viewModel.currentlyPlaying == rec {
                                    viewModel.pausePlayback()
                                    viewModel.currentlyPlaying = nil
                                } else {
                                    viewModel.play(url: rec.url)
                                }
                            },
                            onDelete: { viewModel.deleteRecording(rec) }
                        )
                        .padding(.horizontal, 24)
                    }
                }
                .padding(.top, 6)
            }

            Spacer()
            
            HStack {
                Button {
                    viewModel.openSheetAndStart()
                } label: {
                    Text("Test Microphone")
                        .font(.system(size: 16, weight: .semibold))
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
                        .font(.system(size: 16, weight: .semibold))
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
        .offset(x: (appearScreen ? 0 : 20))
        .animation(.spring(response: 0.55, dampingFraction: 0.85), value: appearScreen)
        .animation(.easeInOut(duration: exitDuration), value: isExiting)
        .onAppear {
            appearScreen = false
            withAnimation(.easeOut(duration: 0.35)) { appearScreen = true }
        }
        .padding(.horizontal, 8)
        .onAppear {
            Task {
                await viewModel.loadRecordings()
                viewModel.canContinue = false    // щоразу дозволяємо зробити 1 новий запис
            }
        }
    }
}

        
        
        
        #Preview {
            MicroView(onContinue: {print("Hello")})
        }
