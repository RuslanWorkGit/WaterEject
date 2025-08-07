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
                case .test:
                    TestView()
                }
            }
        }
    }
}



struct TestView: View {
    var body: some View {
        ZStack {
            Background()
        }
        
    }
}
