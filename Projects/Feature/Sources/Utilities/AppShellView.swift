import SwiftUI

/// 로그인 이후 화면 전환을 한곳에서 관리하는 앱의 메인 컨테이너입니다.
public struct AppShellView: View {
    private enum Destination: String, Identifiable {
        case search
        case notifications
        case newArrivals
        case bookDetail

        var id: String { rawValue }
    }

    @State private var selectedTab: BottomTabBar.Item = .home
    @State private var destination: Destination?

    public init() {}

    public var body: some View {
        Group {
            switch selectedTab {
            case .home:
                MainHomeView(
                    onSelectTab: selectTab,
                    onShowSearch: { destination = .search },
                    onShowNotifications: { destination = .notifications },
                    onShowNewArrivals: { destination = .newArrivals },
                    onShowBookDetail: { destination = .bookDetail }
                )
            case .ranking:
                RankingView(onSelectTab: selectTab)
            case .library:
                LibraryView(
                    onSelectTab: selectTab,
                    onShowBookDetail: { destination = .bookDetail }
                )
            case .my:
                MyView(onSelectTab: selectTab)
            }
        }
        .fullScreenCover(item: $destination) { destination in
            switch destination {
            case .search:
                SearchView(
                    onShowBookDetail: { self.destination = .bookDetail },
                    showsDismissButton: true,
                    onDismiss: dismissDestination
                )
            case .notifications:
                NotificationInboxView(onDismiss: dismissDestination)
            case .newArrivals:
                NewArrivalsView(showsDismissButton: true, onDismiss: dismissDestination)
            case .bookDetail:
                BookDetailView(onBack: dismissDestination)
            }
        }
    }

    private func selectTab(_ item: BottomTabBar.Item) {
        selectedTab = item
    }

    private func dismissDestination() {
        destination = nil
    }
}

struct AppShellView_Previews: PreviewProvider {
    static var previews: some View {
        AppShellView().previewDevice("iPhone 16")
    }
}
