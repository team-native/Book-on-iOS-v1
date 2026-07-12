import SwiftUI

struct ProfileStatsCard: View {
    let stats: [(String, String)]
    var scale: CGFloat = 1
    var body: some View {
        HStack(spacing: 0) {
            ForEach(Array(stats.enumerated()), id: \.offset) { index, stat in
                VStack(spacing: 7 * scale) {
                    Text(stat.0).font(FeatureFontFamily.Pretendard.semiBold.swiftUIFont(size: 12 * scale)).foregroundColor(Color(red: 239/255, green: 246/255, blue: 227/255))
                    Text(stat.1).font(FeatureFontFamily.Pretendard.bold.swiftUIFont(size: 18 * scale)).foregroundColor(Color(red: 239/255, green: 246/255, blue: 227/255))
                }.frame(maxWidth: .infinity)
                if index < stats.count - 1 { Rectangle().fill(Color(red: 186/255, green: 227/255, blue: 126/255)).frame(width: scale, height: 64 * scale) }
            }
        }
        .frame(height: 76 * scale)
        .background(LinearGradient(colors: [Color(red: 141/255, green: 199/255, blue: 56/255), Color(red: 114/255, green: 162/255, blue: 29/255)], startPoint: .leading, endPoint: .trailing))
        .clipShape(RoundedRectangle(cornerRadius: 16 * scale))
        .shadow(color: Color(red: 110/255, green: 173/255, blue: 18/255).opacity(0.4), radius: 12 * scale, x: scale, y: scale)
    }
}
