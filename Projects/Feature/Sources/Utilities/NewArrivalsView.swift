import SwiftUI
import Service

public struct NewArrivalsView: View {
    @StateObject private var viewModel: NewBooksViewModel
    private let onDismiss: () -> Void
    private let onShowBookDetail: (Int) -> Void
    private let showsDismissButton: Bool

    public init(booksService: BooksService = BooksService(), showsDismissButton: Bool = false, onDismiss: @escaping () -> Void = {}, onShowBookDetail: @escaping (Int) -> Void = { _ in }) {
        _viewModel = StateObject(wrappedValue: NewBooksViewModel(service: booksService))
        self.showsDismissButton = showsDismissButton; self.onDismiss = onDismiss; self.onShowBookDetail = onShowBookDetail
    }
    public var body: some View {
        GeometryReader { geo in
            let scale = geo.size.width / 392
            ScrollView {
                VStack(alignment: .leading, spacing: 24 * scale) {
                    if showsDismissButton { AppBackButton(scale: scale, action: onDismiss) }
                    Text("최근 새로 들어온 도서").font(FeatureFontFamily.Pretendard.medium.swiftUIFont(size: 20 * scale))
                    content(scale: scale)
                }.padding(.horizontal, 32 * scale).padding(.top, 56 * scale)
            }
        }.background(Color.white).ignoresSafeArea().task { await viewModel.load() }
    }

    @ViewBuilder private func content(scale: CGFloat) -> some View {
        if viewModel.isLoading && viewModel.books.isEmpty { ProgressView().frame(maxWidth: .infinity).padding(.top, 180 * scale) }
        else if let error = viewModel.errorMessage { VStack { Text(error); Button("재시도") { Task { await viewModel.load() } } }.frame(maxWidth: .infinity).padding(.top, 140 * scale) }
        else if viewModel.books.isEmpty { Text("최근 등록된 도서가 없어요").foregroundColor(.secondary).frame(maxWidth: .infinity).padding(.top, 160 * scale) }
        else {
            LazyVGrid(columns: [GridItem(.flexible(), spacing: 32 * scale), GridItem(.flexible())], spacing: 36 * scale) {
                ForEach(viewModel.books) { book in
                    Button { onShowBookDetail(book.bookId) } label: {
                        VStack(alignment: .leading, spacing: 8 * scale) { BookCoverView(urlString: book.coverImageUrl, width: 132 * scale, height: 177 * scale); Text(book.title).font(FeatureFontFamily.Pretendard.semiBold.swiftUIFont(size: 13 * scale)).lineLimit(2); Text(book.author).font(FeatureFontFamily.Pretendard.medium.swiftUIFont(size: 11 * scale)).foregroundColor(.secondary) }
                    }.buttonStyle(.plain).foregroundColor(.black).onAppear { Task { await viewModel.loadMoreIfNeeded(currentBook: book) } }
                }
            }
        }
    }
}

struct NewArrivalsView_Previews: PreviewProvider { static var previews: some View { NewArrivalsView().previewDevice("iPhone 16") } }
