import SwiftUI
import Service

public struct FavoritesView: View {
    @StateObject private var viewModel: FavoritesViewModel
    private let onBack: () -> Void
    private let onShowBookDetail: (Int) -> Void

    public init(booksService: BooksService = BooksService(), onBack: @escaping () -> Void = {}, onShowBookDetail: @escaping (Int) -> Void = { _ in }) {
        _viewModel = StateObject(wrappedValue: FavoritesViewModel(service: booksService))
        self.onBack = onBack; self.onShowBookDetail = onShowBookDetail
    }

    public var body: some View {
        GeometryReader { geo in
            let scale = geo.size.width / 392
            ZStack(alignment: .topLeading) {
                Color.white
                AppBackButton(scale: scale, action: onBack).offset(x: 25 * scale, y: 64 * scale)
                Text("즐겨찾기").font(FeatureFontFamily.Pretendard.bold.swiftUIFont(size: 16 * scale)).frame(width: geo.size.width).offset(y: 74 * scale)
                Text("관심 도서 \(viewModel.books.count)권 · 대출 가능해지면 알려드려요").font(FeatureFontFamily.Pretendard.semiBold.swiftUIFont(size: 12 * scale)).foregroundColor(FeatureAsset.Color.textDescription.swiftUIColor).offset(x: 24 * scale, y: 116 * scale)
                content(scale: scale).offset(x: 24 * scale, y: 158 * scale)
            }
        }.ignoresSafeArea().task { await viewModel.load() }
    }

    @ViewBuilder private func content(scale: CGFloat) -> some View {
        if viewModel.isLoading && viewModel.books.isEmpty { ProgressView().frame(width: 344 * scale).padding(.top, 120 * scale) }
        else if let error = viewModel.errorMessage, viewModel.books.isEmpty { VStack { Text(error); Button("재시도") { Task { await viewModel.load() } } }.frame(width: 344 * scale).padding(.top, 100 * scale) }
        else if viewModel.books.isEmpty { Text("관심 도서가 없어요").foregroundColor(FeatureAsset.Color.textDescription.swiftUIColor).frame(width: 344 * scale).padding(.top, 120 * scale) }
        else {
            ScrollView {
                LazyVStack(spacing: 16 * scale) {
                    ForEach(viewModel.books) { book in
                        FavoriteBookRow(book: book, scale: scale, onSelect: { onShowBookDetail(book.bookId) }, onRemove: { Task { await viewModel.remove(book) } })
                            .onAppear { Task { await viewModel.loadMoreIfNeeded(currentBook: book) } }
                    }
                }.padding(.bottom, 40 * scale)
            }.frame(width: 344 * scale, height: 680 * scale)
        }
    }
}

struct FavoritesView_Previews: PreviewProvider { static var previews: some View { FavoritesView().previewDevice("iPhone 16") } }
