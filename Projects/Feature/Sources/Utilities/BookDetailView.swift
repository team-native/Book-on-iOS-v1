import SwiftUI
import Service

public struct BookDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel: BookDetailViewModel
    private let onBack: () -> Void

    public init(bookId: Int, booksService: BooksService = BooksService(), onBack: @escaping () -> Void = {}) {
        _viewModel = StateObject(wrappedValue: BookDetailViewModel(bookId: bookId, service: booksService))
        self.onBack = onBack
    }

    public var body: some View {
        GeometryReader { geo in
            let scale = geo.size.width / 392
            ZStack(alignment: .bottom) {
                Color.white.ignoresSafeArea()
                if viewModel.isLoading { ProgressView() }
                else if let book = viewModel.book { detail(book, scale: scale) }
                else { errorView(scale: scale) }
                AppBackButton(scale: scale, action: goBack).frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading).padding(.leading, 23 * scale).padding(.top, 64 * scale)
            }
        }.ignoresSafeArea().task { await viewModel.load() }
    }

    private func goBack() {
        onBack()
        dismiss()
    }

    private func detail(_ book: BookDetail, scale: CGFloat) -> some View {
        ZStack(alignment: .bottom) {
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    Color(red: 248/255, green: 255/255, blue: 232/255)
                        .frame(height: 420 * scale)
                        .overlay(
                            Interactive3DBookView(
                                coverImageURL: book.coverImageUrl,
                                width: 160 * scale,
                                height: 240 * scale
                            )
                        )
                    VStack(alignment: .leading, spacing: 8 * scale) {
                        Text(book.title).font(FeatureFontFamily.Pretendard.bold.swiftUIFont(size: 24 * scale))
                        Text(book.author).font(FeatureFontFamily.Pretendard.semiBold.swiftUIFont(size: 14 * scale)).foregroundColor(.secondary)
                        HStack(spacing: 12 * scale) {
                            BookDetailStat(title: "도서관 번호", value: book.libraryNumber, scale: scale)
                            BookDetailStat(title: "재고 수량", value: "\(book.availableQuantity)권", scale: scale)
                            BookDetailStat(title: "대출 여부", value: book.loanAvailable ? "가능" : "불가", isHighlighted: book.loanAvailable, scale: scale)
                        }.padding(.top, 18 * scale)
                        Text("책 소개").font(FeatureFontFamily.Pretendard.bold.swiftUIFont(size: 14 * scale)).padding(.top, 26 * scale)
                        Text(book.description ?? "등록된 책 소개가 없습니다.").font(FeatureFontFamily.Pretendard.medium.swiftUIFont(size: 12 * scale)).lineSpacing(4 * scale).padding(.top, 6 * scale)
                        if let error = viewModel.errorMessage { Text(error).font(.caption).foregroundColor(.red).padding(.top, 8 * scale) }
                    }.padding(.horizontal, 23 * scale).padding(.top, 20 * scale).padding(.bottom, 120 * scale)
                }
            }
            bottomBar(book: book, scale: scale)
        }
    }

    private func bottomBar(book: BookDetail, scale: CGFloat) -> some View {
        HStack(spacing: 24 * scale) {
            Button { Task { await viewModel.toggleFavorite() } } label: {
                if viewModel.isUpdatingFavorite { ProgressView() }
                else { Image(systemName: viewModel.isFavorite ? "heart.fill" : "heart").font(.system(size: 22 * scale)).foregroundColor(.red) }
            }.disabled(viewModel.isUpdatingFavorite)
            Button(viewModel.isRequestingLoan ? "대출 신청 중..." : (book.loanAvailable ? "대출 신청하기" : "대출 불가")) {
                Task { await viewModel.requestLoan() }
            }
                .font(FeatureFontFamily.Pretendard.semiBold.swiftUIFont(size: 16 * scale)).foregroundColor(.white)
                .frame(width: 275 * scale, height: 60 * scale)
                .background(book.loanAvailable ? FeatureAsset.Color.buttonColor.swiftUIColor : Color.gray.opacity(0.3))
                .clipShape(RoundedRectangle(cornerRadius: 20 * scale)).disabled(!book.loanAvailable || viewModel.isRequestingLoan)
        }.frame(maxWidth: .infinity).frame(height: 100 * scale).background(Color.white).overlay(alignment: .top) { Divider() }
        .alert("대출 신청 완료", isPresented: Binding(
            get: { viewModel.loanMessage != nil },
            set: { if !$0 { viewModel.loanMessage = nil } }
        )) {
            Button("확인", role: .cancel) {}
        } message: {
            Text(viewModel.loanMessage ?? "")
        }
    }

    private func errorView(scale: CGFloat) -> some View {
        VStack(spacing: 12 * scale) { Text(viewModel.errorMessage ?? "도서 정보를 불러오지 못했어요"); Button("재시도") { Task { await viewModel.load() } } }.multilineTextAlignment(.center)
    }
}

struct BookDetailView_Previews: PreviewProvider { static var previews: some View { BookDetailView(bookId: 1).previewDevice("iPhone 16") } }

private struct Interactive3DBookView: View {
    let coverImageURL: String?
    let width: CGFloat
    let height: CGFloat

    @State private var rotationX: Double = 0
    @State private var rotationY: Double = 0
    @State private var isDragging = false

    private var thickness: CGFloat { max(7, width * 0.065) }

    var body: some View {
        ZStack {
            // Pages and the back cover stay slightly offset behind the front cover,
            // making the book retain visible thickness while it is tilted.
            RoundedRectangle(cornerRadius: 5)
                .fill(Color(red: 0.72, green: 0.72, blue: 0.68))
                .frame(width: width, height: height)
                .offset(x: thickness, y: thickness * 0.45)

            RoundedRectangle(cornerRadius: 4)
                .fill(
                    LinearGradient(
                        colors: [.white, Color(red: 0.86, green: 0.84, blue: 0.76)],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .frame(width: width - thickness * 0.35, height: height - thickness * 0.7)
                .offset(x: thickness * 0.7, y: thickness * 0.35)

            BookCoverView(
                urlString: coverImageURL,
                width: width,
                height: height,
                cornerRadius: 6
            )
            .overlay(alignment: .leading) {
                LinearGradient(
                    colors: [.black.opacity(0.2), .clear],
                    startPoint: .leading,
                    endPoint: .trailing
                )
                .frame(width: max(8, width * 0.08))
                .clipShape(RoundedRectangle(cornerRadius: 6))
            }
        }
        .frame(width: width + thickness, height: height + thickness)
        .rotation3DEffect(.degrees(rotationX), axis: (x: 1, y: 0, z: 0), perspective: 0.65)
        .rotation3DEffect(.degrees(rotationY), axis: (x: 0, y: 1, z: 0), perspective: 0.65)
        .scaleEffect(isDragging ? 1.035 : 1)
        .shadow(
            color: .black.opacity(isDragging ? 0.3 : 0.2),
            radius: isDragging ? 18 : 10,
            x: CGFloat(rotationY / 3),
            y: 9 + CGFloat(rotationX / 5)
        )
        .contentShape(Rectangle())
        .gesture(dragGesture)
        .accessibilityLabel("3D 책 표지")
        .accessibilityHint("드래그하여 여러 방향으로 돌려볼 수 있습니다")
    }

    private var dragGesture: some Gesture {
        DragGesture(minimumDistance: 2)
            .onChanged { value in
                isDragging = true
                rotationY = limited(Double(value.translation.width / width) * 32)
                rotationX = limited(Double(-value.translation.height / height) * 32)
            }
            .onEnded { _ in
                withAnimation(.spring(response: 0.48, dampingFraction: 0.7)) {
                    rotationX = 0
                    rotationY = 0
                    isDragging = false
                }
            }
    }

    private func limited(_ angle: Double) -> Double {
        min(max(angle, -28), 28)
    }
}
