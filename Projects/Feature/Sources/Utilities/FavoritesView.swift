import SwiftUI

public struct FavoritesView: View {
    @State private var books = ["클린 코드", "클린 아키텍처", "클린 코더", "클린 소프트웨어"]
    private let onBack: () -> Void
    public init(onBack: @escaping () -> Void = {}) { self.onBack = onBack }
    public var body: some View {
        GeometryReader { geo in
            let scale = geo.size.width / 392
            ZStack(alignment: .topLeading) {
                Color.white
                AppBackButton(scale: scale, action: onBack).offset(x: 25 * scale, y: 64 * scale)
                Text("즐겨찾기").font(FeatureFontFamily.Pretendard.bold.swiftUIFont(size: 16 * scale)).offset(x: 168 * scale, y: 74 * scale)
                Text("관심 도서 \(books.count)권 · 대출 가능해지면 알려드려요").font(FeatureFontFamily.Pretendard.semiBold.swiftUIFont(size: 12 * scale)).foregroundColor(Color(red: 154/255, green: 154/255, blue: 161/255)).offset(x: 24 * scale, y: 116 * scale)
                VStack(spacing: 16 * scale) {
                    ForEach(books, id: \.self) { book in FavoriteBookRow(title: book, scale: scale, action: { books.removeAll { $0 == book } }) }
                }.offset(x: 24 * scale, y: 158 * scale)
            }.frame(width: geo.size.width, height: geo.size.height, alignment: .topLeading)
        }.ignoresSafeArea()
    }
}

struct FavoritesView_Previews: PreviewProvider { static var previews: some View { FavoritesView().previewDevice("iPhone 16") } }
