import SwiftUI

public struct BookDetailView: View {
    @State private var stock = 2
    @State private var isFavorite = false
    private let onBack: () -> Void
    public init(onBack: @escaping () -> Void = {}) { self.onBack = onBack }
    public var body: some View {
        GeometryReader { geo in
            let scale = geo.size.width / 392
            ZStack(alignment: .topLeading) {
                Color.white
                Color(red: 248/255, green: 255/255, blue: 232/255).frame(height: 420 * scale).offset(y: 50 * scale)
                AppBackButton(scale: scale, action: onBack).offset(x: 23 * scale, y: 64 * scale)
                BookThumbnail(width: 160, height: 240, scale: scale, action: {}).background(Color.white).shadow(color: .black.opacity(0.15), radius: 8 * scale, x: scale, y: scale).offset(x: 117 * scale, y: 113 * scale)
                VStack(alignment: .leading, spacing: 0) {
                    Text("토마토 컵라면").font(FeatureFontFamily.Pretendard.bold.swiftUIFont(size: 24 * scale))
                    Text("차정은").font(FeatureFontFamily.Pretendard.semiBold.swiftUIFont(size: 14 * scale)).foregroundColor(Color(red: 142/255, green: 142/255, blue: 147/255)).padding(.top, 8 * scale)
                }.offset(x: 23 * scale, y: 399 * scale)
                HStack(spacing: 12 * scale) {
                    BookDetailStat(title: "도서관 번호", value: "000", scale: scale)
                    BookDetailStat(title: "재고 수량", value: "\(stock)권", scale: scale)
                    BookDetailStat(title: "대출 여부", value: stock > 0 ? "가능" : "불가", isHighlighted: stock > 0, scale: scale)
                }.offset(x: 23 * scale, y: 469 * scale)
                VStack(alignment: .leading, spacing: 14 * scale) {
                    Text("책 소개").font(FeatureFontFamily.Pretendard.bold.swiftUIFont(size: 14 * scale))
                    Text("《토마토 컵라면》은 상처와 고민을 안고 살아가는 사람들이 우연한 만남을 통해 서로를 이해하고 위로받는 과정을 그린 이야기이다. 토마토 컵라면은 인물들의 추억과 마음을 이어 주는 상징적인 매개체로 등장한다. 이 책은 작은 일상의 소중함과 사람 사이의 따뜻한 관계가 삶에 큰 힘이 될 수 있다는 메시지를 전한다.")
                        .font(FeatureFontFamily.Pretendard.medium.swiftUIFont(size: 12 * scale)).lineSpacing(4 * scale)
                }.frame(width: 347 * scale, alignment: .leading).offset(x: 23 * scale, y: 567 * scale)
                bottomBar(scale: scale).offset(y: 752 * scale)
            }.frame(width: geo.size.width, height: geo.size.height, alignment: .topLeading)
        }.ignoresSafeArea()
    }
    private func bottomBar(scale: CGFloat) -> some View {
        HStack(spacing: 24 * scale) {
            Button { isFavorite.toggle() } label: { Image(systemName: isFavorite ? "heart.fill" : "heart").font(.system(size: 20 * scale)).foregroundColor(isFavorite ? .red : .red) }.buttonStyle(.plain)
            Button(stock > 0 ? "대출 신청하기" : "대출 불가") { if stock > 0 { stock = 0 } }
                .font(FeatureFontFamily.Pretendard.semiBold.swiftUIFont(size: 16 * scale)).foregroundColor(.white)
                .frame(width: 275 * scale, height: 60 * scale)
                .background(stock > 0 ? FeatureAsset.Color.buttonColor.swiftUIColor : Color(red: 229/255, green: 229/255, blue: 229/255))
                .clipShape(RoundedRectangle(cornerRadius: 20 * scale))
                .disabled(stock == 0)
        }.frame(width: 392 * scale, height: 100 * scale).background(Color.white).overlay(alignment: .top) { Rectangle().fill(Color(red: 192/255, green: 192/255, blue: 192/255).opacity(0.5)).frame(height: 0.4 * scale) }
    }
}

struct BookDetailView_Previews: PreviewProvider { static var previews: some View { BookDetailView().previewDevice("iPhone 16") } }
