import SwiftUI
import UIKit
import Service

public struct PasswordResetView: View {
    private enum Step {
        case email
        case verification
        case reset
    }

    @State private var step: Step = .email
    @State private var emailPrefix = ""
    @State private var verificationCode = ""
    @State private var newPassword = ""
    @State private var newPasswordConfirm = ""
    @State private var errorMessage: String?
    @State private var isLoading = false
    @State private var showsCompletionAlert = false
    @State private var showsPasswordHint = false
    @StateObject private var keyboard = KeyboardObserver()

    private let service: PasswordResetService
    private let onBack: () -> Void
    private let onCompleted: () -> Void

    public init(
        service: PasswordResetService = PasswordResetService(),
        onBack: @escaping () -> Void = {},
        onCompleted: @escaping () -> Void = {}
    ) {
        self.service = service
        self.onBack = onBack
        self.onCompleted = onCompleted
    }

    public var body: some View {
        GeometryReader { geo in
            let scale = geo.size.width / FigmaDesign.size.width
            let buttonY = KeyboardButtonLayout.bottomY(
                containerHeight: geo.size.height,
                buttonHeight: 52 * scale,
                scale: scale,
                keyboardHeight: keyboard.height,
                hiddenY: 734,
                subtractKeyboardHeightWhenVisible: true
            )

            ZStack(alignment: .topLeading) {
                FeatureAsset.Color.background.swiftUIColor
                    .contentShape(Rectangle())
                    .onTapGesture { hideKeyboard() }

                AppBackButton(scale: scale, action: goBack)
                    .frame(width: 40 * scale, height: 40 * scale)
                    .offset(x: 25 * scale, y: 57 * scale)

                if step == .reset {
                    resetPublishing(scale: scale)
                } else {
                    verificationPublishing(scale: scale)
                }

                PrimaryButton(
                    title: buttonTitle,
                    scale: scale,
                    isEnabled: !isLoading,
                    action: submit
                )
                .offset(x: 47 * scale, y: buttonY)
                .animation(.easeOut(duration: 0.22), value: keyboard.height)
            }
            .frame(width: geo.size.width, height: geo.size.height, alignment: .topLeading)
        }
        .ignoresSafeArea()
        .navigationBarBackButtonHidden(true)
        .alert("비밀번호 변경 완료", isPresented: $showsCompletionAlert) {
            Button("로그인하기") {
                onCompleted()
            }
        } message: {
            Text("새 비밀번호로 로그인해주세요.")
        }
    }

    @ViewBuilder
    private func form(scale: CGFloat) -> some View {
        VStack(alignment: .leading, spacing: 12 * scale) {
            if step == .email {
                AuthTextField(
                    icon: "envelope",
                    placeholder: "s12345",
                    text: $emailPrefix,
                    suffix: "@gsm.hs.kr",
                    keyboardType: .asciiCapable,
                    maxLength: 6,
                    allowsSchoolEmailPrefix: true,
                    fieldWidth: 331,
                    horizontalPadding: 18,
                    scale: scale
                )
            } else if step == .verification {
                AuthTextField(
                    icon: "number",
                    placeholder: "인증번호 6자리",
                    text: $verificationCode,
                    keyboardType: .numberPad,
                    maxLength: 6,
                    fieldWidth: 331,
                    scale: scale
                )

            }

            if let errorMessage {
                InlineErrorText(message: errorMessage, scale: scale)
            }
        }
    }

    private func verificationPublishing(scale: CGFloat) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(step == .email ? "비밀번호 재설정" : "인증번호 확인")
                .font(FeatureFontFamily.Pretendard.bold.swiftUIFont(size: 28 * scale))
            Text(step == .email ? "가입한 학교 이메일을 입력해주세요" : "이메일로 전송된 인증번호를 입력해주세요")
                .font(FeatureFontFamily.Pretendard.semiBold.swiftUIFont(size: 14 * scale))
                .foregroundColor(FeatureAsset.Color.textDescription.swiftUIColor)
                .padding(.top, 8 * scale)
            form(scale: scale)
                .padding(.top, 48 * scale)
        }
        .offset(x: 31 * scale, y: 193 * scale)
    }

    private func resetPublishing(scale: CGFloat) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Spacer()
                PasswordHintButton(isShown: $showsPasswordHint, scale: scale)
            }
            .frame(width: 331 * scale)
            .padding(.top, 86 * scale)
            .zIndex(10)

            Capsule()
                .fill(FeatureAsset.Color.buttonColor.swiftUIColor)
                .frame(width: 331 * scale, height: 4 * scale)
                .padding(.top, 24 * scale)

            Text("STEP 1 / 1")
                .font(FeatureFontFamily.Pretendard.medium.swiftUIFont(size: 11 * scale))
                .foregroundColor(FeatureAsset.Color.textDescription.swiftUIColor)
                .padding(.top, 10 * scale)

            Text("비밀번호 재설정")
                .font(FeatureFontFamily.Pretendard.bold.swiftUIFont(size: 24 * scale))
                .foregroundColor(.black)
                .padding(.top, 27 * scale)

            Text("새 비밀번호를 입력해주세요")
                .font(FeatureFontFamily.Pretendard.medium.swiftUIFont(size: 12 * scale))
                .foregroundColor(FeatureAsset.Color.textDescription.swiftUIColor)
                .padding(.top, 8 * scale)

            AuthTextField(
                icon: "lock",
                placeholder: "비밀번호",
                text: $newPassword,
                label: "새 비밀번호",
                isSecure: true,
                errorMessage: passwordError,
                fieldWidth: 331,
                horizontalPadding: 18,
                scale: scale
            )
            .padding(.top, 34 * scale)

            AuthTextField(
                icon: "lock",
                placeholder: "비밀번호 확인",
                text: $newPasswordConfirm,
                label: "확인",
                isSecure: true,
                errorMessage: confirmationError,
                fieldWidth: 331,
                horizontalPadding: 18,
                scale: scale
            )
            .padding(.top, 14 * scale)

            if let errorMessage {
                InlineErrorText(message: errorMessage, scale: scale)
                    .padding(.top, 10 * scale)
            }
        }
        .offset(x: 31 * scale, y: 0)
    }

    private var passwordError: String? {
        guard !newPassword.isEmpty, !isPasswordValid else { return nil }
        return "비밀번호 주의사항을 확인해주세요"
    }

    private var confirmationError: String? {
        guard !newPasswordConfirm.isEmpty, newPassword != newPasswordConfirm else { return nil }
        return "비밀번호가 일치하지 않습니다"
    }

    private var buttonTitle: String {
        if isLoading {
            switch step {
            case .email: return "발송 중..."
            case .verification: return "확인 중..."
            case .reset: return "변경 중..."
            }
        }
        switch step {
        case .email: return "인증 메일 보내기"
        case .verification: return "다음"
        case .reset: return "확인"
        }
    }

    private var email: String {
        "\(emailPrefix.trimmingCharacters(in: .whitespacesAndNewlines))@gsm.hs.kr"
    }

    private var isPasswordValid: Bool {
        (6...15).contains(newPassword.count)
            && newPassword.contains { $0.isLetter }
            && newPassword.contains { !$0.isLetter && !$0.isNumber }
    }

    private func submit() {
        guard !isLoading else { return }
        hideKeyboard()
        errorMessage = nil

        switch step {
        case .email:
            guard emailPrefix.range(of: #"^s\d{5}$"#, options: .regularExpression) != nil else {
                errorMessage = "올바른 학교 이메일을 입력해주세요."
                return
            }
            sendVerificationEmail()
        case .verification:
            guard verificationCode.count == 6, verificationCode.allSatisfy(\.isNumber) else {
                errorMessage = "인증번호 6자리를 입력해주세요."
                return
            }
            step = .reset
        case .reset:
            guard verificationCode.count == 6, verificationCode.allSatisfy(\.isNumber) else {
                errorMessage = "인증번호 6자리를 입력해주세요."
                return
            }
            guard isPasswordValid else {
                errorMessage = "비밀번호는 6~15자의 영문과 특수문자를 포함해야 합니다."
                return
            }
            guard newPassword == newPasswordConfirm else {
                errorMessage = "비밀번호가 일치하지 않습니다."
                return
            }
            resetPassword()
        }
    }

    private func sendVerificationEmail() {
        isLoading = true

        Task {
            do {
                try await service.sendVerificationEmail(to: email)
                isLoading = false
                step = .verification
            } catch let NetworkError.server(statusCode, _, message, _) where statusCode == 404 {
                isLoading = false
                errorMessage = message ?? "가입되지 않은 이메일입니다."
            } catch let NetworkError.server(statusCode, _, message, _) where statusCode == 422 {
                isLoading = false
                errorMessage = message ?? "이메일 형식을 확인해주세요."
            } catch {
                isLoading = false
                errorMessage = error.localizedDescription
            }
        }
    }

    private func resetPassword() {
        isLoading = true
        let request = PasswordResetRequest(
            email: email,
            verificationCode: verificationCode,
            newPassword: newPassword,
            newPasswordConfirm: newPasswordConfirm
        )

        Task {
            do {
                try await service.resetPassword(request)
                isLoading = false
                showsCompletionAlert = true
            } catch let NetworkError.server(statusCode, _, message, _) where statusCode == 401 {
                isLoading = false
                errorMessage = message ?? "인증번호가 올바르지 않거나 만료되었습니다."
            } catch let NetworkError.server(statusCode, _, message, _) where statusCode == 422 {
                isLoading = false
                errorMessage = message ?? "새 비밀번호를 다시 확인해주세요."
            } catch {
                isLoading = false
                errorMessage = error.localizedDescription
            }
        }
    }

    private func goBack() {
        hideKeyboard()
        errorMessage = nil

        switch step {
        case .reset:
            step = .verification
        case .verification:
            step = .email
        case .email:
            onBack()
        }
    }

    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        keyboard.reset()
    }
}
