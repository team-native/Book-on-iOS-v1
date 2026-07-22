import SwiftUI
import Service

@MainActor
private final class MarathonViewModel: ObservableObject {
    @Published private(set) var marathon: MarathonData?
    @Published private(set) var myInfo: Read365MyInfo?
    @Published private(set) var isLoading = false
    @Published private(set) var errorMessage: String?

    private let service: MarathonService

    init(service: MarathonService) {
        self.service = service
    }

    func load() async {
        guard !isLoading else { return }
        isLoading = true
        errorMessage = nil

        do {
            async let marathonRequest = service.fetchMarathon()
            async let myInfoRequest = service.fetchMyInfo()
            marathon = try await marathonRequest
            myInfo = try await myInfoRequest
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }
}

public struct MyView: View {
    private let menuItems = ["비밀번호 변경", "대출 / 반납 내역", "즐겨찾기 목록", "알림 설정", "이용 안내"]
    @State private var isMarathonLinked = false
    @State private var showsNotificationSettings = false
    @State private var showsLoanHistory = false
    @State private var showsFavorites = false
    @State private var selectedFavoriteBookId: Int?
    @State private var showsLogoutConfirmation = false
    @StateObject private var marathonViewModel: MarathonViewModel
    private let onSelectTab: (BottomTabBar.Item) -> Void
    private let onLogout: () -> Void

    public init(
        marathonService: MarathonService = MarathonService(),
        onSelectTab: @escaping (BottomTabBar.Item) -> Void = { _ in },
        onLogout: @escaping () -> Void = {}
    ) {
        _marathonViewModel = StateObject(wrappedValue: MarathonViewModel(service: marathonService))
        self.onSelectTab = onSelectTab
        self.onLogout = onLogout
    }
    public var body: some View {
        GeometryReader { geo in
            let scale = geo.size.width / 392
            ZStack(alignment: .topLeading) {
                Color.white
                Text("내 서재").font(FeatureFontFamily.Pretendard.bold.swiftUIFont(size: 16 * scale)).offset(x: 173 * scale, y: 74 * scale)
                HStack(spacing: 16 * scale) {
                    ZStack(alignment: .bottomTrailing) {
                        ProfileAvatar(size: 64, scale: scale)
                        Button(action: {}) {
                            Image(systemName: "pencil").font(.system(size: 10 * scale, weight: .bold)).foregroundColor(.black).frame(width: 24 * scale, height: 24 * scale).background(Color.white).clipShape(Circle()).shadow(radius: 3 * scale)
                        }
                        .buttonStyle(.plain)
                    }
                    VStack(alignment: .leading, spacing: 5 * scale) {
                        Text("\(marathonViewModel.myInfo?.profile.name ?? "사용자") 님").font(FeatureFontFamily.Pretendard.semiBold.swiftUIFont(size: 22 * scale))
                        Text(profileDetail).font(FeatureFontFamily.Pretendard.semiBold.swiftUIFont(size: 12 * scale)).foregroundColor(Color(red: 154/255, green: 154/255, blue: 161/255))
                    }
                }.offset(x: 23 * scale, y: 108 * scale)
                ProfileStatsCard(stats: [("대출 중", "3권"), ("반납 임박", "2권"), ("누적 대출", "23권")], scale: scale).frame(width: 346 * scale).offset(x: 23 * scale, y: 188 * scale)
                marathonCard(scale: scale).offset(x: 23 * scale, y: 288 * scale)
                VStack(spacing: 0) {
                    ForEach(menuItems, id: \.self) { item in
                        NavigationMenuRow(title: item, scale: scale, action: {
                            if item == "알림 설정" { showsNotificationSettings = true }
                            if item == "대출 / 반납 내역" { showsLoanHistory = true }
                            if item == "즐겨찾기 목록" { showsFavorites = true }
                        })
                        Divider()
                    }
                    NavigationMenuRow(
                        title: "로그아웃",
                        isDestructive: true,
                        scale: scale,
                        action: { showsLogoutConfirmation = true }
                    )
                }.frame(width: 346 * scale).offset(x: 23 * scale, y: 426 * scale)
                Text("© 2026 Native").font(FeatureFontFamily.Pretendard.semiBold.swiftUIFont(size: 10 * scale)).foregroundColor(Color(red: 199/255, green: 199/255, blue: 204/255)).offset(x: 19 * scale, y: 740 * scale)
                BottomTabBar(selected: .my, scale: scale, action: onSelectTab).frame(width: 392 * scale, height: 89 * scale).offset(y: 763 * scale)
            }.frame(width: geo.size.width, height: geo.size.height, alignment: .topLeading)
        }
        .ignoresSafeArea()
        .task { await marathonViewModel.load() }
        .sheet(isPresented: $showsNotificationSettings) { NotificationSettingsView() }
        .fullScreenCover(isPresented: $showsLoanHistory) {
            LoanHistoryView(onBack: { showsLoanHistory = false })
        }
        .fullScreenCover(isPresented: $showsFavorites) {
            FavoritesView(
                onBack: { showsFavorites = false },
                onShowBookDetail: { selectedFavoriteBookId = $0 }
            )
            .fullScreenCover(
                isPresented: Binding(
                    get: { selectedFavoriteBookId != nil },
                    set: { if !$0 { selectedFavoriteBookId = nil } }
                )
            ) {
                if let bookId = selectedFavoriteBookId {
                    BookDetailView(bookId: bookId, onBack: { selectedFavoriteBookId = nil })
                }
            }
        }
        .alert("로그아웃하시겠어요?", isPresented: $showsLogoutConfirmation) {
            Button("취소", role: .cancel) {}
            Button("로그아웃", role: .destructive, action: onLogout)
        }
    }
    private func marathonCard(scale: CGFloat) -> some View {
        let activeMarathon = marathonViewModel.marathon?.marathons.first
        let targetPage = Int(activeMarathon?.course?.completeDistance ?? "") ?? 0
        let currentPage = activeMarathon?.myTotalPage ?? 0
        let progress = targetPage > 0 ? min(Double(currentPage) / Double(targetPage), 1) : 0
        let isLinked = marathonViewModel.marathon?.activeCount ?? 0 > 0

        return VStack(alignment: .leading, spacing: 0) {
            HStack {
                Text("🏃  2026 독서마라톤").font(FeatureFontFamily.Pretendard.bold.swiftUIFont(size: 14 * scale))
                Spacer()
                if isLinked {
                    Text("참여 중").font(FeatureFontFamily.Pretendard.bold.swiftUIFont(size: 10 * scale)).foregroundColor(FeatureAsset.Color.buttonColor.swiftUIColor).padding(.horizontal, 9 * scale).padding(.vertical, 5 * scale).background(FeatureAsset.Color.buttonColor.swiftUIColor.opacity(0.12)).clipShape(RoundedRectangle(cornerRadius: 6 * scale))
                } else if marathonViewModel.isLoading {
                    ProgressView().scaleEffect(0.8)
                }
            }
            if isLinked {
                HStack { Text("\(activeMarathon?.course?.courseName ?? "진행 중") · \(currentPage) / \(targetPage)쪽"); Spacer(); Text("\(Int(progress * 100))%").foregroundColor(FeatureAsset.Color.buttonColor.swiftUIColor) }.font(FeatureFontFamily.Pretendard.semiBold.swiftUIFont(size: 12 * scale)).foregroundColor(Color(red: 142/255, green: 142/255, blue: 147/255)).padding(.top, 15 * scale)
                GeometryReader { p in ZStack(alignment: .leading) { Capsule().fill(Color(red: 217/255, green: 217/255, blue: 217/255)); Capsule().fill(FeatureAsset.Color.buttonColor.swiftUIColor).frame(width: p.size.width * progress) } }.frame(height: 8 * scale).padding(.top, 14 * scale)
                Text("완주까지 \(max(targetPage - currentPage, 0))쪽 남았어요").font(FeatureFontFamily.Pretendard.semiBold.swiftUIFont(size: 12 * scale)).foregroundColor(Color(red: 142/255, green: 142/255, blue: 147/255)).padding(.top, 12 * scale)
            } else {
                Text(marathonViewModel.errorMessage ?? "아직 연동하지 않았어요").font(FeatureFontFamily.Pretendard.semiBold.swiftUIFont(size: 12 * scale)).foregroundColor(Color(red: 142/255, green: 142/255, blue: 147/255)).padding(.top, 16 * scale)
                Text("회원가입 또는 계정 설정에서 독서마라톤을 연동해주세요")
                    .font(FeatureFontFamily.Pretendard.semiBold.swiftUIFont(size: 12 * scale))
                    .foregroundColor(Color(red: 142/255, green: 142/255, blue: 147/255))
                    .padding(.top, 14 * scale)
            }
        }.padding(18 * scale).frame(width: 346 * scale, height: 126 * scale, alignment: .topLeading).background(Color(red: 251/255, green: 251/255, blue: 252/255)).overlay(RoundedRectangle(cornerRadius: 16 * scale).stroke(Color(red: 243/255, green: 243/255, blue: 245/255))).clipShape(RoundedRectangle(cornerRadius: 16 * scale))
    }

    private var profileDetail: String {
        let profile = marathonViewModel.myInfo?.profile
        let grade = profile?.memGrade.map { "\($0)학년" }
        let schoolClass = profile?.memClass.map { "\($0)반" }
        return [grade, schoolClass].compactMap { $0 }.joined(separator: " · ")
    }
}

struct MyView_Previews: PreviewProvider { static var previews: some View { MyView().previewDevice("iPhone 16") } }
