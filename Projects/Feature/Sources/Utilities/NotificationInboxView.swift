import SwiftUI

public struct NotificationInboxView: View {
    private struct ReceivedNotification: Identifiable {
        let id = UUID()
        let icon: String
        let title: String
        let message: String
        let time: String
        let isUnread: Bool
    }

    private let notifications = [
        ReceivedNotification(
            icon: "book.closed.fill",
            title: "반납 예정일이 다가오고 있어요",
            message: "『클린 코더』의 반납일까지 3일 남았어요.",
            time: "오늘 · 오후 4:20",
            isUnread: true
        ),
        ReceivedNotification(
            icon: "megaphone.fill",
            title: "여름방학 도서 대출 기간 연장 안내",
            message: "방학 기간 동안 대출 가능 권수와 기간이 늘어났어요.",
            time: "오늘 · 오전 10:00",
            isUnread: true
        ),
        ReceivedNotification(
            icon: "checkmark.circle.fill",
            title: "도서 반납이 완료됐어요",
            message: "『아몬드』가 정상적으로 반납 처리됐어요.",
            time: "7월 12일",
            isUnread: false
        )
    ]

    private let onDismiss: () -> Void

    public init(onDismiss: @escaping () -> Void = {}) {
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

                ScrollView(showsIndicators: false) {
                    LazyVStack(spacing: 12 * scale) {
                        ForEach(notifications) { notification in
                            notificationCard(notification, scale: scale)
                        }
                    }
                    .padding(.horizontal, 24 * scale)
                    .padding(.top, 16 * scale)
                    .padding(.bottom, 32 * scale)
                }
                .padding(.top, 118 * scale)
            }
        }
        .ignoresSafeArea(edges: .bottom)
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

    private func notificationCard(_ notification: ReceivedNotification, scale: CGFloat) -> some View {
        HStack(alignment: .top, spacing: 13 * scale) {
            Image(systemName: notification.icon)
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

                    if notification.isUnread {
                        Circle()
                            .fill(FeatureAsset.Color.buttonColor.swiftUIColor)
                            .frame(width: 7 * scale, height: 7 * scale)
                    }
                }

                Text(notification.message)
                    .font(FeatureFontFamily.Pretendard.medium.swiftUIFont(size: 12 * scale))
                    .foregroundColor(Color(red: 122 / 255, green: 122 / 255, blue: 129 / 255))
                    .lineSpacing(3 * scale)
                    .padding(.top, 8 * scale)

                Text(notification.time)
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
}

struct NotificationInboxView_Previews: PreviewProvider {
    static var previews: some View {
        NotificationInboxView().previewDevice("iPhone 16")
    }
}
