import SwiftUI

public struct RankingView: View {
    @State private var refreshCount = 0
    @State private var selectedPlayer: RankingPlayer?
    private let onSelectTab: (BottomTabBar.Item) -> Void

    public init(onSelectTab: @escaping (BottomTabBar.Item) -> Void = { _ in }) {
        self.onSelectTab = onSelectTab
    }
    public var body: some View {
        GeometryReader { geo in
            let scale = geo.size.width / 392
            ZStack(alignment: .topLeading) {
                Color.white
                Text("다독왕 랭킹").font(FeatureFontFamily.Pretendard.bold.swiftUIFont(size: 28 * scale)).offset(x: 26 * scale, y: 69 * scale)
                Text("2026년 · 대출 권수 기준 · 매년 1월 1일 초기화").font(FeatureFontFamily.Pretendard.medium.swiftUIFont(size: 14 * scale)).foregroundColor(Color(red: 154/255, green: 154/255, blue: 161/255)).offset(x: 26 * scale, y: 110 * scale)
                podium(scale: scale).offset(x: 28 * scale, y: 166 * scale)
                rankingList(scale: scale).offset(x: 25 * scale, y: 406 * scale)
                BottomTabBar(selected: .ranking, scale: scale, action: onSelectTab).frame(width: 392 * scale, height: 89 * scale).offset(y: 763 * scale)
            }.frame(width: geo.size.width, height: geo.size.height, alignment: .topLeading)
        }
        .ignoresSafeArea()
        .onReceive(Timer.publish(every: 5, on: .main, in: .common).autoconnect()) { _ in
            withAnimation(.easeInOut(duration: 0.3)) { refreshCount += 1 }
        }
        .sheet(item: $selectedPlayer) { PlayerProfileView(player: $0) }
    }
    private func podium(scale: CGFloat) -> some View {
        ZStack(alignment: .bottomLeading) {
            podiumPerson(player: .init(name: "김길동", grade: "2학년", loans: 46 + refreshCount % 2), rank: 2, height: 76, color: [Color(red: 240/255, green: 240/255, blue: 243/255), Color(red: 221/255, green: 223/255, blue: 230/255)], scale: scale).offset(x: 0, y: 0)
            podiumPerson(player: .init(name: "홍길동", grade: "2학년", loans: 49 + refreshCount), rank: 1, height: 96, color: [Color(red: 226/255, green: 236/255, blue: 205/255), Color(red: 199/255, green: 220/255, blue: 161/255)], scale: scale).offset(x: 116 * scale, y: 0)
            podiumPerson(player: .init(name: "이길동", grade: "1학년", loans: 45 + refreshCount % 3), rank: 3, height: 62, color: [Color(red: 243/255, green: 233/255, blue: 221/255), Color(red: 228/255, green: 210/255, blue: 190/255)], scale: scale).offset(x: 232 * scale, y: 0)
        }.frame(width: 332 * scale, height: 222 * scale, alignment: .bottomLeading)
    }
    private func podiumPerson(player: RankingPlayer, rank: Int, height: CGFloat, color: [Color], scale: CGFloat) -> some View {
        Button { selectedPlayer = player } label: { VStack(spacing: 3 * scale) {
            ProfileAvatar(size: rank == 1 ? 64 : 52, scale: scale)
            Text(player.name).font(FeatureFontFamily.Pretendard.bold.swiftUIFont(size: 14 * scale))
            Text("\(player.loans) 권").font(FeatureFontFamily.Pretendard.medium.swiftUIFont(size: 12 * scale)).foregroundColor(rank == 1 ? FeatureAsset.Color.buttonColor.swiftUIColor : Color(red: 154/255, green: 154/255, blue: 161/255))
            Spacer(minLength: 10 * scale)
            Text("\(rank)").font(FeatureFontFamily.Pretendard.bold.swiftUIFont(size: 20 * scale)).foregroundColor(rank == 1 ? Color(red: 79/255, green: 112/255, blue: 22/255) : Color(red: 155/255, green: 161/255, blue: 173/255))
                .frame(width: 100 * scale, height: height * scale, alignment: .top).padding(.top, 12 * scale)
                .background(LinearGradient(colors: color, startPoint: .top, endPoint: .bottom)).clipShape(RoundedRectangle(cornerRadius: 16 * scale, style: .continuous))
        }.frame(width: 100 * scale) }.buttonStyle(.plain)
    }
    private func rankingList(scale: CGFloat) -> some View {
        VStack(spacing: 0) {
            RankingListRow(rank: 4, name: "정길동", detail: "2학년 · 소프트웨어 개발과", count: "\(31 + refreshCount % 2)권", scale: scale, action: { selectedPlayer = .init(name: "정길동", grade: "2학년 · 소프트웨어 개발과", loans: 31 + refreshCount % 2) })
            Divider().padding(.horizontal, 21 * scale)
            RankingListRow(rank: 5, name: "최길동", detail: "1학년 · AI과", count: "\(28 + refreshCount % 3)권", scale: scale, action: { selectedPlayer = .init(name: "최길동", grade: "1학년 · AI과", loans: 28 + refreshCount % 3) })
            Divider().padding(.horizontal, 21 * scale)
            RankingListRow(rank: 6, name: "한길동", detail: "2학년 · 소프트웨어 개발과", count: "\(20 + refreshCount % 2)권", scale: scale, action: { selectedPlayer = .init(name: "한길동", grade: "2학년 · 소프트웨어 개발과", loans: 20 + refreshCount % 2) })
        }.padding(.horizontal, 21 * scale).frame(width: 342 * scale, height: 192 * scale).background(Color.white).clipShape(RoundedRectangle(cornerRadius: 16 * scale)).shadow(color: .black.opacity(0.15), radius: 8 * scale, x: scale, y: scale)
    }
}

private struct RankingPlayer: Identifiable {
    let id = UUID()
    let name: String
    let grade: String
    let loans: Int
}

private struct PlayerProfileView: View {
    let player: RankingPlayer
    @Environment(\.dismiss) private var dismiss
    var body: some View {
        NavigationStack {
            VStack(spacing: 18) {
                ProfileAvatar(size: 88)
                Text(player.name).font(FeatureFontFamily.Pretendard.bold.swiftUIFont(size: 24))
                Text(player.grade).foregroundColor(.secondary)
                Text("누적 대출 \(player.loans)권").font(FeatureFontFamily.Pretendard.semiBold.swiftUIFont(size: 16)).foregroundColor(FeatureAsset.Color.buttonColor.swiftUIColor)
            }
            .navigationTitle("프로필").navigationBarTitleDisplayMode(.inline)
            .toolbar { ToolbarItem(placement: .topBarTrailing) { Button("닫기") { dismiss() } } }
        }
    }
}

struct RankingView_Previews: PreviewProvider { static var previews: some View { RankingView().previewDevice("iPhone 16") } }
