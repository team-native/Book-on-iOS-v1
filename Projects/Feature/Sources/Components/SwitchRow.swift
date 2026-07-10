import SwiftUI

struct SwitchRow: View {
    let title: String
    let subtitle: String
    @Binding var isOn: Bool
    var scale: CGFloat = 1

    var body: some View {
        HStack(spacing: 14 * scale) {
            ZStack {
                RoundedRectangle(cornerRadius: 10 * scale)
                    .fill(Color(red: 0.933, green: 0.957, blue: 0.886))
                    .frame(width: 36 * scale, height: 36 * scale)

                MarathonMarkShape()
                    .fill(FeatureAsset.Color.buttonColor.swiftUIColor)
                    .frame(width: 16 * scale, height: 24 * scale)
            }

            VStack(alignment: .leading, spacing: 4 * scale) {
                Text(title)
                    .font(FeatureFontFamily.Pretendard.bold.swiftUIFont(size: 16 * scale))
                    .foregroundColor(FeatureAsset.Color.textPrimary.swiftUIColor)

                Text(subtitle)
                    .font(FeatureFontFamily.Pretendard.medium.swiftUIFont(size: 13 * scale))
                    .foregroundColor(FeatureAsset.Color.textDescription.swiftUIColor)
                    .lineLimit(2)
            }

            Spacer(minLength: 0)

            Toggle("", isOn: $isOn)
                .labelsHidden()
                .tint(FeatureAsset.Color.buttonColor.swiftUIColor)
        }
        .padding(.horizontal, 16 * scale)
        .padding(.vertical, 14 * scale)
        .overlay(
            RoundedRectangle(cornerRadius: 16 * scale)
                .stroke(FeatureAsset.Color.background.swiftUIColor, lineWidth: 2 * scale)
        )
        .background(Color.white)
        .cornerRadius(16 * scale)
    }
}

private struct MarathonMarkShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.minX + rect.width * 0.58, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.minX + rect.width * 0.15, y: rect.minY + rect.height * 0.52))
        path.addLine(to: CGPoint(x: rect.minX + rect.width * 0.45, y: rect.minY + rect.height * 0.52))
        path.addLine(to: CGPoint(x: rect.minX + rect.width * 0.31, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY + rect.height * 0.36))
        path.addLine(to: CGPoint(x: rect.minX + rect.width * 0.62, y: rect.minY + rect.height * 0.36))
        path.closeSubpath()
        return path
    }
}
