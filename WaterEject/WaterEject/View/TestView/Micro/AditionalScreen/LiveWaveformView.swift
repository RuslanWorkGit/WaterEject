
//
//  Untitled.swift
//  WaterEject
//
//  Created by Ruslan Liulka on 12.08.2025.
//
import SwiftUI

// LiveWaveformView.swift
import SwiftUI

struct LiveWaveformView: View {
    let samples: [CGFloat]          // 0...1
    var barCount: Int = 90          // скільки паличок малюємо (обрізаємо/даунсемплимо)
    var thickness: CGFloat = 2      // ← зроби палички ВУЖЧИМИ (наприклад, 1–2)
    var spacing: CGFloat = 2       // ← відступ між паличками
    var cornerRadius: CGFloat = 1

    var body: some View {
        GeometryReader { geo in
            let n = min(barCount, samples.count)
            let totalDesired = thickness * CGFloat(n) + spacing * CGFloat(max(0, n - 1))
            // Якщо задані розміри виходять за рамку — масштабуємо рівномірно
            let scale = min(1, geo.size.width / max(1, totalDesired))
            let w = thickness * scale
            let s = spacing * scale

            HStack(alignment: .center, spacing: s) {
                ForEach(0..<n, id: \.self) { i in
                    let v = max(0, min(1, samples[i]))
                    let h = max(2, v * geo.size.height)
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .frame(width: w, height: h)
                        .foregroundStyle(Color(red: 248/255, green: 97/255, blue: 97/255))
                        .opacity(0.95)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        }
    }
}

struct WaveformView: View {
    /// Нормалізовані значення 0...1
    let samples: [Float]

    /// Бажана товщина палички (у пойнтах)
    var barWidth: CGFloat = 1       // ← зроби 1 або навіть 0.8
    /// Бажаний відступ між паличками
    var barSpacing: CGFloat = 1.5     // ← невеликий відступ
    var cornerRadius: CGFloat = 1.5
    var color: Color = Color(red: 161/255, green: 192/255, blue: 255/255)
    /// За потреби можна обмежити кількість стовпчиків (наприклад, до 60)
    var maxBars: Int? = nil

    var body: some View {
        GeometryReader { geo in
            // Підготуємо значення та (опційно) обріжемо кількість барів
            let vals: [CGFloat] = {
                let src = maxBars.map { Array(samples.prefix($0)) } ?? samples
                return src.map { CGFloat(max(0, min(1, $0))) }
            }()
            let n = max(vals.count, 1)

            // Бажана загальна ширина з урахуванням відступів
            let desiredTotal = barWidth * CGFloat(n) + barSpacing * CGFloat(max(0, n - 1))
            // Масштаб, щоб уміститись у доступну ширину
            let scale = min(1, geo.size.width / desiredTotal)

            let w = max(0.5, barWidth * scale)   // мінімальна товщина 0.5pt
            let s = barSpacing * scale

            HStack(alignment: .center, spacing: s) {
                ForEach(vals.indices, id: \.self) { i in
                    let h = max(2, vals[i] * geo.size.height)
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .frame(width: w, height: h)
                        .foregroundStyle(color)
                        .opacity(0.95)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        }
    }
}

