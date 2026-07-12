import SwiftUI

public struct MyView: View {
    private let menuItems = ["비밀번호 변경", "대출 / 반납 내역", "즐겨찾기 목록", "알림 설정", "이용 안내"]
    @State private var isMarathonLinked = false
    @State private var showsNotificationSettings = false
    public init() {}
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
                        Text("홍길동 님").font(FeatureFontFamily.Pretendard.semiBold.swiftUIFont(size: 22 * scale))
                        Text("9기 · AI과").font(FeatureFontFamily.Pretendard.semiBold.swiftUIFont(size: 12 * scale)).foregroundColor(Color(red: 154/255, green: 154/255, blue: 161/255))
                    }
                }.offset(x: 23 * scale, y: 108 * scale)
                ProfileStatsCard(stats: [("대출 중", "3권"), ("반납 임박", "2권"), ("누적 대출", "23권")], scale: scale).frame(width: 346 * scale).offset(x: 23 * scale, y: 188 * scale)
                marathonCard(scale: scale).offset(x: 23 * scale, y: 288 * scale)
                VStack(spacing: 0) {
                    ForEach(menuItems, id: \.self) { item in
                        NavigationMenuRow(title: item, scale: scale, action: {
                            if item == "알림 설정" { showsNotificationSettings = true }
                        })
                        Divider()
                    }
                    NavigationMenuRow(title: "로그아웃", isDestructive: true, scale: scale, action: {})
                }.frame(width: 346 * scale).offset(x: 23 * scale, y: 426 * scale)
                Text("© 2026 Native").font(FeatureFontFamily.Pretendard.semiBold.swiftUIFont(size: 10 * scale)).foregroundColor(Color(red: 199/255, green: 199/255, blue: 204/255)).offset(x: 19 * scale, y: 740 * scale)
                BottomTabBar(selected: .my, scale: scale, action: { _ in }).frame(width: 392 * scale, height: 89 * scale).offset(y: 763 * scale)
            }.frame(width: geo.size.width, height: geo.size.height, alignment: .topLeading)
        }
        .ignoresSafeArea()
        .sheet(isPresented: $showsNotificationSettings) { NotificationSettingsView() }
    }
    private func marathonCard(scale: CGFloat) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Text("🏃  2026 독서마라톤").font(FeatureFontFamily.Pretendard.bold.swiftUIFont(size: 14 * scale))
                Spacer()
                if isMarathonLinked {
                    Text("참여 중").font(FeatureFontFamily.Pretendard.bold.swiftUIFont(size: 10 * scale)).foregroundColor(FeatureAsset.Color.buttonColor.swiftUIColor).padding(.horizontal, 9 * scale).padding(.vertical, 5 * scale).background(FeatureAsset.Color.buttonColor.swiftUIColor.opacity(0.12)).clipShape(RoundedRectangle(cornerRadius: 6 * scale))
                } else {
                    Toggle("", isOn: $isMarathonLinked)
                        .labelsHidden()
                        .tint(FeatureAsset.Color.buttonColor.swiftUIColor)
                        .scaleEffect(0.82 * scale)
                }
            }
            if isMarathonLinked {
                HStack { Text("거북이 코스 · 42 / 50권"); Spacer(); Text("84%").foregroundColor(FeatureAsset.Color.buttonColor.swiftUIColor) }.font(FeatureFontFamily.Pretendard.semiBold.swiftUIFont(size: 12 * scale)).foregroundColor(Color(red: 142/255, green: 142/255, blue: 147/255)).padding(.top, 15 * scale)
                GeometryReader { p in ZStack(alignment: .leading) { Capsule().fill(Color(red: 217/255, green: 217/255, blue: 217/255)); Capsule().fill(FeatureAsset.Color.buttonColor.swiftUIColor).frame(width: p.size.width * 0.84) } }.frame(height: 8 * scale).padding(.top, 14 * scale)
                Text("완주까지 8권 남았어요 · 상위 12%").font(FeatureFontFamily.Pretendard.semiBold.swiftUIFont(size: 12 * scale)).foregroundColor(Color(red: 142/255, green: 142/255, blue: 147/255)).padding(.top, 12 * scale)
            } else {
                Text("아직 연동하지 않았어요").font(FeatureFontFamily.Pretendard.semiBold.swiftUIFont(size: 12 * scale)).foregroundColor(Color(red: 142/255, green: 142/255, blue: 147/255)).padding(.top, 16 * scale)
                Text("토글을 켜면 독서마라톤 계정을 연동할 수 있어요")
                    .font(FeatureFontFamily.Pretendard.semiBold.swiftUIFont(size: 12 * scale))
                    .foregroundColor(Color(red: 142/255, green: 142/255, blue: 147/255))
                    .padding(.top, 14 * scale)
            }
        }.padding(18 * scale).frame(width: 346 * scale, height: 126 * scale, alignment: .topLeading).background(Color(red: 251/255, green: 251/255, blue: 252/255)).overlay(RoundedRectangle(cornerRadius: 16 * scale).stroke(Color(red: 243/255, green: 243/255, blue: 245/255))).clipShape(RoundedRectangle(cornerRadius: 16 * scale))
    }
}

struct MyView_Previews: PreviewProvider { static var previews: some View { MyView().previewDevice("iPhone 16") } }
