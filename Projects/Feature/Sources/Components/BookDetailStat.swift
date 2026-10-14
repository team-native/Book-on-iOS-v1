import SwiftUI

struct BookDetailStat: View {
    let title: String
    let value: String
    var valueColor: Color = .black
    var scale: CGFloat = 1
    var body: some View {
        VStack(spacing: 8 * scale) {
            Text(title).font(FeatureFontFamily.Pretendard.semiBold.swiftUIFont(size: 12 * scale)).foregroundColor(Color(red: 154/255, green: 154/255, blue: 161/255))
            Text(value)
                .font(FeatureFontFamily.Pretendard.bold.swiftUIFont(size: 14 * scale))
                .foregroundColor(valueColor)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.horizontal, 8 * scale)
        .padding(.vertical, 12 * scale)
        .frame(maxWidth: .infinity, minHeight: 84 * scale)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 12 * scale))
        .shadow(color: .black.opacity(0.07), radius: 12 * scale, x: 0, y: 8 * scale)
    }
}
