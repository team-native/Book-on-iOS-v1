import SwiftUI
import UIKit

struct AuthTextField: View {
    let icon: String?
    let placeholder: String
    @Binding var text: String
    var label: String? = nil
    var prefix: String? = nil
    var suffix: String? = nil
    var isSecure: Bool = false
    var errorMessage: String? = nil
    var showsInlineCaption: Bool = true
    var keyboardType: UIKeyboardType = .default
    var maxLength: Int? = nil
    var allowsOnlyNumbers = false
    var fieldWidth: CGFloat = 300
    var scale: CGFloat = 1

    @State private var isRevealed = false
    @FocusState private var isFocused: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 6 * scale) {
            if let label {
                Text(label)
                    .font(FeatureFontFamily.Pretendard.semiBold.swiftUIFont(size: 14 * scale))
                    .foregroundColor(FeatureAsset.Color.textDescription.swiftUIColor)
            }

            fieldRow

            if showsInlineCaption, let errorMessage {
                InlineErrorText(message: errorMessage, scale: scale)
            }
        }
    }

    private var fieldRow: some View {
        HStack(spacing: 12 * scale) {
            if let icon {
                Image(systemName: icon)
                    .foregroundColor(FeatureAsset.Color.textPlaceholder.swiftUIColor)
                    .frame(width: 15 * scale)
            }

            if let prefix {
                Text(prefix)
                    .font(FeatureFontFamily.Pretendard.bold.swiftUIFont(size: 12 * scale))
                    .foregroundColor(FeatureAsset.Color.textPrimary.swiftUIColor)
            }

            ZStack(alignment: .leading) {
                if text.isEmpty {
                    Text(placeholder)
                        .font(FeatureFontFamily.Pretendard.bold.swiftUIFont(size: 12 * scale))
                        .foregroundColor(FeatureAsset.Color.textPlaceholder.swiftUIColor)
                }

                Group {
                    if isSecure && !isRevealed {
                        SecureField("", text: sanitizedTextBinding)
                            .focused($isFocused)
                    } else {
                        TextField("", text: sanitizedTextBinding)
                            .focused($isFocused)
                    }
                }
                .font(FeatureFontFamily.Pretendard.regular.swiftUIFont(size: 14 * scale))
                .foregroundColor(FeatureAsset.Color.textPrimary.swiftUIColor)
                .autocorrectionDisabled()
                .textInputAutocapitalization(.never)
                .keyboardType(keyboardType)
                .onChange(of: text) { newValue in
                    let sanitized = sanitize(newValue)

                    if sanitized != newValue {
                        text = sanitized
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .layoutPriority(1)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .layoutPriority(1)

            if let suffix {
                Text(suffix)
                    .font(FeatureFontFamily.Pretendard.bold.swiftUIFont(size: 12 * scale))
                    .foregroundColor(FeatureAsset.Color.textPlaceholder.swiftUIColor)
            }

            if isSecure {
                Button(action: {
                    let wasFocused = isFocused

                    withAnimation(.easeInOut(duration: 0.12)) {
                        isRevealed.toggle()
                    }

                    if wasFocused {
                        DispatchQueue.main.async {
                            isFocused = true
                        }
                    }
                }) {
                    ZStack {
                        FeatureAsset.Image.eyeOpen.swiftUIImage
                            .renderingMode(.template)
                            .resizable()
                            .scaledToFit()

                        if !isRevealed {
                            GeometryReader { proxy in
                                Path { path in
                                    path.move(to: CGPoint(x: 0, y: proxy.size.height))
                                    path.addLine(to: CGPoint(x: proxy.size.width, y: 0))
                                }
                                .stroke(FeatureAsset.Color.textPlaceholder.swiftUIColor, lineWidth: 1.2 * scale)
                            }
                        }
                    }
                    .foregroundColor(FeatureAsset.Color.textPlaceholder.swiftUIColor)
                    .frame(width: 16 * scale, height: 12 * scale)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 16 * scale)
        .frame(width: fieldWidth * scale, height: 52 * scale)
        .background(errorMessage == nil ? Color.white : FeatureAsset.Color.errorBackground.swiftUIColor)
        .cornerRadius(16 * scale)
        .shadow(color: .black.opacity(0.15), radius: 6 * scale, x: 1 * scale, y: 1 * scale)
    }

    private func sanitize(_ value: String) -> String {
        var sanitized = allowsOnlyNumbers ? value.filter { $0.isNumber } : value

        if let maxLength {
            sanitized = String(sanitized.prefix(maxLength))
        }

        return sanitized
    }

    private var sanitizedTextBinding: Binding<String> {
        Binding(
            get: { text },
            set: { text = sanitize($0) }
        )
    }
}
