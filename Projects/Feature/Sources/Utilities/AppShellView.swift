import SwiftUI

/// 로그인 이후 화면 전환과 back stack을 한곳에서 관리하는 앱의 메인 컨테이너입니다.
public struct AppShellView: View {
    private enum Route: Hashable {
        case search
        case notifications
        case notices
        case loanHistory
        case favorites
        case usageGuide
        case passwordReset
        case newArrivals
        case recommendations
        case bookDetail(Int)

        var usesSystemBackButton: Bool {
            switch self {
            case .recommendations:
                return true
            default:
                return false
            }
        }
    }

    @State private var selectedTab: BottomTabBar.Item = .home
    @State private var navigationPath: [Route] = []
    private let onLogout: () -> Void

    public init(onLogout: @escaping () -> Void = {}) {
        self.onLogout = onLogout
    }

    public var body: some View {
        NavigationStack(path: $navigationPath) {
            GeometryReader { geometry in
                let scale = geometry.size.width / 392

                Group {
                    switch selectedTab {
                    case .home:
                        MainHomeView(
                            onSelectTab: selectTab,
                            onShowSearch: { push(.search) },
                            onShowNotifications: { push(.notifications) },
                            onShowNotices: { push(.notices) },
                            onShowRecommendations: { push(.recommendations) },
                            onShowBookDetail: showBookDetail
                        )
                    case .ranking:
                        RankingView(onSelectTab: selectTab)
                    case .library:
                        LibraryView(
                            onSelectTab: selectTab,
                            onShowBookDetail: showBookDetail
                        )
                    case .my:
                        MyView(
                            onSelectTab: selectTab,
                            onShowPasswordReset: { push(.passwordReset) },
                            onLogout: onLogout,
                            onShowLoanHistory: { push(.loanHistory) },
                            onShowFavorites: { push(.favorites) },
                            onShowUsageGuide: { push(.usageGuide) }
                        )
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .safeAreaInset(edge: .bottom, spacing: 0) {
                    BottomTabBar(selected: selectedTab, scale: scale, action: selectTab)
                        .frame(maxWidth: .infinity)
                        .background(Color.white.ignoresSafeArea(edges: .bottom))
                }
            }
            .navigationDestination(for: Route.self) { route in
                destinationView(for: route)
                    .toolbar(route.usesSystemBackButton ? .visible : .hidden, for: .navigationBar)
                    .navigationBarBackButtonHidden(!route.usesSystemBackButton)
            }
            .toolbar(.hidden, for: .navigationBar)
        }
        .background(Color.white.ignoresSafeArea())
        .onReceive(NotificationCenter.default.publisher(for: .bookOnPushNotificationRoute)) { notification in
            guard let route = notification.object as? PushNotificationRoute else { return }
            navigationPath = [appRoute(for: route)]
        }
    }

    @ViewBuilder
    private func destinationView(for route: Route) -> some View {
        switch route {
        case .search:
            SearchView(
                onShowBookDetail: showBookDetail,
                showsDismissButton: true,
                onDismiss: popRoute
            )
        case .notifications:
            NotificationInboxView(
                onDismiss: popRoute,
                onSelectRoute: { navigationPath.append(appRoute(for: $0)) }
            )
        case .notices:
            NoticeListView(onBack: popRoute)
        case .loanHistory:
            LoanHistoryView(onBack: popRoute)
        case .favorites:
            FavoritesView(onBack: popRoute, onShowBookDetail: showBookDetail)
        case .usageGuide:
            UsageGuideView(onBack: popRoute)
        case .passwordReset:
            PasswordResetView(
                onBack: popRoute,
                onCompleted: popRoute,
                exitsToPreviousScreenOnBack: true
            )
        case .newArrivals:
            NewArrivalsView(
                showsDismissButton: true,
                onDismiss: popRoute,
                onShowBookDetail: showBookDetail
            )
        case .recommendations:
            TodayRecommendationsView(onShowBookDetail: showBookDetail)
        case let .bookDetail(bookId):
            BookDetailView(bookId: bookId, onBack: popRoute)
        }
    }

    private func selectTab(_ item: BottomTabBar.Item) {
        guard item != selectedTab else { return }
        selectedTab = item
    }

    private func push(_ route: Route) {
        navigationPath.append(route)
    }

    private func popRoute() {
        guard !navigationPath.isEmpty else { return }
        navigationPath.removeLast()
    }

    private func showBookDetail(_ bookId: Int) {
        push(.bookDetail(bookId))
    }

    private func appRoute(for route: PushNotificationRoute) -> Route {
        switch route {
        case .loanHistory:
            return .loanHistory
        case .notices:
            return .notices
        case .newArrivals:
            return .newArrivals
        case let .bookDetail(bookId):
            return .bookDetail(bookId)
        }
    }
}

struct AppShellView_Previews: PreviewProvider {
    static var previews: some View {
        AppShellView().previewDevice("iPhone 16")
    }
}
