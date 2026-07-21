import SwiftUI

enum SignUpGender {
    case male
    case female

    var title: String {
        switch self {
        case .male: return "남자"
        case .female: return "여자"
        }
    }

    var serverCode: String {
        switch self {
        case .male: return "MALE"
        case .female: return "FEMALE"
        }
    }
}

struct GenderSelector: View {
    @Binding var selection: SignUpGender?
    var optionWidth: CGFloat = 140
    var scale: CGFloat = 1

    var body: some View {
        HStack(spacing: 20 * scale) {
            option(.male)
            option(.female)
        }
    }

    private func option(_ gender: SignUpGender) -> some View {
        let isSelected = selection == gender

        return Button(action: {
            withAnimation(.spring(response: 0.24, dampingFraction: 0.62)) {
                selection = gender
            }
        }) {
            Text(gender.title)
                .font(
                    isSelected
                        ? FeatureFontFamily.Pretendard.medium.swiftUIFont(size: 14 * scale)
                        : FeatureFontFamily.Pretendard.regular.swiftUIFont(size: 14 * scale)
                )
                .foregroundColor(
                    isSelected
                        ? FeatureAsset.Color.buttonColor.swiftUIColor
                        : FeatureAsset.Color.textPlaceholder.swiftUIColor
                )
                .frame(width: optionWidth * scale, height: 52 * scale)
                .background(
                    isSelected
                        ? FeatureAsset.Color.buttonColor.swiftUIColor.opacity(0.12)
                        : Color.white
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 12 * scale)
                        .stroke(
                            isSelected
                                ? FeatureAsset.Color.buttonColor.swiftUIColor.opacity(0.65)
                                : Color.clear,
                            lineWidth: 1.2 * scale
                        )
                )
                .cornerRadius(12 * scale)
                .scaleEffect(isSelected ? 1.035 : 1)
                .shadow(
                    color: .black.opacity(isSelected ? 0.2 : 0.15),
                    radius: isSelected ? 5 * scale : 4 * scale,
                    x: 1 * scale,
                    y: isSelected ? 2 * scale : 1 * scale
                )
        }
        .buttonStyle(.plain)
        .animation(.spring(response: 0.24, dampingFraction: 0.62), value: isSelected)
    }
}
