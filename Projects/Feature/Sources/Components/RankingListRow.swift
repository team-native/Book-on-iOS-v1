import SwiftUI

struct RankingListRow: View {
    let rank: Int
    let name: String
    let detail: String
    let count: String
    var profileImagePath: String? = nil
    var scale: CGFloat = 1
    var action: () -> Void = {}
    var body: some View {
        Button(action: action) { HStack(spacing: 14 * scale) {
            Text("\(rank)").font(FeatureFontFamily.Pretendard.semiBold.swiftUIFont(size: 14 * scale)).foregroundColor(Color(red: 142/255, green: 142/255, blue: 147/255)).frame(width: 20 * scale)
            ProfileAvatar(scale: scale, imagePath: profileImagePath)
            VStack(alignment: .leading, spacing: 3 * scale) {
                Text(name).font(FeatureFontFamily.Pretendard.semiBold.swiftUIFont(size: 14 * scale))
                Text(detail).font(FeatureFontFamily.Pretendard.medium.swiftUIFont(size: 12 * scale)).foregroundColor(Color(red: 154/255, green: 154/255, blue: 161/255))
            }
            Spacer()
            Text(count).font(FeatureFontFamily.Pretendard.semiBold.swiftUIFont(size: 12 * scale))
        }
        .frame(height: 63 * scale) }
        .buttonStyle(.plain)
    }
}
