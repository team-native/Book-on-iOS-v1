import SwiftUI
import UIKit
import Service

public struct PasswordResetView: View {
    private enum Step {
        case email
        case reset
    }

    @Environment(\.dismiss) private var dismiss
    @State private var step: Step = .email
    @State private var emailPrefix = ""
    @State private var verificationCode = ""
    @State private var newPassword = ""
    @State private var newPasswordConfirm = ""
    @State private var errorMessage: String?
    @State private var isLoading = false
    @State private var showsCompletionAlert = false
    @StateObject private var keyboard = KeyboardObserver()

    private let service: PasswordResetService
    private let onCompleted: () -> Void

    public init(
        service: PasswordResetService = PasswordResetService(),
        onCompleted: @escaping () -> Void = {}
    ) {
        self.service = service
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

                VStack(alignment: .leading, spacing: 8 * scale) {
                    Text(step == .email ? "비밀번호 재설정" : "새 비밀번호")
                        .font(FeatureFontFamily.Pretendard.bold.swiftUIFont(size: 28 * scale))
                    Text(step == .email ? "가입한 학교 이메일을 입력해주세요" : "인증번호와 새 비밀번호를 입력해주세요")
                        .font(FeatureFontFamily.Pretendard.semiBold.swiftUIFont(size: 14 * scale))
                        .foregroundColor(FeatureAsset.Color.textDescription.swiftUIColor)
                }
                .offset(x: 31 * scale, y: 193 * scale)

                form(scale: scale)
                    .offset(x: 31 * scale, y: 283 * scale)

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
                dismiss()
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
                    placeholder: "이메일 주소",
                    text: $emailPrefix,
                    suffix: "@gsm.hs.kr",
                    keyboardType: .asciiCapable,
                    maxLength: 6,
                    allowsSchoolEmailPrefix: true,
                    fieldWidth: 331,
                    horizontalPadding: 18,
                    scale: scale
                )
            } else {
                AuthTextField(
                    icon: "number",
                    placeholder: "인증번호 6자리",
                    text: $verificationCode,
                    keyboardType: .numberPad,
                    maxLength: 6,
                    fieldWidth: 331,
                    scale: scale
                )

                AuthTextField(
                    icon: "lock",
                    placeholder: "새 비밀번호",
                    text: $newPassword,
                    isSecure: true,
                    fieldWidth: 331,
                    scale: scale
                )

                AuthTextField(
                    icon: "lock",
                    placeholder: "새 비밀번호 확인",
                    text: $newPasswordConfirm,
                    isSecure: true,
                    fieldWidth: 331,
                    scale: scale
                )
            }

            if let errorMessage {
                InlineErrorText(message: errorMessage, scale: scale)
            }
        }
    }

    private var buttonTitle: String {
        if isLoading { return step == .email ? "발송 중..." : "변경 중..." }
        return step == .email ? "인증 메일 보내기" : "비밀번호 변경"
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
                step = .reset
            } catch let NetworkError.server(statusCode, _, message) where statusCode == 404 {
                isLoading = false
                errorMessage = message ?? "가입되지 않은 이메일입니다."
            } catch let NetworkError.server(statusCode, _, message) where statusCode == 422 {
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
            } catch let NetworkError.server(statusCode, _, message) where statusCode == 401 {
                isLoading = false
                errorMessage = message ?? "인증번호가 올바르지 않거나 만료되었습니다."
            } catch let NetworkError.server(statusCode, _, message) where statusCode == 422 {
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

        if step == .reset {
            step = .email
        } else {
            dismiss()
        }
    }

    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        keyboard.reset()
    }
}
