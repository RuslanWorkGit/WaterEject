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

    var body: some View {
        ZStack {
            Background()
            
            // Основний контент
            content


            if viewModel.showSheet {
                Color.black.opacity(0.35)
                    .ignoresSafeArea()
                    .transition(.opacity)
                    .onTapGesture { viewModel.closeSheet() }
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
                            viewModel.closeSheet()
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

            Button {
                if viewModel.canContinue {
                    onContinue()
                } else {
                    viewModel.openSheetAndStart()
                }
            } label: {
                Text(viewModel.canContinue ? "Continue" : "Start Test")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(viewModel.canContinue
                                  ? Color(red: 81/255, green: 132/255, blue: 234/255)
                                  : Color.white.opacity(0.12))
                    )
            }
            .disabled(viewModel.isRecording)
            .padding(.horizontal, 24)
            .padding(.bottom, 40)
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
