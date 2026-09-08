import SwiftUI
import Service

public struct SearchView: View {
    @State private var query: String
    @State private var didSearch: Bool
    @State private var showsEmptyQueryAlert = false
    @StateObject private var viewModel: SearchBooksViewModel
    private let onShowBookDetail: (Int) -> Void
    private let showsDismissButton: Bool
    private let onDismiss: () -> Void

    public init(initialQuery: String = "", booksService: BooksService = BooksService(), onShowBookDetail: @escaping (Int) -> Void = { _ in }, showsDismissButton: Bool = false, onDismiss: @escaping () -> Void = {}) {
        let value = initialQuery.trimmingCharacters(in: .whitespacesAndNewlines)
        _query = State(initialValue: value); _didSearch = State(initialValue: !value.isEmpty)
        _viewModel = StateObject(wrappedValue: SearchBooksViewModel(service: booksService))
        self.onShowBookDetail = onShowBookDetail; self.showsDismissButton = showsDismissButton; self.onDismiss = onDismiss
    }

    public var body: some View {
        GeometryReader { geo in
            let scale = geo.size.width / 392
            ZStack(alignment: .topLeading) {
                Color.white
                Text("검색").font(FeatureFontFamily.Pretendard.bold.swiftUIFont(size: 28 * scale)).offset(x: 23 * scale, y: 62 * scale)
                if showsDismissButton { AppBackButton(scale: scale, action: onDismiss).offset(x: 330 * scale, y: 62 * scale) }
                BookSearchField(text: $query, width: 344, scale: scale, onSubmit: performSearch, onClear: query.isEmpty ? nil : { query = ""; didSearch = false }, onSearch: performSearch)
                    .offset(x: 24 * scale, y: 123 * scale)
                content(scale: scale).offset(x: 24 * scale, y: 190 * scale)
            }
        }.ignoresSafeArea()
        .task { if didSearch { await viewModel.search(query) } }
        .alert("검색할 자료명을 입력해주세요.", isPresented: $showsEmptyQueryAlert) {
            Button("확인", role: .cancel) {}
        }
    }

    @ViewBuilder private func content(scale: CGFloat) -> some View {
        if viewModel.isLoading && viewModel.books.isEmpty { ProgressView().frame(width: 344 * scale).padding(.top, 150 * scale) }
        else if let error = viewModel.errorMessage { VStack(spacing: 12) { Text(error); Button("재시도", action: performSearch) }.frame(width: 344 * scale).padding(.top, 120 * scale) }
        else if didSearch && !viewModel.books.isEmpty {
            ScrollView {
                VStack(alignment: .leading, spacing: 16 * scale) {
                    Text("‘\(query)’ 검색 결과 \(viewModel.books.count)건").font(FeatureFontFamily.Pretendard.semiBold.swiftUIFont(size: 12 * scale)).foregroundColor(FeatureAsset.Color.textDescription.swiftUIColor)
                    ForEach(viewModel.books) { book in
                        SearchBookRow(book: book, scale: scale) { onShowBookDetail(book.bookId) }
                            .onAppear { Task { await viewModel.loadMoreIfNeeded(currentBook: book) } }
                    }
                }.padding(.bottom, 40 * scale)
            }.frame(width: 344 * scale, height: 650 * scale)
        } else { emptyState(scale: scale) }
    }

    private func performSearch() {
        let keyword = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !keyword.isEmpty else {
            didSearch = false
            showsEmptyQueryAlert = true
            return
        }
        query = keyword
        didSearch = true
        Task { await viewModel.search(keyword) }
    }

    private func emptyState(scale: CGFloat) -> some View {
        VStack(spacing: 16 * scale) { Image(systemName: "book.closed").font(.system(size: 62 * scale, weight: .thin)); Text(didSearch ? "검색된 책이 없어요\n다른 검색어를 입력해보세요" : "책 제목을 검색해보세요").multilineTextAlignment(.center) }
            .foregroundColor(FeatureAsset.Color.textDescription.swiftUIColor).frame(width: 344 * scale).padding(.top, 150 * scale)
    }
}

private struct SearchBookRow: View {
    let book: BookSummary; let scale: CGFloat; let action: () -> Void
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16 * scale) {
                BookCoverView(urlString: book.coverImageUrl, width: 54 * scale, height: 68 * scale)
                VStack(alignment: .leading, spacing: 7 * scale) { Text(book.title).font(FeatureFontFamily.Pretendard.extraBold.swiftUIFont(size: 15 * scale)); Text("\(book.author) · \(book.libraryNumber)").font(FeatureFontFamily.Pretendard.regular.swiftUIFont(size: 12 * scale)).foregroundColor(FeatureAsset.Color.textDescription.swiftUIColor) }
                Spacer(); BookStatusBadge(title: "재고 \(book.availableQuantity)권", scale: scale).opacity(book.loanAvailable ? 1 : 0.45)
            }.padding(.horizontal, 16 * scale).frame(width: 344 * scale, height: 88 * scale).background(Color.white).clipShape(RoundedRectangle(cornerRadius: 16 * scale)).shadow(color: .black.opacity(0.15), radius: 10 * scale, x: scale, y: scale)
        }.buttonStyle(.plain).foregroundColor(.black)
    }
}

struct SearchView_Previews: PreviewProvider { static var previews: some View { SearchView().previewDevice("iPhone 16") } }
