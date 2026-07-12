import SwiftUI
import UserNotifications

struct NotificationSettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @AppStorage("notification.return") private var returnReminder = true
    @AppStorage("notification.libraryNotice") private var libraryNotice = true
    @AppStorage("notification.newBooks") private var newBooksNotice = false

    var body: some View {
        VStack(spacing: 0) {
            Capsule().fill(Color(red: 225/255, green: 225/255, blue: 230/255)).frame(width: 32, height: 4).padding(.top, 8)
            VStack(alignment: .leading, spacing: 0) {
                Text("알림 설정").font(FeatureFontFamily.Pretendard.bold.swiftUIFont(size: 18)).padding(.top, 24)
                Text("받고 싶은 알림을 선택하세요").font(FeatureFontFamily.Pretendard.medium.swiftUIFont(size: 12)).foregroundColor(.secondary).padding(.top, 5)
                NotificationChannelRow(title: "반납 알림", subtitle: "반납 3일 전과 당일에 알려드려요", isOn: $returnReminder)
                NotificationChannelRow(title: "도서부 공지 알림", subtitle: "새 공지가 올라오면 알려드려요", isOn: $libraryNotice)
                NotificationChannelRow(title: "도서부 공지 알림", subtitle: "새 공지가 올라오면 알려드려요", isOn: $newBooksNotice)
                Button("설정 완료") { dismiss() }
                    .font(FeatureFontFamily.Pretendard.semiBold.swiftUIFont(size: 14))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 52)
                    .background(FeatureAsset.Color.buttonColor.swiftUIColor)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .padding(.top, 18)
            }
            .padding(.horizontal, 20)
            Spacer()
        }
        .presentationDetents([.height(442)])
        .presentationDragIndicator(.hidden)
    }
}

private struct NotificationChannelRow: View {
    let title: String
    let subtitle: String
    @Binding var isOn: Bool

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 5) {
                Text(title).font(FeatureFontFamily.Pretendard.semiBold.swiftUIFont(size: 14))
                Text(subtitle).font(FeatureFontFamily.Pretendard.medium.swiftUIFont(size: 11)).foregroundColor(.secondary)
            }
            Spacer()
            Toggle("", isOn: $isOn).labelsHidden().tint(FeatureAsset.Color.buttonColor.swiftUIColor)
        }
        .padding(.vertical, 16)
        .overlay(alignment: .bottom) { Divider() }
        .onChange(of: isOn) { enabled in
            guard enabled else { return }
            UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { _, _ in }
        }
    }
}
