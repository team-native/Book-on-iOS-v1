import SwiftUI

/// 로그인 이후 화면 전환을 한곳에서 관리하는 앱의 메인 컨테이너입니다.
public struct AppShellView: View {
    private enum Destination: Identifiable {
        case search
        case notifications
        case notices
        case loanHistory
        case newArrivals
        case bookDetail(Int)
        case passwordReset

        var id: String {
            switch self {
            case .search: return "search"
            case .notifications: return "notifications"
            case .notices: return "notices"
            case .loanHistory: return "loanHistory"
            case .newArrivals: return "newArrivals"
            case let .bookDetail(bookId): return "bookDetail-\(bookId)"
            case .passwordReset: return "passwordReset"
            }
        }
    }

    @State private var selectedTab: BottomTabBar.Item = .home
    @State private var destination: Destination?
    private let onLogout: () -> Void

    public init(onLogout: @escaping () -> Void = {}) {
        self.onLogout = onLogout
    }

    public var body: some View {
        GeometryReader { geometry in
            let scale = geometry.size.width / 392

            ZStack(alignment: .bottom) {
                Group {
                    switch selectedTab {
                    case .home:
                        MainHomeView(
                            onSelectTab: selectTab,
                            onShowSearch: { destination = .search },
                            onShowNotifications: { destination = .notifications },
                            onShowNotices: { destination = .notices },
                            onShowNewArrivals: { destination = .newArrivals },
                            onShowBookDetail: { destination = .bookDetail($0) }
                        )
                    case .ranking:
                        RankingView(onSelectTab: selectTab)
                    case .library:
                        LibraryView(
                            onSelectTab: selectTab,
                            onShowBookDetail: { destination = .bookDetail($0) }
                        )
                    case .my:
                        MyView(
                            onSelectTab: selectTab,
                            onShowPasswordReset: { destination = .passwordReset },
                            onLogout: onLogout
                        )
                    }
                }

                BottomTabBar(selected: selectedTab, scale: scale, action: selectTab)
                    .frame(height: 89 * scale, alignment: .top)
            }
        }
        .ignoresSafeArea()
        .onReceive(NotificationCenter.default.publisher(for: .bookOnPushNotificationRoute)) { notification in
            guard let route = notification.object as? PushNotificationRoute else { return }

            switch route {
            case .loanHistory:
                destination = .loanHistory
            case .notices:
                destination = .notices
            }
        }
        .fullScreenCover(item: $destination) { destination in
            switch destination {
            case .search:
                SearchView(
                    onShowBookDetail: { self.destination = .bookDetail($0) },
                    showsDismissButton: true,
                    onDismiss: dismissDestination
                )
            case .notifications:
                NotificationInboxView(onDismiss: dismissDestination)
            case .notices:
                NoticeListView(onBack: dismissDestination)
            case .loanHistory:
                LoanHistoryView(onBack: dismissDestination)
            case .newArrivals:
                NewArrivalsView(showsDismissButton: true, onDismiss: dismissDestination, onShowBookDetail: { self.destination = .bookDetail($0) })
            case let .bookDetail(bookId):
                BookDetailView(bookId: bookId, onBack: dismissDestination)
            case .passwordReset:
                PasswordResetView(
                    onBack: dismissDestination,
                    onCompleted: dismissDestination
                )
            }
        }
    }

    private func selectTab(_ item: BottomTabBar.Item) {
        guard item != selectedTab else { return }
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
