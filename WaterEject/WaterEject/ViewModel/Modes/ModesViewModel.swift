//
//  ModesViewModel.swift
//  WaterEject
//
//  Created by Ruslan Liulka on 13.08.2025.
//

import RevenueCat
import Foundation

final class ModesViewModel: ObservableObject {
    // інші твої властивості і методи

    func shouldShowPaywall() async -> Bool {
        do {
            let info = try await Purchases.shared.customerInfo()
            // 👉 заміни "pro" на свій entitlement id з RevenueCat
            return info.entitlements.active["pro_user"] == nil
        } catch {
            return true // якщо не змогли дістати — краще показати пейвол
        }
    }
}
