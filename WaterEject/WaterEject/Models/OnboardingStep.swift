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

enum OnboardingStepOne: Int, CaseIterable, Hashable {
    case start
    case wallet
    case women
    case paywall
}

enum OnboardingStepTwo: Int, CaseIterable {
    case start
    case women
    case wallet
    case paywall
}

enum OnboardingStepThree: Int, CaseIterable {
    case device
    case start
    case test
    case women
    case paywall
}

enum OnboardingStepFour: Int, CaseIterable, Hashable {
    case stepOne
    case stepTwo
    case stepThree
    case stepFour
    case stepFive
    case stepSix
    case paywall
}

enum OnboardingStepFive: Int, CaseIterable, Hashable {
    case stepOne
    case paywall
}

enum OnboardingStepSix: Int, CaseIterable, Hashable {
    case stepOne
    case paywall
}

enum OnboardingStepSeven: Int, CaseIterable, Hashable {
    case stepOne
    case stepTwo
    case stepThree
    case stepFour
    case paywall
}

enum OnboardingStepEight: Int, CaseIterable, Hashable {
    case stepOne
    case stepTwo
    case stepThree
    case stepFour
    case paywall
}

enum OnboardingStepNine: Int, CaseIterable, Hashable {
    case stepOne
    case paywall
}

enum OnboardingStepTen: Int, CaseIterable, Hashable {
    case stepOne
    case stepTwo
    case stepThree
    case paywall
}
