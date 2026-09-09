import SwiftUI
import UIKit

struct LimitedTextField: UIViewRepresentable {
    @Binding var text: String
    @Binding var isFocused: Bool
    let keyboardType: UIKeyboardType
    let maxLength: Int?
    let allowsOnlyNumbers: Bool
    let allowsSchoolEmailPrefix: Bool
    let fontSize: CGFloat

    func makeUIView(context: Context) -> UITextField {
        let textField = UITextField()
        textField.delegate = context.coordinator
        textField.keyboardType = keyboardType
        textField.autocorrectionType = .no
        textField.autocapitalizationType = .none
        textField.font = UIFont(name: "Pretendard-Regular", size: fontSize) ?? .systemFont(ofSize: fontSize)
        // 앱 화면은 라이트 팔레트로 고정되어 있다. 시스템 `.label`은 기기
        // 색상 모드에 따라 흰색이 될 수 있으므로 입력값도 명시적으로 검정으로 둔다.
        textField.textColor = .black
        textField.backgroundColor = .clear
        textField.addTarget(context.coordinator, action: #selector(Coordinator.textDidChange(_:)), for: .editingChanged)
        return textField
    }

    func updateUIView(_ uiView: UITextField, context: Context) {
        context.coordinator.parent = self
        uiView.keyboardType = keyboardType
        uiView.font = UIFont(name: "Pretendard-Regular", size: fontSize) ?? .systemFont(ofSize: fontSize)
        uiView.textColor = .black

        if uiView.text != text {
            uiView.text = text
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }

    final class Coordinator: NSObject, UITextFieldDelegate {
        var parent: LimitedTextField

        init(parent: LimitedTextField) {
            self.parent = parent
        }

        func textField(
            _ textField: UITextField,
            shouldChangeCharactersIn range: NSRange,
            replacementString string: String
        ) -> Bool {
            let currentText = textField.text ?? ""

            guard let textRange = Range(range, in: currentText) else {
                return false
            }

            let proposedText = currentText.replacingCharacters(in: textRange, with: string)
            let sanitizedText = sanitize(proposedText)

            textField.text = sanitizedText
            parent.text = sanitizedText
            return false
        }

        @objc func textDidChange(_ textField: UITextField) {
            let sanitizedText = sanitize(textField.text ?? "")

            if textField.text != sanitizedText {
                textField.text = sanitizedText
            }

            parent.text = sanitizedText
        }

        func textFieldDidBeginEditing(_ textField: UITextField) {
            parent.isFocused = true
        }

        func textFieldDidEndEditing(_ textField: UITextField) {
            parent.isFocused = false
        }

        private func sanitize(_ value: String) -> String {
            var result = value

            if parent.allowsSchoolEmailPrefix {
                result = sanitizedSchoolEmailPrefix(result)
            } else if parent.allowsOnlyNumbers {
                result = result.filter(\.isNumber)
            }

            if let maxLength = parent.maxLength {
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
    }
}
