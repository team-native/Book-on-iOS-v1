import SwiftUI

public struct SearchView: View {
    @State private var query = ""
    @State private var didSearch = false
    private let onShowBookDetail: () -> Void
    private let showsDismissButton: Bool
    private let onDismiss: () -> Void

    private var hasResults: Bool { didSearch && query.localizedCaseInsensitiveContains("클린") }

    public init(
        onShowBookDetail: @escaping () -> Void = {},
        showsDismissButton: Bool = false,
        onDismiss: @escaping () -> Void = {}
    ) {
        self.onShowBookDetail = onShowBookDetail
        self.showsDismissButton = showsDismissButton
        self.onDismiss = onDismiss
    }

    public var body: some View {
        GeometryReader { geo in
            let scale = geo.size.width / 392

            ZStack(alignment: .topLeading) {
                Color.white

                Text("검색")
                    .font(FeatureFontFamily.Pretendard.bold.swiftUIFont(size: 28 * scale))
                    .foregroundColor(.black)
                    .offset(x: 23 * scale, y: 62 * scale)

                if showsDismissButton {
                    AppBackButton(scale: scale, action: onDismiss)
                        .offset(x: 330 * scale, y: 62 * scale)
                }

                BookSearchField(
                    text: $query,
                    width: 344,
                    scale: scale,
                    onSubmit: { didSearch = true },
                    onClear: query.isEmpty ? nil : {
                        query = ""
                        didSearch = false
                    },
                    onSearch: { didSearch = true }
                )
                .offset(x: 24 * scale, y: 123 * scale)

                if hasResults {
                    results(scale: scale)
                        .offset(x: 24 * scale, y: 190 * scale)
                } else {
                    emptyState(scale: scale)
                        .frame(width: geo.size.width, height: geo.size.height)
                }
            }
            .frame(width: geo.size.width, height: geo.size.height, alignment: .topLeading)
        }
        .ignoresSafeArea()
    }

    private func results(scale: CGFloat) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("‘클린’ 검색 결과 4건 · 제목 · 도서관 번호")
                .font(FeatureFontFamily.Pretendard.semiBold.swiftUIFont(size: 12 * scale))
                .foregroundColor(Color(red: 154/255, green: 154/255, blue: 161/255))

            VStack(spacing: 16 * scale) {
                SearchBookRow(title: "클린 코드", stock: 2, scale: scale, action: onShowBookDetail)
                SearchBookRow(title: "클린 아키텍처", stock: 0, scale: scale, action: onShowBookDetail)
                SearchBookRow(title: "클린 코더", stock: 1, scale: scale, action: onShowBookDetail)
                SearchBookRow(title: "클린 소프트웨어", stock: 3, scale: scale, action: onShowBookDetail)
            }
            .padding(.top, 22 * scale)
        }
    }

    private func emptyState(scale: CGFloat) -> some View {
        VStack(spacing: 16 * scale) {
            Image(systemName: "book.closed")
                .font(.system(size: 62 * scale, weight: .thin))
                .foregroundColor(Color(red: 176/255, green: 176/255, blue: 181/255))
            Text("검색된 책이 없어요\n다른 검색어를 입력해보세요")
                .font(FeatureFontFamily.Pretendard.semiBold.swiftUIFont(size: 15 * scale))
                .foregroundColor(Color(red: 64/255, green: 64/255, blue: 64/255))
                .multilineTextAlignment(.center)
                .lineSpacing(4 * scale)
        }
        .padding(.top, 220 * scale)
    }
}

private struct SearchBookRow: View {
    let title: String
    let stock: Int
    let scale: CGFloat
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 16 * scale) {
                BookThumbnail(width: 54, height: 68, scale: scale, action: {})
                    .background(Color(red: 241/255, green: 241/255, blue: 244/255))
                    .clipShape(RoundedRectangle(cornerRadius: 9 * scale))
                VStack(alignment: .leading, spacing: 7 * scale) {
                    Text(title).font(FeatureFontFamily.Pretendard.extraBold.swiftUIFont(size: 15 * scale)).foregroundColor(.black)
                    Text("로버트 C. 마틴 · 005.1")
                        .font(FeatureFontFamily.Pretendard.regular.swiftUIFont(size: 12 * scale))
                        .foregroundColor(Color(red: 154/255, green: 154/255, blue: 161/255))
                }
                Spacer()
                BookStatusBadge(title: "재고 \(stock)권", scale: scale)
                    .opacity(stock == 0 ? 0.45 : 1)
            }
            .padding(.horizontal, 16 * scale)
            .frame(width: 344 * scale, height: 88 * scale)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 16 * scale))
            .shadow(color: .black.opacity(0.15), radius: 10 * scale, x: scale, y: scale)
        }
        .buttonStyle(.plain)
    }
}

struct SearchView_Previews: PreviewProvider {
    static var previews: some View { SearchView().previewDevice("iPhone 16") }
}
