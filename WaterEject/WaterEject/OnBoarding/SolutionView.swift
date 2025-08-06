//
//  SolutionView.swift
//  WaterEject
//
//  Created by Ruslan Liulka on 06.08.2025.
//

import SwiftUI

struct SolutionView: View {
    var body: some View {
        ZStack {
            Background(startCleaning: true)
            
            VStack(alignment: .center) {
                (
                    Text("Use Safe Sound Frequencies to")
                        .foregroundStyle(Color(red: 238 / 255, green: 255 / 255, blue: 236 / 255)) +
                    Text(" Push Water Out")
                        .foregroundStyle(Color(red: 43 / 255, green: 217 / 255, blue: 156 / 255))
      
                )
                .font(.system(size: 32, weight: .bold))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 24)
                .padding(.bottom, 54)
                

                ZStack(alignment: .trailing) {
                    Image("devicesBig")
                    Image("Aprove")
                        .offset(x: 52)
                        
                }
                
                
            }
            .frame(maxHeight: .infinity, alignment: .top)
            .padding(.horizontal, 12)
            .padding(.top, 50)
            
        }

    }
}

#Preview {
    SolutionView()
}
