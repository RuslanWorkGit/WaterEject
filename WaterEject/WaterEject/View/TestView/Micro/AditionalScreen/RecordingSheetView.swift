//
//  RecordingSheetView.swift
//  WaterEject
//
//  Created by Ruslan Liulka on 12.08.2025.
//

import SwiftUI

struct RecordingSheetView: View {
    @ObservedObject var vm: MicroViewModel
    var onClose: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Spacer()
                Button(action: onClose) {
                    Image(systemName: "xmark")
                        .foregroundStyle(.white.opacity(0.8))
                }
            }

            LiveWaveformView(samples: vm.liveSamples.map(CGFloat.init))
                .padding(.horizontal, 16)
                .clipped()

            Text(vm.isRecording ? timeString(vm.elapsed) + " / 00:20" : "Ready")
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(.white.opacity(0.8))

            if vm.isRecording {
                HStack(spacing: 16) {
                    Button {
                        vm.isPaused ? vm.resumeRecording() : vm.pauseRecording()
                    } label: {
                        Label(vm.isPaused ? "Resume" : "Pause",
                              systemImage: vm.isPaused ? "play.fill" : "pause.fill")
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(RoundedRectangle(cornerRadius: 14).fill(Color.white.opacity(0.08)))
                    }

                    Button(role: .destructive) {
                        vm.stopRecording(save: true)
                    } label: {
                        Label("Stop", systemImage: "stop.fill")
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(RoundedRectangle(cornerRadius: 14).fill(Color.white.opacity(0.08)))
                    }
                }
                .foregroundStyle(.white)
            } else if let url = vm.lastRecordedURL {
                Button { vm.play(url: url) } label: {
                    Label("Play", systemImage: "play.fill")
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(RoundedRectangle(cornerRadius: 14).fill(Color.white.opacity(0.08)))
                        .foregroundStyle(.white)
                }
            }

            Spacer(minLength: 8)
        }
        .padding(16) // НІЯКИХ .presentationDetents — це не системний sheet
    }

    private func timeString(_ t: TimeInterval) -> String {
        let s = Int(t) % 60, m = Int(t) / 60
        return String(format: "%02d:%02d", m, s)
    }
}

#Preview {
    RecordingSheetView(vm: MicroViewModel(), onClose: { print ("Close")})
}
