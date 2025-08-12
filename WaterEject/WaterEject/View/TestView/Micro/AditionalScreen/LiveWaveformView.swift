
//
//  Untitled.swift
//  WaterEject
//
//  Created by Ruslan Liulka on 12.08.2025.
//
import SwiftUI

struct LiveWaveformView: View {
    let samples: [CGFloat] // 0...1

    var body: some View {
        GeometryReader { geo in
            let barW = max(2, geo.size.width / 60)
            HStack(alignment: .center, spacing: barW * 0.4) {
                ForEach(samples.indices, id: \.self) { i in
                    let h = max(2, samples[i] * geo.size.height)
                    RoundedRectangle(cornerRadius: 2)
                        .fill(Color.red.opacity(0.9))
                        .frame(width: barW, height: h)
                        .frame(height: geo.size.height, alignment: .center)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        }
        .frame(height: 68)
    }
}


import SwiftUI

struct WaveformView: View {
    /// Нормалізовані значення 0...1
    let samples: [Float]
    var barWidth: CGFloat = 3
    var barSpacing: CGFloat = 2
    var cornerRadius: CGFloat = 1.5

    var body: some View {
        GeometryReader { geo in
            let barW = max(2, geo.size.width / CGFloat(samples.count))
            HStack(alignment: .center, spacing: barSpacing) {
                ForEach(Array(samples.enumerated()), id: \.offset) { _, value in
                    let h = max(2, CGFloat(value) * geo.size.height)
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .frame(width: barW, height: h)
                        .foregroundStyle(Color(red: 81/255, green: 132/255, blue: 234/255))
                        .opacity(0.95)
                }
            }
        }
    }
}


