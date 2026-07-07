import SwiftUI
import UIKit

public struct LoginView: View {
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var emailError: String?
    @State private var passwordError: String?
    @StateObject private var keyboard = KeyboardObserver()

    private let onLogin: (String, String) -> Void
    private let onForgotPassword: () -> Void
    private let onSignUp: () -> Void

    private let fieldHeight: CGFloat = 52
    private let gapFieldToField: CGFloat = 12
    private let gapFieldToCaption: CGFloat = 6
    private let contentTopY: CGFloat = 290
    private let buttonY: CGFloat = 726
    private let signupY: CGFloat = 802

    public init(
        emailError: String? = nil,
        passwordError: String? = nil,
        onLogin: @escaping (String, String) -> Void = { _, _ in },
        onForgotPassword: @escaping () -> Void = {},
        onSignUp: @escaping () -> Void = {}
    ) {
        self.onLogin = onLogin
        self.onForgotPassword = onForgotPassword
        self.onSignUp = onSignUp
        _emailError = State(initialValue: emailError)
        _passwordError = State(initialValue: passwordError)
    }

    public var body: some View {
        GeometryReader { geo in
            let scale = geo.size.width / FigmaDesign.size.width
            let keyboardTop = geo.size.height - keyboard.height
            let buttonBottomY = (buttonY + fieldHeight) * scale
            let keyboardOverlap = max(0, buttonBottomY - keyboardTop + 12)

            ZStack(alignment: .topLeading) {
                FeatureAsset.Color.background.swiftUIColor
                    .contentShape(Rectangle())
                    .onTapGesture { hideKeyboard() }

                Text("환영합니다 !")
                    .font(FeatureFontFamily.Pretendard.semiBold.swiftUIFont(size: 20 * scale))
                    .foregroundColor(FeatureAsset.Color.textPrimary.swiftUIColor)
                    .offset(x: 147 * scale, y: 211 * scale)

                VStack(alignment: .leading, spacing: gapFieldToField * scale) {
                    AuthTextField(
                        icon: "envelope",
                        placeholder: "이메일 주소",
                        text: $email,
                        errorMessage: emailError,
                        scale: scale
                    )

                    VStack(alignment: .leading, spacing: gapFieldToCaption * scale) {
                        AuthTextField(
                            icon: "lock",
                            placeholder: "비밀번호",
                            text: $password,
                            isSecure: true,
                            errorMessage: passwordError,
                            showsInlineCaption: false,
                            scale: scale
                        )

                        HStack {
                            if let passwordError {
                                InlineErrorText(message: passwordError, scale: scale)
                            }
                            Spacer()
                            Button(action: onForgotPassword) {
                                Text("비밀번호를 잊으셨나요?")
                                    .font(FeatureFontFamily.Pretendard.semiBold.swiftUIFont(size: 10 * scale))
                                    .foregroundColor(FeatureAsset.Color.buttonColor.swiftUIColor)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
                .frame(width: 300 * scale, alignment: .leading)
                .offset(x: 47 * scale, y: contentTopY * scale)

                PrimaryButton(title: "로그인", scale: scale, action: {
                    hideKeyboard()
                    if email.isEmpty {
                        emailError = "올바른 이메일 형식이 아니에요"
                        passwordError = nil
                    } else {
                        emailError = nil
                        passwordError = "비밀번호는 6자 이상이어야 해요"
                    }
                    onLogin(email, password)
                })
                .offset(x: 47 * scale, y: buttonY * scale)
                .offset(y: -keyboardOverlap)
                .animation(.easeOut(duration: 0.2), value: keyboardOverlap)

                UnderlineTextButton(title: "회원가입 하러가기", scale: scale, action: onSignUp)
                    .offset(x: 154 * scale, y: signupY * scale)
            }
            .frame(width: geo.size.width, height: geo.size.height, alignment: .topLeading)
        }
        .ignoresSafeArea()
    }

    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            LoginView()
                .previewDisplayName("Default")

            LoginView(
                emailError: "올바른 이메일 형식이 아니에요",
                passwordError: "비밀번호는 6자 이상이어야 해요"
            )
            .previewDisplayName("Error")
        }
    }
}
