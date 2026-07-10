import SwiftUI

struct NoticeBanner: View {
    enum Tone {
        case highlighted
        case neutral
    }

    let text: String
    var tone: Tone = .neutral
    var scale: CGFloat = 1

    var body: some View {
        HStack(alignment: .top, spacing: 8 * scale) {
            Image(systemName: tone == .highlighted ? "info.circle.fill" : "info.circle")
                .font(.system(size: 13 * scale, weight: .semibold))
                .foregroundColor(
                    tone == .highlighted
                        ? FeatureAsset.Color.buttonColor.swiftUIColor
                        : Color(red: 0.388, green: 0.388, blue: 0.4)
                )
                .padding(.top, 2 * scale)

            Text(text)
                .font(FeatureFontFamily.Pretendard.medium.swiftUIFont(size: 13 * scale))
                .foregroundColor(
                    tone == .highlighted
                        ? Color(red: 0.369, green: 0.427, blue: 0.255)
                        : FeatureAsset.Color.textDescription.swiftUIColor
                )
        }
        .padding(16 * scale)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(tone == .highlighted ? Color(red: 0.969, green: 0.976, blue: 0.937) : Color.white)
        .cornerRadius(16 * scale)
        .shadow(color: .black.opacity(tone == .highlighted ? 0.1 : 0), radius: 10 * scale, x: 1 * scale, y: 1 * scale)
        .overlay(
            RoundedRectangle(cornerRadius: 16 * scale)
                .stroke(
                    tone == .neutral
                        ? FeatureAsset.Color.borderLight.swiftUIColor.opacity(0.45)
                        : Color.clear,
                    lineWidth: 1 * scale
                )
        )
    }
}
