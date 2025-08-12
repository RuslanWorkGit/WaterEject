//
//  RecordingModel.swift
//  WaterEject
//
//  Created by Ruslan Liulka on 12.08.2025.
//

import Foundation

struct Recording: Identifiable, Hashable {
    let id = UUID()
    let url: URL
    let duration: TimeInterval
    let createdAt: Date
    let title: String
}
