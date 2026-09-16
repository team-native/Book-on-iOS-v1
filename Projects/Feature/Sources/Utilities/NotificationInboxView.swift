import SwiftUI
import Service

@MainActor
private final class NotificationInboxViewModel: ObservableObject {
    @Published private(set) var notifications: [NotificationHistoryItem] = []
    @Published private(set) var isLoading = false
    @Published private(set) var errorMessage: String?

    private let service: NotificationHistoryService

    init(service: NotificationHistoryService) {
        self.service = service
    }

    func load() async {
        guard !isLoading else { return }

        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            notifications = try await service.fetchNotifications().notifications
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func markRead(_ notification: NotificationHistoryItem) async {
        guard !notification.isRead else { return }

        do {
            try await service.markRead(notificationId: notification.id)
            guard let index = notifications.firstIndex(where: { $0.id == notification.id }) else { return }
            notifications[index] = NotificationHistoryItem(
                id: notification.id,
                type: notification.type,
                title: notification.title,
                body: notification.body,
                isRead: true,
                createdAt: notification.createdAt,
                deepLink: notification.deepLink
            )
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}

public struct NotificationInboxView: View {
    @StateObject private var viewModel: NotificationInboxViewModel
    private let onDismiss: () -> Void

    public init(
        service: NotificationHistoryService = NotificationHistoryService(),
        onDismiss: @escaping () -> Void = {}
    ) {
        _viewModel = StateObject(wrappedValue: NotificationInboxViewModel(service: service))
        self.onDismiss = onDismiss
    }

    public var body: some View {
        GeometryReader { geo in
            let scale = geo.size.width / 392

            ZStack(alignment: .topLeading) {
                Color(red: 251 / 255, green: 251 / 255, blue: 252 / 255)
                    .ignoresSafeArea()

                header(scale: scale)
                    .padding(.top, 58 * scale)

                content(scale: scale)
                .padding(.top, 118 * scale)
            }
        }
        .ignoresSafeArea(edges: .bottom)
        .task { await viewModel.load() }
    }

    private func header(scale: CGFloat) -> some View {
        HStack(spacing: 0) {
            Button(action: onDismiss) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 16 * scale, weight: .semibold))
                    .foregroundColor(.black)
                    .frame(width: 40 * scale, height: 40 * scale)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)

            Text("받은 알림")
                .font(FeatureFontFamily.Pretendard.bold.swiftUIFont(size: 20 * scale))
                .foregroundColor(.black)
                .padding(.leading, 8 * scale)

            Spacer()

            Text("최근 알림")
                .font(FeatureFontFamily.Pretendard.semiBold.swiftUIFont(size: 11 * scale))
                .foregroundColor(Color(red: 154 / 255, green: 154 / 255, blue: 161 / 255))
        }
        .padding(.horizontal, 16 * scale)
        .frame(width: 392 * scale, height: 44 * scale)
    }

    private func emptyState(scale: CGFloat) -> some View {
        VStack(spacing: 12 * scale) {
            Image(systemName: "bell.slash")
                .font(.system(size: 30 * scale, weight: .medium))
                .foregroundColor(FeatureAsset.Color.textDescription.swiftUIColor)

            Text("받은 알림이 없어요")
                .font(FeatureFontFamily.Pretendard.semiBold.swiftUIFont(size: 15 * scale))
                .foregroundColor(FeatureAsset.Color.textPrimary.swiftUIColor)

            Text("새 알림이 도착하면 여기에서 확인할 수 있어요.")
                .font(FeatureFontFamily.Pretendard.medium.swiftUIFont(size: 12 * scale))
                .foregroundColor(FeatureAsset.Color.textDescription.swiftUIColor)
        }
        .frame(maxWidth: .infinity)
        .accessibilityElement(children: .combine)
    }

    @ViewBuilder
    private func content(scale: CGFloat) -> some View {
        if viewModel.isLoading && viewModel.notifications.isEmpty {
            ProgressView()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else if let errorMessage = viewModel.errorMessage, viewModel.notifications.isEmpty {
            VStack(spacing: 12 * scale) {
                Text(errorMessage)
                    .multilineTextAlignment(.center)
                Button("재시도") { Task { await viewModel.load() } }
            }
            .font(FeatureFontFamily.Pretendard.medium.swiftUIFont(size: 12 * scale))
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else if viewModel.notifications.isEmpty {
            emptyState(scale: scale)
                .padding(.horizontal, 24 * scale)
                .padding(.top, 32 * scale)
        } else {
            ScrollView(showsIndicators: false) {
                LazyVStack(spacing: 12 * scale) {
                    ForEach(viewModel.notifications) { notification in
                        Button {
                            Task { await viewModel.markRead(notification) }
                        } label: {
                            notificationCard(notification, scale: scale)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 24 * scale)
                .padding(.top, 16 * scale)
                .padding(.bottom, 32 * scale)
            }
            .refreshable { await viewModel.load() }
        }
    }

    private func notificationCard(_ notification: NotificationHistoryItem, scale: CGFloat) -> some View {
        HStack(alignment: .top, spacing: 13 * scale) {
            Image(systemName: iconName(for: notification.type))
                .font(.system(size: 16 * scale, weight: .medium))
                .foregroundColor(FeatureAsset.Color.buttonColor.swiftUIColor)
                .frame(width: 38 * scale, height: 38 * scale)
                .background(FeatureAsset.Color.buttonColor.swiftUIColor.opacity(0.13))
                .clipShape(RoundedRectangle(cornerRadius: 11 * scale))

            VStack(alignment: .leading, spacing: 0) {
                HStack(alignment: .firstTextBaseline, spacing: 8 * scale) {
                    Text(notification.title)
                        .font(FeatureFontFamily.Pretendard.bold.swiftUIFont(size: 14 * scale))
                        .foregroundColor(.black)
                        .lineLimit(2)

                    Spacer(minLength: 4 * scale)

                    if !notification.isRead {
                        Circle()
                            .fill(FeatureAsset.Color.buttonColor.swiftUIColor)
                            .frame(width: 7 * scale, height: 7 * scale)
                    }
                }

                Text(notification.body)
                    .font(FeatureFontFamily.Pretendard.medium.swiftUIFont(size: 12 * scale))
                    .foregroundColor(Color(red: 122 / 255, green: 122 / 255, blue: 129 / 255))
                    .lineSpacing(3 * scale)
                    .padding(.top, 8 * scale)

                Text(notification.createdAt)
                    .font(FeatureFontFamily.Pretendard.medium.swiftUIFont(size: 10 * scale))
                    .foregroundColor(Color(red: 174 / 255, green: 174 / 255, blue: 180 / 255))
                    .padding(.top, 10 * scale)
            }
        }
        .padding(16 * scale)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 18 * scale))
        .shadow(color: .black.opacity(0.07), radius: 8 * scale, x: 1 * scale, y: 2 * scale)
        .accessibilityElement(children: .combine)
    }

    private func iconName(for type: String) -> String {
        switch type {
        case "loan_due": return "book.closed.fill"
        case "notice": return "megaphone.fill"
        case "new_book": return "book.fill"
        default: return "bell.fill"
        }
    }
}

struct NotificationInboxView_Previews: PreviewProvider {
    static var previews: some View {
        NotificationInboxView().previewDevice("iPhone 16")
    }
}
