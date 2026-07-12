import SwiftUI

public struct NewArrivalsView: View {
    @State private var isLoading = true
    public init() {}
    public var body: some View {
        GeometryReader { geo in
            let scale = geo.size.width / 392
            ScrollView(showsIndicators: true) {
                VStack(alignment: .leading, spacing: 0) {
                    Text("최근 새로 들어온 도서")
                        .font(FeatureFontFamily.Pretendard.medium.swiftUIFont(size: 20 * scale))
                        .padding(.top, 90 * scale)
                        .padding(.leading, 44 * scale)
                    if isLoading {
                        LazyVGrid(columns: [GridItem(.fixed(132 * scale), spacing: 40 * scale), GridItem(.fixed(132 * scale))], spacing: 85 * scale) {
                            ForEach(0..<6, id: \.self) { _ in BookCardSkeleton(scale: scale) }
                        }
                        .padding(.top, 39 * scale)
                        .padding(.leading, 44 * scale)
                    } else {
                        Color.clear.frame(height: max(geo.size.height - (130 * scale), 0))
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
}

struct NewArrivalsView_Previews: PreviewProvider { static var previews: some View { NewArrivalsView().previewDevice("iPhone 16") } }
