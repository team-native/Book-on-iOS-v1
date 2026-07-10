import SwiftUI
import UIKit

struct SignUpAccountInfo {
    var schoolEmailPrefix: String = ""
    var name: String = ""
    var gender: SignUpGender?
    var department: String?
    var password: String = ""
    var passwordConfirm: String = ""
    var isAgreedToPrivacyPolicy: Bool = false
    var isMarathonLinked: Bool = false
    var marathonId: String = ""
    var marathonPassword: String = ""
}

struct SignUpStep1View: View {
    @Binding var info: SignUpAccountInfo
    let onNext: () -> Void

    @State private var emailError: String?
    @State private var isVerificationPresented = false
    @State private var verificationCode = ""
    @State private var verificationError: String?
    @State private var remainingVerificationSeconds = 292
    @FocusState private var isEmailFocused: Bool
    @StateObject private var keyboard = KeyboardObserver()

    private let departments = ["소프트웨어개발과", "사물인터넷과", "인공지능과"]

    private var isEmailValid: Bool {
        info.schoolEmailPrefix.range(of: "^s\\d{5}$", options: .regularExpression) != nil
    }

    private var isFormValid: Bool {
        isEmailValid
            && !info.name.isEmpty
            && info.gender != nil
            && info.department != nil
    }

    private var schoolEmailBinding: Binding<String> {
        Binding<String>(
            get: { info.schoolEmailPrefix },
            set: { newValue in
                info.schoolEmailPrefix = sanitizeSchoolEmail(newValue)
            }
        )
    }

    private var verificationTimeText: String {
        let minutes = remainingVerificationSeconds / 60
        let seconds = remainingVerificationSeconds % 60

        return String(format: "%02d:%02d", minutes, seconds)
    }

    private var isVerificationCodeAccepted: Bool {
        (4...6).contains(verificationCode.count) && verificationCode.allSatisfy { $0 == "0" }
    }

    var body: some View {
        GeometryReader { geo in
            let scale = geo.size.width / FigmaDesign.size.width

            ZStack(alignment: .topLeading) {
                FeatureAsset.Color.background.swiftUIColor
                    .contentShape(Rectangle())
                    .onTapGesture { hideKeyboard() }

                SignUpProgressBar(currentStep: 1, scale: scale)
                    .frame(width: 333 * scale, alignment: .leading)
                    .offset(x: 30 * scale, y: 131 * scale)

                if isVerificationPresented {
                    verificationContent(scale: scale)
                } else {
                    schoolInfoContent(scale: scale)
                }

                KeyboardAvoidingBottomButton(
                    screenHeight: geo.size.height,
                    contentBottomY: (726 + 52) * scale,
                    keyboard: keyboard
                ) {
                    PrimaryButton(
                        title: isVerificationPresented ? "인증하고 계속하기" : "다음",
                        scale: scale,
                        action: isVerificationPresented ? validateVerificationAndProceed : validateSchoolInfoAndProceed
                    )
                        .offset(x: 47 * scale, y: 726 * scale)
                }

                if isVerificationPresented {
                    resendCodeView(scale: scale)
                }
            }
            .frame(width: geo.size.width, height: geo.size.height, alignment: .topLeading)
        }
        .ignoresSafeArea()
        .onReceive(Timer.publish(every: 1, on: .main, in: .common).autoconnect()) { _ in
            guard isVerificationPresented, remainingVerificationSeconds > 0 else { return }

            remainingVerificationSeconds -= 1
        }
    }

    private func schoolInfoContent(scale: CGFloat) -> some View {
        Group {
            VStack(alignment: .leading, spacing: 8 * scale) {
                Text("학교 정보")
                    .font(FeatureFontFamily.Pretendard.bold.swiftUIFont(size: 28 * scale))
                    .foregroundColor(.black)

                Text("학교 계정으로 간편하게 가입하세요!")
                    .font(FeatureFontFamily.Pretendard.semiBold.swiftUIFont(size: 14 * scale))
                    .foregroundColor(FeatureAsset.Color.textDescription.swiftUIColor)
            }
            .offset(x: 31 * scale, y: 193 * scale)

            VStack(alignment: .leading, spacing: 20 * scale) {
                SchoolEmailField(
                    text: schoolEmailBinding,
                    label: "학교 이메일",
                    errorMessage: emailError,
                    fieldWidth: 331,
                    scale: scale
                )
                .focused($isEmailFocused)
                .onChange(of: info.schoolEmailPrefix) { newValue in
                    if newValue.isEmpty || isEmailValid {
                        emailError = nil
                    } else {
                        emailError = "잘못된 이메일 형식입니다"
                    }
                }

                AuthTextField(
                    icon: "person",
                    placeholder: "이름",
                    text: $info.name,
                    label: "이름",
                    fieldWidth: 331,
                    scale: scale
                )

                VStack(alignment: .leading, spacing: 6 * scale) {
                    Text("성별")
                        .font(FeatureFontFamily.Pretendard.semiBold.swiftUIFont(size: 14 * scale))
                        .foregroundColor(FeatureAsset.Color.textDescription.swiftUIColor)

                    GenderSelector(selection: $info.gender, optionWidth: 154, scale: scale)
                }

                DepartmentField(
                    label: "학과",
                    placeholder: "학과",
                    options: departments,
                    selection: $info.department,
                    fieldWidth: 331,
                    scale: scale
                )
            }
            .offset(x: 31 * scale, y: 283 * scale)
        }
    }

    private func verificationContent(scale: CGFloat) -> some View {
        Group {
            VStack(alignment: .leading, spacing: 10 * scale) {
                Text("인증번호 입력")
                    .font(FeatureFontFamily.Pretendard.bold.swiftUIFont(size: 28 * scale))
                    .foregroundColor(.black)

                (
                    Text("\(info.schoolEmailPrefix)@gsm.hs.kr")
                        .font(FeatureFontFamily.Pretendard.medium.swiftUIFont(size: 12 * scale))
                        .foregroundColor(FeatureAsset.Color.textDescription.swiftUIColor)
                    + Text(" 으로 보낸\n6자리 코드를 입력해 주세요")
                        .font(FeatureFontFamily.Pretendard.semiBold.swiftUIFont(size: 12 * scale))
                        .foregroundColor(FeatureAsset.Color.textDescription.swiftUIColor)
                )
                .lineSpacing(2 * scale)
            }
            .frame(width: 331 * scale, alignment: .leading)
            .offset(x: 31 * scale, y: 193 * scale)

            VerificationCodeInputView(code: $verificationCode, scale: scale)
                .offset(x: 52 * scale, y: 330 * scale)
                .onChange(of: verificationCode) { newValue in
                    let sanitized = String(newValue.filter { $0.isNumber }.prefix(6))

                    if sanitized != newValue {
                        verificationCode = sanitized
                    }

                    if verificationError != nil {
                        verificationError = nil
                    }
                }

            HStack(spacing: 4 * scale) {
                Image(systemName: "clock")
                    .font(.system(size: 11 * scale, weight: .medium))

                Text("\(verificationTimeText) 후 만료")
                    .font(FeatureFontFamily.Pretendard.medium.swiftUIFont(size: 11 * scale))
            }
            .foregroundColor(FeatureAsset.Color.textDescription.swiftUIColor)
            .offset(x: 52 * scale, y: 372 * scale)

            if let verificationError {
                InlineErrorText(message: verificationError, scale: scale)
                    .offset(x: 52 * scale, y: 396 * scale)
            }
        }
    }

    private func resendCodeView(scale: CGFloat) -> some View {
        HStack(spacing: 4 * scale) {
            Text("코드를 받지 못하셨나요?")
                .foregroundColor(FeatureAsset.Color.textDescription.swiftUIColor)

            Button("재전송") {
                verificationCode = ""
                verificationError = nil
                remainingVerificationSeconds = 292
            }
            .foregroundColor(FeatureAsset.Color.buttonColor.swiftUIColor)
        }
        .font(FeatureFontFamily.Pretendard.medium.swiftUIFont(size: 12 * scale))
        .frame(width: 300 * scale)
        .offset(x: 47 * scale, y: 802 * scale)
    }

    private func validateSchoolInfoAndProceed() {
        hideKeyboard()

        guard isEmailValid else {
            emailError = "잘못된 이메일 형식입니다"
            return
        }

        guard isFormValid else { return }

        emailError = nil
        verificationCode = ""
        verificationError = nil
        remainingVerificationSeconds = 292

        isVerificationPresented = true
    }

    private func validateVerificationAndProceed() {
        hideKeyboard()

        guard isVerificationCodeAccepted else {
            verificationError = "인증번호를 다시 확인해주세요"
            return
        }

        verificationError = nil
        onNext()
    }

    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        keyboard.reset()
    }
}

private struct SchoolEmailField: View {
    @Binding var text: String
    let label: String
    let errorMessage: String?
    let fieldWidth: CGFloat
    let scale: CGFloat

    var body: some View {
        VStack(alignment: .leading, spacing: 6 * scale) {
            Text(label)
                .font(FeatureFontFamily.Pretendard.semiBold.swiftUIFont(size: 14 * scale))
                .foregroundColor(FeatureAsset.Color.textDescription.swiftUIColor)

            HStack(spacing: 12 * scale) {
                Image(systemName: "envelope")
                    .foregroundColor(FeatureAsset.Color.textPlaceholder.swiftUIColor)
                    .frame(width: 15 * scale)

                LimitedSchoolEmailTextField(text: $text, fontSize: 14 * scale)
                    .frame(maxWidth: .infinity, minHeight: 24 * scale, alignment: .leading)

                Text("@gsm.hs.kr")
                    .font(FeatureFontFamily.Pretendard.bold.swiftUIFont(size: 12 * scale))
                    .foregroundColor(FeatureAsset.Color.textPlaceholder.swiftUIColor)
                    .layoutPriority(1)
            }
            .padding(.horizontal, 16 * scale)
            .frame(width: fieldWidth * scale, height: 52 * scale)
            .background(errorMessage == nil ? Color.white : FeatureAsset.Color.errorBackground.swiftUIColor)
            .cornerRadius(16 * scale)
            .shadow(color: .black.opacity(0.15), radius: 6 * scale, x: 1 * scale, y: 1 * scale)

            if let errorMessage {
                InlineErrorText(message: errorMessage, scale: scale)
            }
        }
    }
}

private struct LimitedSchoolEmailTextField: UIViewRepresentable {
    @Binding var text: String
    let fontSize: CGFloat

    func makeUIView(context: Context) -> UITextField {
        let textField = UITextField()
        textField.delegate = context.coordinator
        textField.keyboardType = .asciiCapable
        textField.autocorrectionType = .no
        textField.autocapitalizationType = .none
        textField.textColor = UIColor.black
        textField.tintColor = UIColor.systemBlue
        textField.backgroundColor = .clear
        textField.borderStyle = .none
        textField.textAlignment = .left
        textField.font = UIFont.systemFont(ofSize: fontSize)
        textField.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        textField.addTarget(context.coordinator, action: #selector(Coordinator.textDidChange(_:)), for: .editingChanged)
        return textField
    }

    func updateUIView(_ uiView: UITextField, context: Context) {
        let sanitized = sanitizeSchoolEmail(text)

        if text != sanitized {
            DispatchQueue.main.async {
                text = sanitized
            }
        }

        if uiView.text != sanitized {
            uiView.text = sanitized
        }

        uiView.font = UIFont.systemFont(ofSize: fontSize)
        context.coordinator.parent = self
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }

    final class Coordinator: NSObject, UITextFieldDelegate {
        var parent: LimitedSchoolEmailTextField

        init(parent: LimitedSchoolEmailTextField) {
            self.parent = parent
        }

        func textField(
            _ textField: UITextField,
            shouldChangeCharactersIn range: NSRange,
            replacementString string: String
        ) -> Bool {
            let current = textField.text ?? ""
            guard let textRange = Range(range, in: current) else { return false }

            let candidate = current.replacingCharacters(in: textRange, with: string)
            let sanitized = sanitizeSchoolEmail(candidate)

            if sanitized == candidate {
                return true
            }

            textField.text = sanitized
            parent.text = sanitized
            return false
        }

        @objc func textDidChange(_ textField: UITextField) {
            let sanitized = sanitizeSchoolEmail(textField.text ?? "")

            if textField.text != sanitized {
                textField.text = sanitized
            }

            parent.text = sanitized
        }
    }
}

private func sanitizeSchoolEmail(_ value: String) -> String {
    let lowercased = value.lowercased()
    let hasPrefixMarker = lowercased.contains("s")
    let digits = lowercased.filter { $0.isNumber }
    let sanitized = (hasPrefixMarker ? "s" : "") + digits

    return String(sanitized.prefix(6))
}

private struct VerificationCodeInputView: View {
    @Binding var code: String
    let scale: CGFloat

    @FocusState private var isFocused: Bool

    private let slotCount = 6

    var body: some View {
        ZStack(alignment: .leading) {
            HStack(spacing: 14 * scale) {
                ForEach(0..<slotCount, id: \.self) { index in
                    VStack(spacing: 4 * scale) {
                        Text(digit(at: index))
                            .font(FeatureFontFamily.Pretendard.semiBold.swiftUIFont(size: 20 * scale))
                            .foregroundColor(
                                index == min(code.count, slotCount - 1) && isFocused
                                    ? FeatureAsset.Color.buttonColor.swiftUIColor
                                    : FeatureAsset.Color.textPrimary.swiftUIColor
                            )
                            .frame(height: 24 * scale)

                        Rectangle()
                            .fill(
                                index == min(code.count, slotCount - 1) && isFocused
                                    ? FeatureAsset.Color.buttonColor.swiftUIColor
                                    : FeatureAsset.Color.textPrimary.swiftUIColor
                            )
                            .frame(width: 30 * scale, height: 2 * scale)
                    }
                    .frame(width: 34 * scale)
                }
            }

            TextField("", text: $code)
                .keyboardType(.numberPad)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .focused($isFocused)
                .opacity(0.01)
                .frame(width: 1, height: 1)
                .accessibilityHidden(true)
        }
        .contentShape(Rectangle())
        .onTapGesture {
            isFocused = true
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                isFocused = true
            }
        }
    }

    private func digit(at index: Int) -> String {
        let digits = Array(code)

        guard index < digits.count else {
            return ""
        }

        return String(digits[index])
    }
}
