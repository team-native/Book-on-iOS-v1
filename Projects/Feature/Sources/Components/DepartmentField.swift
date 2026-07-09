import SwiftUI

struct DepartmentField: View {
    let label: String
    let placeholder: String
    let options: [String]
    @Binding var selection: String?
    var fieldWidth: CGFloat = 300
    var scale: CGFloat = 1

    var body: some View {
        VStack(alignment: .leading, spacing: 6 * scale) {
            Text(label)
                .font(FeatureFontFamily.Pretendard.semiBold.swiftUIFont(size: 14 * scale))
                .foregroundColor(FeatureAsset.Color.textDescription.swiftUIColor)

            Menu {
                ForEach(options, id: \.self) { option in
                    Button(option) { selection = option }
                }
            } label: {
                HStack(spacing: 12 * scale) {
                    Text(selection ?? placeholder)
                        .font(FeatureFontFamily.Pretendard.regular.swiftUIFont(size: 14 * scale))
                        .foregroundColor(
                            selection == nil
                                ? FeatureAsset.Color.textPlaceholder.swiftUIColor
                                : FeatureAsset.Color.textPrimary.swiftUIColor
                        )

                    Spacer()

                    Image(systemName: "chevron.down")
                        .font(.system(size: 12 * scale, weight: .semibold))
                        .foregroundColor(FeatureAsset.Color.textPrimary.swiftUIColor)
                }
                .padding(.horizontal, 16 * scale)
                .frame(width: fieldWidth * scale, height: 52 * scale)
                .background(Color.white)
                .cornerRadius(16 * scale)
                .shadow(color: .black.opacity(0.15), radius: 6 * scale, x: 1 * scale, y: 1 * scale)
            }
            .buttonStyle(.plain)
        }
    }
}
