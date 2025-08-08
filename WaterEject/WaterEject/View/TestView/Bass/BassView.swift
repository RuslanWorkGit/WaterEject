//
//  BassView.swift
//  WaterEject
//
//  Created by Ruslan Liulka on 08.08.2025.
//

import SwiftUI

struct BassView: View {
    var body: some View {
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
    }
}

#Preview {
    BassView()
}
