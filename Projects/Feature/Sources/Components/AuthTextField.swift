import SwiftUI

struct AuthTextField: View {
    let icon: String
    let placeholder: String
    @Binding var text: String
    var isSecure: Bool = false
    var errorMessage: String? = nil
    var showsInlineCaption: Bool = true
    var scale: CGFloat = 1

    @State private var isRevealed = false
    @FocusState private var isFocused: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 6 * scale) {
            fieldRow

            if showsInlineCaption, let errorMessage {
                InlineErrorText(message: errorMessage, scale: scale)
            }
        }
    }

    private var fieldRow: some View {
        HStack(spacing: 12 * scale) {
            Image(systemName: icon)
                .foregroundColor(FeatureAsset.Color.textPlaceholder.swiftUIColor)
                .frame(width: 15 * scale)

            ZStack(alignment: .leading) {
                if text.isEmpty {
                    Text(placeholder)
                        .font(FeatureFontFamily.Pretendard.bold.swiftUIFont(size: 12 * scale))
                        .foregroundColor(FeatureAsset.Color.textPlaceholder.swiftUIColor)
                }

                Group {
                    if isSecure && !isRevealed {
                        SecureField("", text: $text)
                            .focused($isFocused)
                    } else {
                        TextField("", text: $text)
                            .focused($isFocused)
                    }
                }
                .font(FeatureFontFamily.Pretendard.regular.swiftUIFont(size: 14 * scale))
                .foregroundColor(FeatureAsset.Color.textPrimary.swiftUIColor)
                .autocorrectionDisabled()
                .textInputAutocapitalization(.never)
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
        .frame(width: 300 * scale, height: 52 * scale)
        .background(errorMessage == nil ? Color.white : FeatureAsset.Color.errorBackground.swiftUIColor)
        .cornerRadius(16 * scale)
        .shadow(color: .black.opacity(0.15), radius: 6 * scale, x: 1 * scale, y: 1 * scale)
    }
}
