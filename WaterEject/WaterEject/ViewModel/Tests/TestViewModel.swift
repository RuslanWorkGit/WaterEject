//
//  TestViewModel.swift
//  WaterEject
//
//  Created by Ruslan Liulka on 08.08.2025.
//


import Foundation
import SwiftUI

final class TestViewModel: ObservableObject {
    @Published var mode: TestMode = .stereo
    @Published var passedCount: Int = 0
    @Published var completedModesTest: Set<TestMode> = []

    func goToNextStep() {
        // позначаємо поточний як завершений і переходимо далі
        markCompletedAndAdvance(finished: mode)
    }

    private func markCompletedAndAdvance(finished: TestMode) {
        withAnimation { completedModesTest.insert(finished) }

        let all = Array(TestMode.allCases)
        guard let i = all.firstIndex(of: finished) else { return }

        // шукаємо перший НЕвиконаний після finished
        if let nextOffset = (1...all.count).first(where: { off in
            let j = (i + off) % all.count
            return !completedModesTest.contains(all[j])
        }) {
            withAnimation { mode = all[(i + nextOffset) % all.count] }
        } else {
            // якщо всі виконані — просто наступний по колу
            withAnimation { mode = all[(i + 1) % all.count] }
        }

        passedCount = completedModesTest.count
    }
}
