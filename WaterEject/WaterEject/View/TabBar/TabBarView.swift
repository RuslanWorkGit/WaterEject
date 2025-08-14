//
//  TabBarView.swift
//  WaterEject
//
//  Created by Ruslan Liulka on 07.08.2025.
//

import SwiftUI

struct TabBarView: View {
    @State private var selectedTab: TabBarTab = .home

    var body: some View {
        CustomTabBarContainerView(selectedTab: $selectedTab) {
            Group {
                switch selectedTab {
                case .home:
                    HomeView()
                        .environmentObject(PaywallGate.shared)
                case .test:
                    TestView {
                        selectedTab = .home
                    }
                }
            }
        }
    }
}



