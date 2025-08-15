//
//  TabBarView.swift
//  WaterEject
//
//  Created by Ruslan Liulka on 07.08.2025.
//

import SwiftUI

final class TabBarState: ObservableObject {
    @Published var isHidden: Bool = false
}

struct TabBarView: View {
    @State private var selectedTab: TabBarTab = .home
    @StateObject private var tabBarState = TabBarState()

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
        .environmentObject(tabBarState)
    }
}



