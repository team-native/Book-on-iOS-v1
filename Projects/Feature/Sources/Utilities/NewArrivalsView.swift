import SwiftUI

public struct NewArrivalsView: View {
    @State private var isLoading = true
    private let onDismiss: () -> Void
    private let showsDismissButton: Bool

    public init(
        showsDismissButton: Bool = false,
        onDismiss: @escaping () -> Void = {}
    ) {
        self.showsDismissButton = showsDismissButton
        self.onDismiss = onDismiss
    }
    public var body: some View {
        GeometryReader { geo in
            let scale = geo.size.width / 392
            ScrollView(showsIndicators: true) {
                VStack(alignment: .leading, spacing: 0) {
                    if showsDismissButton {
                        AppBackButton(scale: scale, action: onDismiss)
                            .padding(.leading, 23 * scale)
                            .padding(.top, 56 * scale)
                    }
                    Text("최근 새로 들어온 도서")
                        .font(FeatureFontFamily.Pretendard.medium.swiftUIFont(size: 20 * scale))
                        .padding(.top, showsDismissButton ? 30 * scale : 90 * scale)
                        .padding(.leading, 44 * scale)
                    if isLoading {
                        bookGrid(scale: scale, isAnimating: true)
                    } else {
                        bookGrid(scale: scale, isAnimating: false)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .background(Color.white)
        .ignoresSafeArea()
        .task {
            try? await Task.sleep(nanoseconds: 1_000_000_000)
            isLoading = false
        }
    }

    private func bookGrid(scale: CGFloat, isAnimating: Bool) -> some View {
        LazyVGrid(columns: [GridItem(.fixed(132 * scale), spacing: 40 * scale), GridItem(.fixed(132 * scale))], spacing: 85 * scale) {
            ForEach(0..<6, id: \.self) { _ in
                BookCardSkeleton(scale: scale, isAnimating: isAnimating)
            }
        }
        .frame(width: 304 * scale, alignment: .leading)
        .padding(.top, 39 * scale)
        .padding(.leading, 44 * scale)
    }
}

struct NewArrivalsView_Previews: PreviewProvider { static var previews: some View { NewArrivalsView().previewDevice("iPhone 16") } }
