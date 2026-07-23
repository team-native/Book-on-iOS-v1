import SwiftUI
import Service

@MainActor
private final class RankingViewModel: ObservableObject {
    @Published var data: ReaderRankingData?
    @Published var isLoading = false
    @Published var errorMessage: String?
    private let service: RankingService

    init(service: RankingService) { self.service = service }

    func load() async {
        guard !isLoading else { return }
        isLoading = true; errorMessage = nil
        do {
            data = try await service.fetchReaders(year: Calendar.current.component(.year, from: Date()))
        } catch { errorMessage = error.localizedDescription }
        isLoading = false
    }
}

public struct RankingView: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @StateObject private var viewModel: RankingViewModel
    @State private var selectedPlayer: ReaderRanking?
    @State private var podiumProgress: [Int: CGFloat] = [:]
    @State private var podiumAnimationTask: Task<Void, Never>?
    private let onSelectTab: (BottomTabBar.Item) -> Void

    public init(
        service: RankingService = RankingService(),
        onSelectTab: @escaping (BottomTabBar.Item) -> Void = { _ in }
    ) {
        _viewModel = StateObject(wrappedValue: RankingViewModel(service: service))
        self.onSelectTab = onSelectTab
    }

    public var body: some View {
        GeometryReader { geo in
            let scale = geo.size.width / 392
            ZStack(alignment: .topLeading) {
                Color.white.ignoresSafeArea()
                Text("다독왕 랭킹").font(FeatureFontFamily.Pretendard.bold.swiftUIFont(size: 28 * scale)).offset(x: 26 * scale, y: 69 * scale)
                Text("\(viewModel.data?.year ?? Calendar.current.component(.year, from: Date()))년 · 대출 권수 기준 · 매년 1월 1일 초기화")
                    .font(FeatureFontFamily.Pretendard.medium.swiftUIFont(size: 14 * scale))
                    .foregroundColor(Color(red: 154/255, green: 154/255, blue: 161/255)).offset(x: 26 * scale, y: 110 * scale)

                if viewModel.isLoading {
                    ProgressView().frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if let error = viewModel.errorMessage {
                    VStack(spacing: 12) {
                        Text(error).multilineTextAlignment(.center)
                        Button("재시도") { Task { await viewModel.load() } }
                    }.frame(width: geo.size.width, height: geo.size.height)
                } else {
                    podium(scale: scale).offset(x: 28 * scale, y: 166 * scale)
                    rankingList(scale: scale).offset(x: 25 * scale, y: 406 * scale)
                }
            }
        }
        .ignoresSafeArea()
        .task { await viewModel.load() }
        .onChange(of: viewModel.data?.items.map(\.loanCount) ?? []) { _ in
            startPodiumAnimation()
        }
        .onDisappear {
            podiumAnimationTask?.cancel()
        }
        .sheet(item: $selectedPlayer) { playerProfile($0) }
    }

    private func podium(scale: CGFloat) -> some View {
        let items = viewModel.data?.items ?? []
        let maximumLoanCount = max(items.prefix(3).map(\.loanCount).max() ?? 1, 1)
        return ZStack(alignment: .bottomLeading) {
            if let second = items.first(where: { $0.rank == 2 }) {
                podiumPerson(second, maximumLoanCount: maximumLoanCount, scale: scale).offset(x: 0)
            }
            if let first = items.first(where: { $0.rank == 1 }) {
                podiumPerson(first, maximumLoanCount: maximumLoanCount, scale: scale).offset(x: 116 * scale)
            }
            if let third = items.first(where: { $0.rank == 3 }) {
                podiumPerson(third, maximumLoanCount: maximumLoanCount, scale: scale).offset(x: 232 * scale)
            }
        }.frame(width: 332 * scale, height: 222 * scale, alignment: .bottomLeading)
    }

    private func podiumPerson(
        _ player: ReaderRanking,
        maximumLoanCount: Int,
        scale: CGFloat
    ) -> some View {
        let isFirst = player.rank == 1
        let progress = podiumProgress[player.rank] ?? 0
        let ratio = CGFloat(player.loanCount) / CGFloat(maximumLoanCount)
        let targetHeight = max(42, 96 * ratio)
        let displayedHeight = max(1, targetHeight * progress)

        return Button { selectedPlayer = player } label: {
            VStack(spacing: 3 * scale) {
                ProfileAvatar(size: isFirst ? 64 : 52, scale: scale)
                Text(player.name).font(FeatureFontFamily.Pretendard.bold.swiftUIFont(size: 14 * scale))
                AnimatedLoanCount(value: Double(player.loanCount) * Double(progress))
                    .font(FeatureFontFamily.Pretendard.medium.swiftUIFont(size: 12 * scale))
                    .foregroundColor(isFirst ? FeatureAsset.Color.buttonColor.swiftUIColor : .secondary)
                Spacer(minLength: 10 * scale)
                Text("\(player.rank)").font(FeatureFontFamily.Pretendard.bold.swiftUIFont(size: 20 * scale))
                    .frame(width: 100 * scale, height: displayedHeight * scale, alignment: .top)
                    .padding(.top, 12 * scale)
                    .background(isFirst ? FeatureAsset.Color.buttonColor.swiftUIColor.opacity(0.2) : Color.gray.opacity(0.12))
                    .clipShape(RoundedRectangle(cornerRadius: 16 * scale))
            }.frame(width: 100 * scale)
        }.buttonStyle(.plain)
    }

    private func startPodiumAnimation() {
        podiumAnimationTask?.cancel()
        let ranks = viewModel.data?.items.prefix(3).map(\.rank) ?? []
        guard !ranks.isEmpty else { return }

        if reduceMotion {
            podiumProgress = Dictionary(uniqueKeysWithValues: ranks.map { ($0, 1) })
            return
        }

        podiumProgress = Dictionary(uniqueKeysWithValues: ranks.map { ($0, 0) })
        let animationOrder = [2, 1, 3].filter(ranks.contains)

        podiumAnimationTask = Task { @MainActor in
            for rank in animationOrder {
                guard !Task.isCancelled else { return }
                withAnimation(.easeOut(duration: 0.72)) {
                    podiumProgress[rank] = 1
                }
                try? await Task.sleep(nanoseconds: 130_000_000)
            }
        }
    }

    private func rankingList(scale: CGFloat) -> some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                ForEach((viewModel.data?.items ?? []).filter { $0.rank > 3 }) { player in
                    RankingListRow(
                        rank: player.rank,
                        name: player.name,
                        detail: player.department,
                        count: "\(player.loanCount)권",
                        scale: scale,
                        action: { selectedPlayer = player }
                    )
                    Divider().padding(.horizontal, 21 * scale)
                }
            }
        }
        .frame(width: 342 * scale, height: 290 * scale)
        .background(Color.white).clipShape(RoundedRectangle(cornerRadius: 16 * scale))
        .shadow(color: .black.opacity(0.15), radius: 8 * scale, x: scale, y: scale)
    }

    private func playerProfile(_ player: ReaderRanking) -> some View {
        NavigationStack {
            VStack(spacing: 18) {
                ProfileAvatar(size: 88)
                Text(player.name).font(FeatureFontFamily.Pretendard.bold.swiftUIFont(size: 24))
                Text(player.department).foregroundColor(.secondary)
                Text("연간 대출 \(player.loanCount)권").foregroundColor(FeatureAsset.Color.buttonColor.swiftUIColor)
            }
            .navigationTitle("프로필").navigationBarTitleDisplayMode(.inline)
            .toolbar { ToolbarItem(placement: .topBarTrailing) { Button("닫기") { selectedPlayer = nil } } }
        }
    }
}

private struct AnimatedLoanCount: Animatable, View {
    var value: Double

    var animatableData: Double {
        get { value }
        set { value = newValue }
    }

    var body: some View {
        Text("\(max(0, Int(value.rounded()))) 권")
    }
}

struct RankingView_Previews: PreviewProvider { static var previews: some View { RankingView().previewDevice("iPhone 16") } }
