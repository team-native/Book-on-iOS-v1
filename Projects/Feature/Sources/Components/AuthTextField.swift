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
    @State private var isLimitedFieldFocused = false
    @StateObject private var keyboard = KeyboardObserver()
    @FocusState private var isFocused: Bool

<<<<<<< Updated upstream:Projects/Feature/Sources/Components/AuthTextField.swift
=======
    private var isFieldFocused: Bool {
        isFocused || isLimitedFieldFocused
    }

    private var sanitizedText: Binding<String> {
        Binding(
            get: { text },
            set: { newValue in
                text = sanitize(newValue)
            }
        )
    }

    private var usesLimitedInput: Bool {
        allowsOnlyNumbers || allowsSchoolEmailPrefix || maxLength != nil
    }

    private func sanitize(_ value: String) -> String {
        var result = value

        if allowsSchoolEmailPrefix {
            result = sanitizedSchoolEmailPrefix(result)
        } else if allowsOnlyNumbers {
            result = result.filter(\.isNumber)
        }

        if let maxLength {
            result = String(result.prefix(maxLength))
        }

        return result
    }

    private func sanitizedSchoolEmailPrefix(_ value: String) -> String {
        let lowercased = value.lowercased()
        var result = ""

        for character in lowercased {
            if result.isEmpty {
                if character == "s" {
                    result.append(character)
                } else if character.isNumber {
                    result.append("s")
                    result.append(character)
                }
            } else if character.isNumber {
                result.append(character)
            }
        }

        return result
    }

>>>>>>> Stashed changes:Projects/Feature/Sources/Components/Inputs/AuthTextField.swift
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
<<<<<<< Updated upstream:Projects/Feature/Sources/Components/AuthTextField.swift
=======
                    } else if usesLimitedInput {
                        LimitedTextField(
                            text: $text,
                            isFocused: $isLimitedFieldFocused,
                            keyboardType: keyboardType,
                            maxLength: maxLength,
                            allowsOnlyNumbers: allowsOnlyNumbers,
                            allowsSchoolEmailPrefix: allowsSchoolEmailPrefix,
                            fontSize: 14 * scale
                        )
                        .frame(height: 30 * scale)
>>>>>>> Stashed changes:Projects/Feature/Sources/Components/Inputs/AuthTextField.swift
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
        .overlay {
            if keyboard.height > 0 && !isFieldFocused {
                Color.clear
                    .contentShape(Rectangle())
                    .onTapGesture {
                        UIApplication.hideKeyboard()
                    }
            }
        }
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
