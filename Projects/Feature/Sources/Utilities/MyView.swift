import SwiftUI
import Service

private enum ProfileImageUploadError: LocalizedError {
    case missingImageURL

    var errorDescription: String? {
        "서버에서 프로필 이미지 주소를 받지 못했습니다."
    }
}

private enum LocalProfileImageStore {
    static func load(userId: Int) -> Data? {
        try? Data(contentsOf: fileURL(userId: userId))
    }

    static func save(_ data: Data, userId: Int) throws {
        let directory = fileURL(userId: userId).deletingLastPathComponent()
        try FileManager.default.createDirectory(
            at: directory,
            withIntermediateDirectories: true
        )
        try data.write(to: fileURL(userId: userId), options: .atomic)
    }

    static func delete(userId: Int) {
        try? FileManager.default.removeItem(at: fileURL(userId: userId))
    }

    private static func fileURL(userId: Int) -> URL {
        let baseDirectory = FileManager.default.urls(
            for: .applicationSupportDirectory,
            in: .userDomainMask
        )[0]
        return baseDirectory
            .appendingPathComponent("BookOn/ProfileImages", isDirectory: true)
            .appendingPathComponent("profile-\(userId).jpg")
    }
}

@MainActor
private final class MarathonViewModel: ObservableObject {
    @Published private(set) var marathon: MarathonData?
    @Published private(set) var myInfo: Read365MyInfo?
    @Published private(set) var isLoading = false
    @Published private(set) var errorMessage: String?
    @Published private(set) var me: MeData?
    @Published private(set) var totalLoanCount = 0
    @Published private(set) var isLinkingRead365 = false
    @Published private(set) var read365LinkError: String?
    @Published private(set) var isUpdatingProfileImage = false
    @Published private(set) var profileImageError: String?
    @Published private(set) var localProfileImageData: Data?

    private let service: MarathonService
    private let meService: MeService
    private let loanService: LoanService
    private let read365Service: Read365Service

    init(service: MarathonService, meService: MeService, loanService: LoanService, read365Service: Read365Service) {
        self.service = service
        self.meService = meService
        self.loanService = loanService
        self.read365Service = read365Service
    }

    func load() async {
        guard !isLoading else { return }
        isLoading = true
        errorMessage = nil

        do {
            me = try await meService.fetchMe()
            if let user = me?.user, user.profileImageUrl != nil {
                localProfileImageData = LocalProfileImageStore.load(userId: user.userId)
            } else if let userId = me?.user.userId {
                LocalProfileImageStore.delete(userId: userId)
                localProfileImageData = nil
            }
            _ = try? await read365Service.extendSession()
            async let marathonRequest = try? service.fetchMarathon()
            async let myInfoRequest = try? service.fetchMyInfo()
            async let loanHistoryRequest = try? loanService.fetchHistory(status: "ALL", page: 1, size: 1)
            marathon = await marathonRequest
            myInfo = await myInfoRequest
            totalLoanCount = await loanHistoryRequest?.pagination.totalCount ?? 0
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }

    func linkRead365(cookieHeader: String) async -> Bool {
        guard !isLinkingRead365 else { return false }
        isLinkingRead365 = true
        read365LinkError = nil

        do {
            _ = try await read365Service.registerSession(cookieHeader: cookieHeader)
            marathon = try await service.fetchMarathon()
            myInfo = try await service.fetchMyInfo()
            isLinkingRead365 = false
            return true
        } catch {
            read365LinkError = error.localizedDescription
            isLinkingRead365 = false
            return false
        }
    }

    func uploadProfileImage(data: Data, contentType: String) async -> Bool {
        guard !isUpdatingProfileImage else { return false }
        isUpdatingProfileImage = true
        profileImageError = nil
        do {
            let uploaded = try await meService.uploadProfileImage(data: data, contentType: contentType)
            guard uploaded.profileImageUrl != nil else {
                throw ProfileImageUploadError.missingImageURL
            }
            localProfileImageData = data
            if let userId = me?.user.userId {
                try LocalProfileImageStore.save(data, userId: userId)
            }
            if let imagePath = uploaded.profileImageUrl,
               let imageURL = resolvedProfileImageURL(imagePath),
               let image = UIImage(data: data) {
                ProfileImageCache.shared.store(image, for: imageURL)
            }
            me = try await meService.fetchMe()
            isUpdatingProfileImage = false
            return true
        } catch {
            profileImageError = error.localizedDescription
            isUpdatingProfileImage = false
            return false
        }
    }

    func deleteProfileImage() async -> Bool {
        guard !isUpdatingProfileImage else { return false }
        isUpdatingProfileImage = true
        profileImageError = nil
        do {
            _ = try await meService.deleteProfileImage()
            if let userId = me?.user.userId {
                LocalProfileImageStore.delete(userId: userId)
            }
            ProfileImageCache.shared.removeAll()
            localProfileImageData = nil
            me = try await meService.fetchMe()
            isUpdatingProfileImage = false
            return true
        } catch {
            profileImageError = error.localizedDescription
            isUpdatingProfileImage = false
            return false
        }
    }

    private func resolvedProfileImageURL(_ imagePath: String) -> URL? {
        if let absoluteURL = URL(string: imagePath), absoluteURL.scheme != nil {
            return absoluteURL
        }
        return URL(string: imagePath, relativeTo: APIConfiguration.baseURL)?.absoluteURL
    }
}

public struct MyView: View {
    private let menuItems = ["비밀번호 변경", "대출 / 반납 내역", "즐겨찾기 목록", "알림 설정", "이용 안내"]
    @State private var showsNotificationSettings = false
    @State private var showsLoanHistory = false
    @State private var showsFavorites = false
    @State private var selectedFavoriteBookId: Int?
    @State private var showsLogoutConfirmation = false
    @State private var showsRead365Link = false
    @State private var showsProfileImageSettings = false
    @StateObject private var marathonViewModel: MarathonViewModel
    private let onSelectTab: (BottomTabBar.Item) -> Void
    private let onLogout: () -> Void

    public init(
        marathonService: MarathonService = MarathonService(),
        meService: MeService = MeService(),
        loanService: LoanService = LoanService(),
        read365Service: Read365Service = Read365Service(),
        onSelectTab: @escaping (BottomTabBar.Item) -> Void = { _ in },
        onLogout: @escaping () -> Void = {}
    ) {
        _marathonViewModel = StateObject(
            wrappedValue: MarathonViewModel(
                service: marathonService,
                meService: meService,
                loanService: loanService,
                read365Service: read365Service
            )
        )
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
                        ProfileAvatar(
                            size: 64,
                            scale: scale,
                            imagePath: marathonViewModel.me?.user.profileImageUrl,
                            imageData: marathonViewModel.localProfileImageData
                        )
                        Button(action: { showsProfileImageSettings = true }) {
                            Image(systemName: "pencil").font(.system(size: 10 * scale, weight: .bold)).foregroundColor(.black).frame(width: 24 * scale, height: 24 * scale).background(Color.white).clipShape(Circle()).shadow(radius: 3 * scale)
                        }
                        .buttonStyle(.plain)
                    }
                    VStack(alignment: .leading, spacing: 5 * scale) {
                        Text("\(marathonViewModel.me?.user.name ?? marathonViewModel.myInfo?.profile.name ?? "사용자") 님").font(FeatureFontFamily.Pretendard.semiBold.swiftUIFont(size: 22 * scale))
                        Text(profileDetail).font(FeatureFontFamily.Pretendard.semiBold.swiftUIFont(size: 12 * scale)).foregroundColor(Color(red: 154/255, green: 154/255, blue: 161/255))
                    }
                }.offset(x: 23 * scale, y: 108 * scale)
                ProfileStatsCard(stats: profileStats, scale: scale).frame(width: 346 * scale).offset(x: 23 * scale, y: 188 * scale)
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
            }.frame(width: geo.size.width, height: geo.size.height, alignment: .topLeading)
        }
        .ignoresSafeArea()
        .task { await marathonViewModel.load() }
        .sheet(isPresented: $showsNotificationSettings) { NotificationSettingsView() }
        .sheet(isPresented: $showsProfileImageSettings) {
            ProfileImageSettingsView(
                profileImagePath: marathonViewModel.me?.user.profileImageUrl,
                isSubmitting: marathonViewModel.isUpdatingProfileImage,
                errorMessage: marathonViewModel.profileImageError,
                onUpload: { data, contentType in
                    await marathonViewModel.uploadProfileImage(data: data, contentType: contentType)
                },
                onDelete: {
                    await marathonViewModel.deleteProfileImage()
                }
            )
        }
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
        .fullScreenCover(isPresented: $showsRead365Link) {
            Read365LinkView(
                isSubmitting: marathonViewModel.isLinkingRead365,
                serverError: marathonViewModel.read365LinkError,
                onBack: { showsRead365Link = false },
                onLink: { cookieHeader in
                    Task {
                        if await marathonViewModel.linkRead365(cookieHeader: cookieHeader) {
                            showsRead365Link = false
                        }
                    }
                }
            )
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
            HStack(spacing: 6 * scale) {
                FeatureAsset.Image.readingMarathonLogo.swiftUIImage
                    .resizable()
                    .scaledToFit()
                    .frame(width: 20 * scale, height: 20 * scale)

                Text("2026 독서마라톤")
                    .font(FeatureFontFamily.Pretendard.bold.swiftUIFont(size: 14 * scale))

                Spacer()

                if marathonViewModel.isLoading {
                    ProgressView().scaleEffect(0.8)
                } else {
                    Toggle(
                        "",
                        isOn: Binding(
                            get: { isLinked },
                            set: { shouldLink in
                                if shouldLink && !isLinked { showsRead365Link = true }
                            }
                        )
                    )
                        .labelsHidden()
                        .tint(FeatureAsset.Color.buttonColor.swiftUIColor)
                        .scaleEffect(0.78)
                        .frame(width: 44 * scale, height: 28 * scale)
                }
            }
            .frame(height: 20 * scale)

            if isLinked {
                HStack {
                    Text("\(activeMarathon?.course?.courseName ?? "진행 중") · \(currentPage) / \(targetPage)쪽")
                    Spacer()
                    Text("\(Int(progress * 100))%")
                        .foregroundColor(FeatureAsset.Color.buttonColor.swiftUIColor)
                }
                .font(FeatureFontFamily.Pretendard.semiBold.swiftUIFont(size: 12 * scale))
                .foregroundColor(Color(red: 142/255, green: 142/255, blue: 147/255))
                .padding(.top, 10 * scale)

                GeometryReader { proxy in
                    ZStack(alignment: .leading) {
                        Capsule().fill(Color(red: 217/255, green: 217/255, blue: 217/255))
                        Capsule()
                            .fill(FeatureAsset.Color.buttonColor.swiftUIColor)
                            .frame(width: proxy.size.width * progress)
                    }
                }
                .frame(height: 8 * scale)
                .padding(.top, 9 * scale)

                Text("완주까지 \(max(targetPage - currentPage, 0))쪽 남았어요")
                    .font(FeatureFontFamily.Pretendard.semiBold.swiftUIFont(size: 12 * scale))
                    .foregroundColor(Color(red: 152/255, green: 152/255, blue: 159/255))
                    .padding(.top, 8 * scale)
            } else {
                Text(marathonViewModel.errorMessage ?? "아직 연동하지 않았어요")
                    .font(FeatureFontFamily.Pretendard.semiBold.swiftUIFont(size: 12 * scale))
                    .foregroundColor(Color(red: 142/255, green: 142/255, blue: 147/255))
                    .padding(.top, 10 * scale)

                Capsule()
                    .fill(Color(red: 217/255, green: 217/255, blue: 217/255))
                    .frame(height: 8 * scale)
                    .padding(.top, 9 * scale)

                Text("토글을 켜면 독서마라톤 계정을 연동할 수 있어요")
                    .font(FeatureFontFamily.Pretendard.semiBold.swiftUIFont(size: 12 * scale))
                    .foregroundColor(Color(red: 152/255, green: 152/255, blue: 159/255))
                    .padding(.top, 8 * scale)
            }
        }
        .padding(.horizontal, 18 * scale)
        .padding(.vertical, 15 * scale)
        .frame(width: 346 * scale, height: 126 * scale, alignment: .topLeading)
        .background(Color(red: 251/255, green: 251/255, blue: 252/255))
        .overlay(
            RoundedRectangle(cornerRadius: 16 * scale)
                .stroke(Color(red: 243/255, green: 243/255, blue: 245/255), lineWidth: scale)
        )
        .clipShape(RoundedRectangle(cornerRadius: 16 * scale))
    }

    private var profileDetail: String {
        if let department = marathonViewModel.me?.user.department { return department }
        let profile = marathonViewModel.myInfo?.profile
        let grade = profile?.memGrade.map { "\($0)학년" }
        let schoolClass = profile?.memClass.map { "\($0)반" }
        return [grade, schoolClass].compactMap { $0 }.joined(separator: " · ")
    }

    private var profileStats: [(String, String)] {
        let summary = marathonViewModel.me?.loanSummary
        let dueSoonCount = marathonViewModel.me?.currentLoans.filter {
            (0...3).contains($0.dDay)
        }.count ?? 0
        return [
            ("대출 중", "\(summary?.currentLoanCount ?? 0)권"),
            ("반납 임박", "\(dueSoonCount)권"),
            ("누적 대출", "\(marathonViewModel.totalLoanCount)권"),
        ]
    }
}

struct MyView_Previews: PreviewProvider { static var previews: some View { MyView().previewDevice("iPhone 16") } }
