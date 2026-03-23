import SwiftUI

enum AppTab: Hashable, CaseIterable {
    case home
    case items
    case insights
    case settings

    var title: String {
        switch self {
        case .home: "Home"
        case .items: "Items"
        case .insights: "Insights"
        case .settings: "Settings"
        }
    }

    var symbolName: String {
        switch self {
        case .home: "house.fill"
        case .items: "doc.text.fill"
        case .insights: "chart.bar.xaxis"
        case .settings: "gearshape.fill"
        }
    }
}

struct CustomTabBar: View {
    @Binding var selection: AppTab

    var body: some View {
        HStack {
            ForEach(AppTab.allCases, id: \.self) { tab in
                Button {
                    selection = tab
                } label: {
                    VStack(spacing: 4) {
                        Image(systemName: tab.symbolName)
                            .font(.system(size: 22, weight: selection == tab ? .semibold : .regular))
                        Text(tab.title)
                            .font(.system(size: 10, weight: selection == tab ? .semibold : .regular))
                    }
                    .foregroundStyle(selection == tab ? AppTheme.primary : AppTheme.textMuted)
                    .frame(maxWidth: .infinity)
                    .padding(.top, 10)
                    .padding(.bottom, 8)
                }
                .buttonStyle(.plain)
                .accessibilityIdentifier("tab_\(tab.title.lowercased())")
            }
        }
        .padding(.horizontal, 8)
        .background(.ultraThinMaterial.opacity(0.96))
        .background(AppTheme.elevated.opacity(0.96))
        .overlay(alignment: .top) {
            Rectangle()
                .fill(AppTheme.border)
                .frame(height: 1)
        }
    }
}
