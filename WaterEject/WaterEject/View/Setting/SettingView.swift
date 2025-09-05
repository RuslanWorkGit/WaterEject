//
//  SettingView.swift
//  WaterEject
//
//  Created by Ruslan Liulka on 05.09.2025.
//

import SwiftUI

struct SettingView: View {
    var body: some View {
        NavigationStack {
            ZStack {
                
                Background()
                
                VStack(spacing: 28) {
                    HStack {
                        Text("Settig")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(.white)
                        Spacer()
                    }
                  
                    
                }
            }
        }
    }
}

#Preview {
    SettingView()
}
