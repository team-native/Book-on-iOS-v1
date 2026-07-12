import SwiftUI

public struct MainHomeView: View {
    @State private var searchText = ""

    public init() {}

    public var body: some View {
        GeometryReader { geo in
            let scale = geo.size.width / 392

            ZStack(alignment: .topLeading) {
                Color(red: 251 / 255, green: 251 / 255, blue: 252 / 255)

                header(scale: scale)
                    .offset(x: 27 * scale, y: 66 * scale)

                searchField(scale: scale)
                    .offset(x: 27 * scale, y: 136 * scale)

                Button(action: {}) { noticeCard(scale: scale) }
                    .buttonStyle(.plain)
                    .offset(x: 28 * scale, y: 197 * scale)

                recommendationSection(scale: scale)
                    .offset(x: 27 * scale, y: 425 * scale)

                HStack(spacing: 0) {
                    Text("우리 학교 인기 책")
                        .font(FeatureFontFamily.Pretendard.bold.swiftUIFont(size: 14 * scale))
                    Spacer()
                    Button("더보기", action: {})
                        .font(FeatureFontFamily.Pretendard.semiBold.swiftUIFont(size: 12 * scale))
                        .foregroundColor(FeatureAsset.Color.buttonColor.swiftUIColor)
                }
                .frame(width: 338 * scale)
                .offset(x: 27 * scale, y: 742 * scale)

                bottomBar(scale: scale)
                    .offset(y: 763 * scale)
            }
            .frame(width: geo.size.width, height: geo.size.height, alignment: .topLeading)
        }
        .ignoresSafeArea()
    }

    private func header(scale: CGFloat) -> some View {
        ZStack(alignment: .topLeading) {
            VStack(alignment: .leading, spacing: 0) {
                Text("좋은 저녁이에요")
                    .font(FeatureFontFamily.Pretendard.semiBold.swiftUIFont(size: 12 * scale))
                    .foregroundColor(Color(red: 154 / 255, green: 154 / 255, blue: 161 / 255))
                    .frame(height: 20 * scale, alignment: .topLeading)
                Text("홍길동님")
                    .font(FeatureFontFamily.Pretendard.bold.swiftUIFont(size: 24 * scale))
                    .foregroundColor(.black)
                    .padding(.top, 5 * scale)
            }

            Button(action: {}) {
                Image(systemName: "bell")
                    .font(.system(size: 17 * scale, weight: .medium))
                    .foregroundColor(.black)
                    .frame(width: 32 * scale, height: 32 * scale)
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 7 * scale))
                    .shadow(color: .black.opacity(0.1), radius: 3 * scale, x: 1 * scale, y: 1 * scale)
                    .overlay(alignment: .topTrailing) {
                        Circle().fill(FeatureAsset.Color.buttonColor.swiftUIColor)
                            .frame(width: 4 * scale, height: 4 * scale)
                            .padding(7 * scale)
                    }
            }
            .buttonStyle(.plain)
            .offset(x: 256 * scale, y: 10 * scale)

            Button(action: {}) {
                Image(systemName: "person.fill")
                    .font(.system(size: 18 * scale))
                    .foregroundColor(.white)
                    .frame(width: 36 * scale, height: 36 * scale)
                    .background(Color(red: 216 / 255, green: 216 / 255, blue: 218 / 255))
                    .clipShape(Circle())
            }
            .buttonStyle(.plain)
                .offset(x: 304 * scale, y: 10 * scale)
        }
        .frame(width: 340 * scale, height: 50 * scale, alignment: .topLeading)
    }

    private func searchField(scale: CGFloat) -> some View {
        HStack {
            TextField("도서 찾기", text: $searchText)
                .font(FeatureFontFamily.Pretendard.regular.swiftUIFont(size: 12 * scale))
                .foregroundColor(.black)
                .onSubmit {}
            Spacer()
            Image(systemName: "magnifyingglass")
                .font(.system(size: 13 * scale, weight: .medium))
                .foregroundColor(Color(red: 183 / 255, green: 183 / 255, blue: 183 / 255))
        }
        .padding(.horizontal, 12 * scale)
        .frame(width: 340 * scale, height: 42 * scale)
        .background(Color.white)
        .overlay(RoundedRectangle(cornerRadius: 16 * scale).stroke(Color(red: 140 / 255, green: 140 / 255, blue: 140 / 255), lineWidth: 0.4 * scale))
        .clipShape(RoundedRectangle(cornerRadius: 16 * scale))
        .shadow(color: .black.opacity(0.1), radius: 3 * scale, x: 1 * scale, y: 1 * scale)
    }

    private func noticeCard(scale: CGFloat) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .center, spacing: 12 * scale) {
                Image(systemName: "speaker.wave.2")
                    .font(.system(size: 16 * scale, weight: .medium))
                    .foregroundColor(FeatureAsset.Color.buttonColor.swiftUIColor)
                    .frame(width: 36 * scale, height: 36 * scale)
                    .background(FeatureAsset.Color.buttonColor.swiftUIColor.opacity(0.13))
                    .clipShape(RoundedRectangle(cornerRadius: 10 * scale))
                VStack(alignment: .leading, spacing: 4 * scale) {
                    Text("도서부 공지").font(FeatureFontFamily.Pretendard.semiBold.swiftUIFont(size: 14 * scale))
                    Text("2026. 07. 01 · 도서부")
                        .font(FeatureFontFamily.Pretendard.medium.swiftUIFont(size: 10 * scale))
                        .foregroundColor(Color(red: 154 / 255, green: 154 / 255, blue: 161 / 255))
                }
                Spacer()
                Text("NEW")
                    .font(FeatureFontFamily.Pretendard.bold.swiftUIFont(size: 10 * scale))
                    .foregroundColor(.white)
                    .frame(width: 43 * scale, height: 21 * scale)
                    .background(FeatureAsset.Color.buttonColor.swiftUIColor)
                    .clipShape(RoundedRectangle(cornerRadius: 7 * scale))
            }
            Text("여름방학 도서 대출 기간 연장 안내")
                .font(FeatureFontFamily.Pretendard.bold.swiftUIFont(size: 16 * scale))
                .padding(.top, 18 * scale)
            Text("방학 기간 동안 1인당 최대 5권, 대출 기간이 14일로 연장됩니다.\n반납은 개학일 전까지 완료해 주세요.")
                .font(FeatureFontFamily.Pretendard.medium.swiftUIFont(size: 12 * scale))
                .foregroundColor(Color(red: 122 / 255, green: 122 / 255, blue: 129 / 255))
                .lineSpacing(4 * scale)
                .padding(.top, 12 * scale)
            HStack(spacing: 8 * scale) {
                Text("자세히 보기")
                Image(systemName: "chevron.right").font(.system(size: 8 * scale, weight: .bold))
            }
            .font(FeatureFontFamily.Pretendard.semiBold.swiftUIFont(size: 12 * scale))
            .foregroundColor(FeatureAsset.Color.buttonColor.swiftUIColor)
            .padding(.top, 11 * scale)
        }
        .padding(.horizontal, 18 * scale)
        .padding(.top, 18 * scale)
        .frame(width: 340 * scale, height: 184 * scale, alignment: .topLeading)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 20 * scale))
        .shadow(color: .black.opacity(0.15), radius: 10 * scale, x: 1 * scale, y: 1 * scale)
    }

    private func recommendationSection(scale: CGFloat) -> some View {
        ZStack(alignment: .topLeading) {
            Text("AI 추천")
                .font(FeatureFontFamily.Pretendard.semiBold.swiftUIFont(size: 20 * scale))
            Text("홍길동님의 대출 이력을 분석해 골랐어요")
                .font(FeatureFontFamily.Pretendard.medium.swiftUIFont(size: 12 * scale))
                .foregroundColor(Color(red: 154 / 255, green: 154 / 255, blue: 161 / 255))
                .offset(y: 26 * scale)
            HStack(spacing: 4 * scale) {
                Image(systemName: "sparkles").font(.system(size: 8 * scale))
                Text("AI")
            }
            .font(FeatureFontFamily.Pretendard.semiBold.swiftUIFont(size: 10 * scale))
            .foregroundColor(.white)
            .frame(width: 45 * scale, height: 22 * scale)
            .background(LinearGradient(colors: [Color(red: 147/255, green: 210/255, blue: 52/255), Color(red: 116/255, green: 163/255, blue: 46/255)], startPoint: .topLeading, endPoint: .bottomTrailing))
            .clipShape(RoundedRectangle(cornerRadius: 8 * scale))
            .offset(x: 68 * scale)
            Button("더보기", action: {})
                .font(FeatureFontFamily.Pretendard.semiBold.swiftUIFont(size: 12 * scale)).foregroundColor(FeatureAsset.Color.buttonColor.swiftUIColor).offset(x: 310 * scale, y: 2 * scale)
            bookSlot(title: "나미야 잡화점의 기적", author: "히가시노 게이고", scale: scale).offset(x: 1 * scale, y: 56 * scale)
            bookSlot(title: "아몬드", author: "손원평", scale: scale).offset(x: 152 * scale, y: 56 * scale)
            bookSlot(title: "오늘 밤, 세계에서\n이 사랑이 사라진다 해도", author: "이치조 미사키", scale: scale).offset(x: 302 * scale, y: 56 * scale)
        }
        .frame(width: 365 * scale, height: 292 * scale, alignment: .topLeading)
    }

    private func bookSlot(title: String, author: String, scale: CGFloat) -> some View {
        Button(action: {}) { VStack(alignment: .leading, spacing: 0) {
            Color.clear.frame(width: 94 * scale, height: 160 * scale)
            Text(title).font(FeatureFontFamily.Pretendard.semiBold.swiftUIFont(size: 12 * scale)).lineLimit(2).frame(width: 118 * scale, alignment: .leading).padding(.top, 18 * scale)
            Text(author).font(FeatureFontFamily.Pretendard.semiBold.swiftUIFont(size: 12 * scale)).foregroundColor(Color(red: 152/255, green: 152/255, blue: 159/255)).padding(.top, 4 * scale)
        } }
        .buttonStyle(.plain)
    }

    private func bottomBar(scale: CGFloat) -> some View {
        HStack(spacing: 0) {
            tab(icon: "house", title: "홈", selected: true, scale: scale)
            tab(icon: "chart.bar", title: "랭킹", selected: false, scale: scale)
            tab(icon: "rectangle.stack", title: "도서실", selected: false, scale: scale)
            tab(icon: "person", title: "마이", selected: false, scale: scale)
        }
        .frame(width: 392 * scale, height: 89 * scale)
        .background(Color(red: 254/255, green: 254/255, blue: 254/255))
        .overlay(alignment: .top) { Rectangle().fill(Color(red: 241/255, green: 241/255, blue: 240/255)).frame(height: 1) }
    }

    private func tab(icon: String, title: String, selected: Bool, scale: CGFloat) -> some View {
        Button(action: {}) { VStack(spacing: 5 * scale) {
            Image(systemName: icon).font(.system(size: 21 * scale, weight: selected ? .semibold : .regular))
            Text(title).font(FeatureFontFamily.Pretendard.semiBold.swiftUIFont(size: 10 * scale))
        }
        .foregroundColor(selected ? FeatureAsset.Color.buttonColor.swiftUIColor : Color(red: 176/255, green: 176/255, blue: 181/255))
        .frame(width: 98 * scale, height: 59 * scale)
        .padding(.top, 10 * scale) }
        .buttonStyle(.plain)
    }
}

struct MainHomeView_Previews: PreviewProvider {
    static var previews: some View { MainHomeView().previewDevice("iPhone 16") }
}
