//
//  OnboardingStep.swift
//  WaterEject
//
//  Created by Ruslan Liulka on 06.08.2025.
//

import Foundation

enum OnboardingStep: Int, CaseIterable {
    case hook
    case urgency
    case solution
    case tests
    case paywall
}

extension OnboardingStep {
    var analyticsValue: String {
        switch self {
        case .hook: "hook"
        case .urgency: "urgency"
        case .solution: "solution"
        case .tests: "tests"
        case .paywall: "paywall"
        }
    }
}
