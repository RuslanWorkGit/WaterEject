//
//  RecordingRow.swift
//  WaterEject
//
//  Created by Ruslan Liulka on 12.08.2025.
//
import SwiftUI


struct RecordingRow: View {
    let rec: Recording
    let isPlaying: Bool
    let onPlayPause: () -> Void
    let onDelete: () -> Void

    @State private var samples: [Float] = []

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // шапка
            HStack {
                Label(rec.title, systemImage: "bolt.horizontal.fill")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(Color(red: 43/255, green: 217/255, blue: 156/255))
                Spacer()
            }

            // Хвиля з файлу
            WaveformView(samples: samples)
                .frame(height: 56)
                .clipped() // обрізає все, що виходить за межі
                .background(.white.opacity(0.03), in: RoundedRectangle(cornerRadius: 10))
            
            Divider().background(.white.opacity(0.08))

            // низ
            HStack {
                Text(durationString(rec.duration))
                    .font(.system(size: 12))
                    .foregroundStyle(.white.opacity(0.75))
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(.white.opacity(0.06), in: Capsule())

                Text(dateString(rec.createdAt))
                    .font(.system(size: 12))
                    .foregroundStyle(.white.opacity(0.75))

                Spacer()

                Button(action: onPlayPause) {
                    Image(systemName: isPlaying ? "pause.fill" : "play.fill")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundStyle(.white)
                        .padding(10)
                        .background(.white.opacity(0.08), in: Circle())
                }

                Button(action: onDelete) {
                    Image(systemName: "trash")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(.white.opacity(0.85))
                        .padding(10)
                        .background(.white.opacity(0.08), in: Circle())
                }
            }
        }
        .padding(16)
        .background(.white.opacity(0.05), in: RoundedRectangle(cornerRadius: 20))
        .onAppear {
            Task {
                    if let saved = WaveformLoader.loadStoredSamples(forAudioURL: rec.url) {
                        samples = saved                   // вже нормалізовано
                    } else {
                        // fallback: побудувати з файлу (20 c ≈ 60 бінів)
                        samples = (try? await WaveformLoader.loadSamples(url: rec.url, targetSamples: 60)) ?? []
                    }
                }
        }
    }

    private func dateString(_ d: Date) -> String {
        let f = DateFormatter()
        f.dateFormat = "M/d/yyyy h:mm a"
        return f.string(from: d)
    }
    private func durationString(_ t: TimeInterval) -> String {
        String(format: "%02d:%02d", Int(t)/60, Int(t)%60)
    }
}





