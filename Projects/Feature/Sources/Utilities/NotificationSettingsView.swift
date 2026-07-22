import SwiftUI
import Service
import UserNotifications

@MainActor
private final class NotificationSettingsViewModel: ObservableObject {
    @Published var dueDateReminder = true
    @Published var newBookReminder = false
    @Published var isLoading = false
    @Published var errorMessage: String?
    private let service: MeService

    init(service: MeService) { self.service = service }

    func load() async {
        isLoading = true; errorMessage = nil
        do {
            let value = try await service.fetchMe().notificationSettings
            dueDateReminder = value.dueDateReminder
            newBookReminder = value.newBookReminder
        } catch { errorMessage = error.localizedDescription }
        isLoading = false
    }

    func save() async -> Bool {
        isLoading = true; errorMessage = nil
        do {
            let value = try await service.updateNotificationSettings(.init(
                dueDateReminder: dueDateReminder,
                newBookReminder: newBookReminder
            ))
            dueDateReminder = value.dueDateReminder
            newBookReminder = value.newBookReminder
            isLoading = false
            return true
        } catch {
            errorMessage = error.localizedDescription
            isLoading = false
            return false
        }
    }
}

struct NotificationSettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel: NotificationSettingsViewModel

    init(service: MeService = MeService()) {
        _viewModel = StateObject(wrappedValue: NotificationSettingsViewModel(service: service))
    }

    var body: some View {
        VStack(spacing: 0) {
            Capsule().fill(Color(red: 225/255, green: 225/255, blue: 230/255)).frame(width: 32, height: 4).padding(.top, 8)
            VStack(alignment: .leading, spacing: 0) {
                Text("알림 설정").font(FeatureFontFamily.Pretendard.bold.swiftUIFont(size: 18)).padding(.top, 24)
                Text("받고 싶은 알림을 선택하세요").font(FeatureFontFamily.Pretendard.medium.swiftUIFont(size: 12)).foregroundColor(.secondary).padding(.top, 5)
                NotificationChannelRow(title: "반납 알림", subtitle: "반납 예정일을 알려드려요", isOn: $viewModel.dueDateReminder)
                NotificationChannelRow(title: "신간 알림", subtitle: "새 도서가 등록되면 알려드려요", isOn: $viewModel.newBookReminder)
                if let error = viewModel.errorMessage { Text(error).font(.caption).foregroundColor(.red).padding(.top, 8) }
                Button(viewModel.isLoading ? "저장 중..." : "설정 완료") {
                    Task { if await viewModel.save() { dismiss() } }
                }
                .disabled(viewModel.isLoading)
                .font(FeatureFontFamily.Pretendard.semiBold.swiftUIFont(size: 14)).foregroundColor(.white)
                .frame(maxWidth: .infinity).frame(height: 52)
                .background(FeatureAsset.Color.buttonColor.swiftUIColor).clipShape(RoundedRectangle(cornerRadius: 8)).padding(.top, 18)
            }.padding(.horizontal, 20)
            Spacer()
        }
        .task { await viewModel.load() }
        .presentationDetents([.height(390)])
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
        .padding(.vertical, 16).overlay(alignment: .bottom) { Divider() }
        .onChange(of: isOn) { enabled in
            guard enabled else { return }
            UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { _, _ in }
        }
    }
}
