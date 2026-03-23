import SwiftUI
import SwiftData

struct RecurringItemsListView: View {
    let title: String
    let items: [TrackedItem]

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 16) {
                if items.isEmpty {
                    EmptyStateView(
                        systemImage: "repeat",
                        title: "No Items",
                        message: "There are no items matching this filter."
                    )
                    .padding(.top, 36)
                } else {
                    LazyVStack(spacing: 12) {
                        ForEach(items, id: \.id) { item in
                            NavigationLink {
                                ItemDetailView(item: item)
                            } label: {
                                ItemCardView(item: item)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 16)
            .padding(.bottom, 120)
        }
        .background(AppTheme.background.ignoresSafeArea())
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
    }
}
