import SwiftUI

public struct LibraryView: View {
    @State private var category = "전체"
    @State private var sortByPopularity = true
    private let categories = ["전체", "소설", "과학", "역사", "개발"]
    private let books = [("프로젝트 헤일메리", "앤디 위어"), ("괴테는 모든 것을 말했다", "스즈키 유이"), ("인간 실격", "다자이 오사무"), ("급류", "정대건")]

    public init() {}

    public var body: some View {
        GeometryReader { geo in
            let scale = geo.size.width / 392
            ZStack(alignment: .topLeading) {
                Color.white
                Text("도서실").font(FeatureFontFamily.Pretendard.bold.swiftUIFont(size: 28 * scale)).offset(x: 23 * scale, y: 70 * scale)
                sortControl(scale: scale).offset(x: 239 * scale, y: 63 * scale)
                HStack(spacing: 10 * scale) {
                    ForEach(categories, id: \.self) { title in
                        FilterChip(title: title, isSelected: category == title, scale: scale, action: { category = title })
                    }
                }.offset(x: 23 * scale, y: 118 * scale)
                bookGrid(scale: scale)
                    .offset(x: 23 * scale, y: 170 * scale)
                BottomTabBar(selected: .library, scale: scale, action: { _ in }).frame(width: 392 * scale, height: 89 * scale).offset(y: 763 * scale)
            }.frame(width: geo.size.width, height: geo.size.height, alignment: .topLeading)
        }.ignoresSafeArea()
    }

    private func sortControl(scale: CGFloat) -> some View {
        HStack(spacing: 0) {
            sortButton("인기순", selected: sortByPopularity, scale: scale) { sortByPopularity = true }
            sortButton("신간순", selected: !sortByPopularity, scale: scale) { sortByPopularity = false }
        }
        .frame(width: 130 * scale, height: 36 * scale).background(Color(red: 239/255, green: 239/255, blue: 242/255)).clipShape(RoundedRectangle(cornerRadius: 10 * scale))
    }

    private func bookGrid(scale: CGFloat) -> some View {
        ZStack(alignment: .topLeading) {
            LibraryBookCard(title: books[0].0, author: books[0].1, scale: scale)
            LibraryBookCard(title: books[1].0, author: books[1].1, scale: scale).offset(x: 186 * scale)
            LibraryBookCard(title: books[2].0, author: books[2].1, scale: scale).offset(y: 298 * scale)
            LibraryBookCard(title: books[3].0, author: books[3].1, scale: scale).offset(x: 186 * scale, y: 298 * scale)
        }
        .frame(width: 352 * scale, height: 532 * scale, alignment: .topLeading)
    }
    private func sortButton(_ title: String, selected: Bool, scale: CGFloat, action: @escaping () -> Void) -> some View {
        Button(action: action) { Text(title).font(FeatureFontFamily.Pretendard.semiBold.swiftUIFont(size: 12 * scale)).foregroundColor(selected ? .black : Color(red: 142/255, green: 142/255, blue: 147/255)).frame(width: 60 * scale, height: 30 * scale).background(selected ? Color.white : Color.clear).clipShape(RoundedRectangle(cornerRadius: 10 * scale)).shadow(color: .black.opacity(selected ? 0.15 : 0), radius: 4 * scale, x: scale, y: scale) }.buttonStyle(.plain)
    }
}

private struct LibraryBookCard: View {
    let title: String
    let author: String
    let scale: CGFloat
    var body: some View {
        Button(action: {}) {
            VStack(alignment: .leading, spacing: 0) {
                BookThumbnail(width: 166, height: 234, scale: scale, action: {})
                    .background(Color(red: 248/255, green: 248/255, blue: 248/255))
                    .clipShape(RoundedRectangle(cornerRadius: 8 * scale))
                    .shadow(color: .black.opacity(0.15), radius: 12 * scale, x: scale, y: scale)
                Text(title).font(FeatureFontFamily.Pretendard.semiBold.swiftUIFont(size: 14 * scale)).foregroundColor(.black).padding(.top, 10 * scale)
                Text("\(author) · 재고 2권").font(FeatureFontFamily.Pretendard.semiBold.swiftUIFont(size: 10 * scale)).foregroundColor(Color(red: 154/255, green: 154/255, blue: 161/255)).padding(.top, 3 * scale)
            }
        }.buttonStyle(.plain)
    }
}

struct LibraryView_Previews: PreviewProvider { static var previews: some View { LibraryView().previewDevice("iPhone 16") } }
