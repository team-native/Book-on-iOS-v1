import SwiftUI
import Service

public struct LibraryView: View {
    @State private var selectedCategory: BookCategory?
    @State private var sort = "POPULAR"
    @StateObject private var viewModel: LibraryViewModel
    private let onSelectTab: (BottomTabBar.Item) -> Void
    private let onShowBookDetail: (Int) -> Void

    public init(
        booksService: BooksService = BooksService(),
        onSelectTab: @escaping (BottomTabBar.Item) -> Void = { _ in },
        onShowBookDetail: @escaping (Int) -> Void = { _ in }
    ) {
        _viewModel = StateObject(wrappedValue: LibraryViewModel(service: booksService))
        self.onSelectTab = onSelectTab
        self.onShowBookDetail = onShowBookDetail
    }

    public var body: some View {
        GeometryReader { geo in
            let scale = geo.size.width / 392
            ZStack(alignment: .bottom) {
                Color.white.ignoresSafeArea()
                ScrollView {
                    VStack(alignment: .leading, spacing: 18 * scale) {
                        HStack {
                            Text("도서실").font(FeatureFontFamily.Pretendard.bold.swiftUIFont(size: 28 * scale))
                            Spacer()
                            sortControl(scale: scale)
                        }
                        categoryScroll(scale: scale)
                        content(scale: scale)
                    }
                    .padding(.horizontal, 23 * scale)
                    .padding(.top, 70 * scale)
                    .padding(.bottom, 110 * scale)
                }
            }
        }
        .ignoresSafeArea()
        .task { await reload() }
    }

    private func categoryScroll(scale: CGFloat) -> some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10 * scale) {
                FilterChip(title: "전체", isSelected: selectedCategory == nil, scale: scale) {
                    selectedCategory = nil; Task { await reload() }
                }
                ForEach(viewModel.categories) { category in
                    FilterChip(title: category.name, isSelected: selectedCategory?.id == category.id, scale: scale) {
                        selectedCategory = category; Task { await reload() }
                    }
                }
            }
        }
    }

    @ViewBuilder private func content(scale: CGFloat) -> some View {
        if viewModel.isLoading && viewModel.books.isEmpty {
            ProgressView().frame(maxWidth: .infinity).padding(.top, 160 * scale)
        } else if let error = viewModel.errorMessage, viewModel.books.isEmpty {
            retryView(error, scale: scale)
        } else if viewModel.books.isEmpty {
            Text("등록된 도서가 없어요").frame(maxWidth: .infinity).padding(.top, 160 * scale).foregroundColor(.secondary)
        } else {
            LazyVGrid(columns: [GridItem(.flexible(), spacing: 20 * scale), GridItem(.flexible())], spacing: 30 * scale) {
                ForEach(viewModel.books) { book in
                    Button { onShowBookDetail(book.bookId) } label: {
                        VStack(alignment: .leading, spacing: 6 * scale) {
                            BookCoverView(urlString: book.coverImageUrl, width: 166 * scale, height: 234 * scale)
                            Text(book.title).font(FeatureFontFamily.Pretendard.semiBold.swiftUIFont(size: 14 * scale)).lineLimit(2).foregroundColor(.black)
                            Text("\(book.author) · 재고 \(book.availableQuantity)권").font(FeatureFontFamily.Pretendard.medium.swiftUIFont(size: 10 * scale)).foregroundColor(.secondary).lineLimit(1)
                        }
                    }.buttonStyle(.plain).onAppear { Task { await viewModel.loadMoreIfNeeded(currentBook: book) } }
                }
            }
        }
    }

    private func sortControl(scale: CGFloat) -> some View {
        HStack(spacing: 0) {
            sortButton("인기순", value: "POPULAR", scale: scale)
            sortButton("신간순", value: "NEW", scale: scale)
        }.padding(3 * scale).background(Color(.secondarySystemBackground)).clipShape(RoundedRectangle(cornerRadius: 10 * scale))
    }

    private func sortButton(_ title: String, value: String, scale: CGFloat) -> some View {
        Button(title) { sort = value; Task { await reload() } }
            .font(FeatureFontFamily.Pretendard.semiBold.swiftUIFont(size: 12 * scale))
            .foregroundColor(sort == value ? .black : .secondary)
            .frame(width: 60 * scale, height: 30 * scale)
            .background(sort == value ? Color.white : Color.clear)
            .clipShape(RoundedRectangle(cornerRadius: 8 * scale))
    }

    private func retryView(_ message: String, scale: CGFloat) -> some View {
        VStack(spacing: 12 * scale) {
            Text(message).multilineTextAlignment(.center)
            Button("재시도") { Task { await reload() } }
        }.font(FeatureFontFamily.Pretendard.medium.swiftUIFont(size: 12 * scale)).frame(maxWidth: .infinity).padding(.top, 130 * scale)
    }

    private func reload() async { await viewModel.load(sort: sort, category: selectedCategory?.code) }
}

struct LibraryView_Previews: PreviewProvider { static var previews: some View { LibraryView().previewDevice("iPhone 16") } }
