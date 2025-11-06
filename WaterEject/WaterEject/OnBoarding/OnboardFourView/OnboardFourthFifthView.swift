//
//  OnboardFourthFifthView.swift
//  WaterEject
//
//  Created by Ruslan Liulka on 06.11.2025.
//

import SwiftUI

struct OnboardFourthFifthView: View {
    var body: some View {
        ZStack {
            LinearGradient(gradient: Gradient(stops: [
                            .init(color: Color(red: 255/255, green: 255/255, blue: 255/255).opacity(1), location: 0),
                            .init(color: Color(red: 222/255, green: 233/255, blue: 255/255).opacity(1), location: 0.5),
                            .init(color: Color(red: 255/255, green: 255/255, blue: 255/255).opacity(1), location: 1.0)
                        ]), startPoint: .top, endPoint: .bottom)
                        .ignoresSafeArea()
        }
    }
}

#Preview {
    OnboardFourthFifthView()
}
