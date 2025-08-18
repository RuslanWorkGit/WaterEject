//
//  CustomTabBar.swift
//  WaterEject
//
//  Created by Ruslan Liulka on 07.08.2025.
//

import SwiftUI

struct CustomTabBarContainerView<Content: View>: View {
    @Binding var selectedTab: TabBarTab
    @EnvironmentObject private var tabBarState: TabBarState   // ⟵ додали
    let content: Content

    init(selectedTab: Binding<TabBarTab>, @ViewBuilder content: () -> Content) {
        self._selectedTab = selectedTab
        self.content = content()
    }

    private var shouldHide: Bool {
        tabBarState.isHidden || selectedTab == .test            // ⟵ можна лишити/прибрати .test
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            content
                .frame(maxWidth: .infinity, maxHeight: .infinity)

            CustomTabBar(selectedTab: $selectedTab)
                .offset(y: shouldHide ? 120 : 0)                 // ⟵ ховаємо вниз
                .opacity(shouldHide ? 0 : 1)
                .animation(.easeInOut(duration: 0.25), value: shouldHide)
        }
        .edgesIgnoringSafeArea(.bottom)
    }
}


enum TabBarTab {
    case home
    case test
}

struct CustomTabBar: View {
    @Binding var selectedTab: TabBarTab

    var body: some View {
        HStack {
            TabBarButton(
                icon: "house", // Свою SFSymbol або кастомну іконку
                label: "Home",
                isSelected: selectedTab == .home
            ) {
                selectedTab = .home
            }

            Spacer()

            TabBarButton(
                icon: "gauge.open.with.lines.needle.33percent", // Для Test
                label: "Test",
                isSelected: selectedTab == .test
            ) {
                selectedTab = .test
            }
        }
        .padding(.horizontal, 32)
        .padding(.top, 10)
        .padding(.bottom, 28) // для імітації safe area
        .background(
            Color(red: 35/255, green: 37/255, blue: 41/255)
                .ignoresSafeArea(.container, edges: .bottom)
        )
    }
}

struct TabBarButton: View {
    let icon: String
    let label: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 22, weight: .medium))
                    .foregroundColor(isSelected ? Color(red: 161/255, green: 192/255, blue: 255/255) : .gray)
                Text(label)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(isSelected ? Color(red: 161/255, green: 192/255, blue: 255/255) : .gray)
            }
            .padding(.horizontal, 50)
            .padding(.vertical, 10)
            .background(
                isSelected ? Color(red: 31/255, green: 42/255, blue: 66/255).opacity(0.45) : .clear
            )
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .contentShape(Rectangle())
        }
        
        .buttonStyle(.plain)
    }
}
