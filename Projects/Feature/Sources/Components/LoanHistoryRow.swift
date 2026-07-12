import SwiftUI

struct LoanHistoryRow: View {
    let title: String
    let dueText: String
    let badge: String
    var isCompleted = false
    var scale: CGFloat = 1
    let action: () -> Void
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16 * scale) {
                BookThumbnail(width: 48, height: 60, scale: scale, action: {})
                    .background(Color(red: 241/255, green: 241/255, blue: 244/255)).clipShape(RoundedRectangle(cornerRadius: 9 * scale))
                VStack(alignment: .leading, spacing: 7 * scale) {
                    Text(title).font(FeatureFontFamily.Pretendard.extraBold.swiftUIFont(size: 15 * scale)).foregroundColor(.black)
                    Text("로버트 C. 마틴 · \(dueText)").font(FeatureFontFamily.Pretendard.medium.swiftUIFont(size: 12 * scale)).foregroundColor(Color(red: 154/255, green: 154/255, blue: 161/255))
                }
                Spacer()
                BookStatusBadge(title: badge, scale: scale).opacity(isCompleted ? 0.45 : 1)
            }
            .padding(.horizontal, 16 * scale).frame(width: 344 * scale, height: 88 * scale)
            .background(Color.white).clipShape(RoundedRectangle(cornerRadius: 16 * scale)).shadow(color: .black.opacity(0.15), radius: 10 * scale, x: scale, y: scale)
        }.buttonStyle(.plain)
    }
}
