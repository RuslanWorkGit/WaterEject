//
//  ReviewSheet.swift
//  WaterEject
//
//  Created by Ruslan Liulka on 17.12.2025.
//

import SwiftUI

struct ReviewInitialLikeSheet: View {
    let onLike: () -> Void
    let onDislike: () -> Void
    let onLater: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            Text("Did the cleaning help?")
                .font(.headline)

            HStack(spacing: 12) {
                
                Button {
                    onLike()
                } label: {
                    Text("👍 Yes")
                        .padding(8)
                }
                .buttonStyle(.borderedProminent)

               
                Button {
                    onDislike()
                } label: {
                    Text("👎 No")
                        .padding(8)
                }
                .buttonStyle(.bordered)


            }

            Button("Later") { onLater() }
                .foregroundStyle(.secondary)
        }
        .padding()
        .presentationDetents([.height(220)])
    }
}

struct ReviewStarsSheet: View {
    let onSelect: (Int) -> Void
    let onLater: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            Text("Rate WaterEject")
                .font(.headline)

            HStack(spacing: 10) {
                ForEach(1...5, id: \.self) { star in
                    Button {
                        onSelect(star)
                    } label: {
                        Image(systemName: "star.fill")
                            .font(.system(size: 28))
                    }
                }
            }

            Button("Later") { onLater() }
                .foregroundStyle(.secondary)
        }
        .padding()
        .presentationDetents([.height(220)])
    }
}

struct ReviewFeedbackSheet: View {
    let stars: Int?
    let onSubmit: (String) -> Void
    let onCancel: () -> Void

    @State private var text: String = ""

    var body: some View {
        VStack(spacing: 12) {
            Text(stars == nil ? "What didn’t you like?" : "How can we improve?")
                .font(.headline)

            TextEditor(text: $text)
                .frame(height: 120)
                .overlay(RoundedRectangle(cornerRadius: 12).stroke(.gray.opacity(0.2)))

            HStack {
                Button("Cancel") { onCancel() }
                Spacer()
                Button("Send") { onSubmit(text) }
                    .disabled(text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
            .padding(.horizontal, 16)
        }
        .padding()
        .presentationDetents([.medium])
    }
}

#Preview {
//    ReviewStarsSheet { new in
//        
//    } onLater: {
//        
//    }
    
    ReviewFeedbackSheet(stars: 1, onSubmit: { New in
        
    }, onCancel: {
        
    })

}
