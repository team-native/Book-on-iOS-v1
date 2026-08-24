import SwiftUI
import Service

@MainActor
private final class NoticeListViewModel: ObservableObject {
    @Published private(set) var notices: [Notice] = []
    @Published private(set) var isLoading = false
    @Published private(set) var errorMessage: String?

    private let service: HomeService

    init(service: HomeService) {
        self.service = service
    }

    func load() async {
        guard !isLoading else { return }

        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            notices = try await service.fetchNotices(page: 1, size: 30).items
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}

/// 공지 푸시를 탭했을 때 최신 도서부 공지를 확인하는 화면입니다.
public struct NoticeListView: View {
    @StateObject private var viewModel: NoticeListViewModel
    private let onBack: () -> Void

    public init(
        service: HomeService = HomeService(),
        onBack: @escaping () -> Void = {}
    ) {
        _viewModel = StateObject(wrappedValue: NoticeListViewModel(service: service))
        self.onBack = onBack
    }

    public var body: some View {
        GeometryReader { geometry in
            let scale = geometry.size.width / 392

            ZStack(alignment: .topLeading) {
                Color.white.ignoresSafeArea()

                AppBackButton(scale: scale, action: onBack)
                    .offset(x: 25 * scale, y: 64 * scale)

                Text("도서부 공지")
                    .font(FeatureFontFamily.Pretendard.bold.swiftUIFont(size: 18 * scale))
                    .offset(x: 151 * scale, y: 74 * scale)

                content(scale: scale)
                    .frame(width: 344 * scale, height: geometry.size.height - 145 * scale, alignment: .top)
                    .offset(x: 24 * scale, y: 133 * scale)
            }
        }
        .ignoresSafeArea()
        .task { await viewModel.load() }
    }

    @ViewBuilder
    private func content(scale: CGFloat) -> some View {
        if viewModel.isLoading {
            ProgressView().frame(maxWidth: .infinity, maxHeight: .infinity)
        } else if let errorMessage = viewModel.errorMessage {
            VStack(spacing: 12 * scale) {
                Text(errorMessage).multilineTextAlignment(.center)
                Button("재시도") { Task { await viewModel.load() } }
            }
            .font(FeatureFontFamily.Pretendard.medium.swiftUIFont(size: 12 * scale))
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else if viewModel.notices.isEmpty {
            Text("등록된 공지가 없어요.")
                .foregroundColor(.secondary)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else {
            ScrollView {
                LazyVStack(spacing: 12 * scale) {
                    ForEach(viewModel.notices) { notice in
                        VStack(alignment: .leading, spacing: 8 * scale) {
                            Text(notice.title)
                                .font(FeatureFontFamily.Pretendard.semiBold.swiftUIFont(size: 15 * scale))
                            Text(notice.summary)
                                .font(FeatureFontFamily.Pretendard.medium.swiftUIFont(size: 12 * scale))
                                .foregroundColor(.secondary)
                                .lineSpacing(3 * scale)
                            Text(notice.createdAt)
                                .font(FeatureFontFamily.Pretendard.medium.swiftUIFont(size: 10 * scale))
                                .foregroundColor(Color(red: 154 / 255, green: 154 / 255, blue: 161 / 255))
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(16 * scale)
                        .background(Color(red: 251 / 255, green: 251 / 255, blue: 252 / 255))
                        .clipShape(RoundedRectangle(cornerRadius: 14 * scale))
                    }
                }
                .padding(.bottom, 24 * scale)
            }
        }
    }
}
