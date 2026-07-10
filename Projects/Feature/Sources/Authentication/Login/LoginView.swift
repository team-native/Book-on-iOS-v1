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

    private let buttonWidth: CGFloat = 312

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
            let hasEmailError = emailError != nil
            let passwordFieldY: CGFloat = hasEmailError ? 374 : 354
            let passwordErrorY: CGFloat = hasEmailError ? 432 : 420
            let forgotPasswordY: CGFloat = hasEmailError ? 436 : 420
            let loginButtonHeight = 52 * scale
            let loginButtonY = KeyboardButtonLayout.bottomY(
                containerHeight: geo.size.height,
                buttonHeight: loginButtonHeight,
                scale: scale,
                keyboardHeight: keyboard.height,
                hiddenY: 726,
                subtractKeyboardHeightWhenVisible: true
            )

            ZStack(alignment: .topLeading) {
                FeatureAsset.Color.background.swiftUIColor
                    .contentShape(Rectangle())
                    .onTapGesture { UIApplication.hideKeyboard() }

                Text("환영합니다!")
                    .font(FeatureFontFamily.Pretendard.medium.swiftUIFont(size: 28 * scale))
                    .foregroundColor(FeatureAsset.Color.textPrimary.swiftUIColor)
                    .tracking(-0.43 * scale)
                    .offset(x: 31 * scale, y: 193 * scale)

                Text("대출 현황부터 독서마라톤까지 편리하게")
                    .font(FeatureFontFamily.Pretendard.semiBold.swiftUIFont(size: 14 * scale))
                    .foregroundColor(FeatureAsset.Color.textPlaceholder.swiftUIColor)
                    .offset(x: 34 * scale, y: 229 * scale)

                AuthTextField(
                    icon: "envelope",
                    placeholder: "이메일 주소",
                    text: $email,
                    errorMessage: emailError,
                    showsInlineCaption: false,
                    scale: scale,
                    suffix: "@gsm.hs.kr",
                    keyboardType: .asciiCapable,
                    maxLength: 6,
                    allowsSchoolEmailPrefix: true,
                    fieldWidth: 331,
                    horizontalPadding: 18
                )
                .offset(x: 31 * scale, y: 285 * scale)

                LoginPasswordField(
                    placeholder: "비밀번호",
                    text: $password,
                    errorMessage: passwordError,
                    scale: scale
                )
                .offset(x: 31 * scale, y: passwordFieldY * scale)

                if let emailError {
                    InlineErrorText(message: emailError, scale: scale)
                        .offset(x: 31 * scale, y: 344 * scale)
                }

                if let passwordError {
                    InlineErrorText(message: passwordError, scale: scale)
                        .offset(x: 31 * scale, y: passwordErrorY * scale)
                }

                Button(action: onForgotPassword) {
                    Text("비밀번호를 잊으셨나요?")
                        .font(FeatureFontFamily.Pretendard.semiBold.swiftUIFont(size: 10 * scale))
                        .foregroundColor(FeatureAsset.Color.buttonColor.swiftUIColor)
                }
                .buttonStyle(.plain)
                .offset(x: 258 * scale, y: forgotPasswordY * scale)

                LoginButton(title: "로그인", width: buttonWidth, scale: scale) {
                    submitLogin()
                }
                .offset(x: 41 * scale, y: loginButtonY)
                .animation(.easeOut(duration: 0.22), value: keyboard.height)

                UnderlineTextButton(title: "회원가입 하러가기", scale: scale, action: onSignUp)
                    .frame(width: 150 * scale, height: 44 * scale)
                    .contentShape(Rectangle())
                    .offset(x: 122 * scale, y: 787 * scale)
            }
            .frame(width: geo.size.width, height: geo.size.height, alignment: .topLeading)
        }
        .ignoresSafeArea()
    }

    private func submitLogin() {
        UIApplication.hideKeyboard()

        let trimmedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedPassword = password.trimmingCharacters(in: .whitespacesAndNewlines)

        if trimmedEmail.isEmpty {
            emailError = "이메일 주소를 입력해주세요"
            passwordError = nil
            return
        }

        if trimmedEmail.range(of: #"^s\d{5}$"#, options: .regularExpression) == nil {
            emailError = "올바른 이메일 형식이 아니에요"
            passwordError = nil
            return
        }

        emailError = nil

        if trimmedPassword.isEmpty {
            passwordError = "비밀번호를 입력해주세요"
            return
        }

        passwordError = nil

        let loginEmail = "\(trimmedEmail)@gsm.hs.kr"
        onLogin(loginEmail, password)
    }
}

private struct LoginPasswordField: View {
    let placeholder: String
    @Binding var text: String
    var errorMessage: String?
    var scale: CGFloat

    @State private var isRevealed = false
    @StateObject private var keyboard = KeyboardObserver()
    @FocusState private var isFocused: Bool

    var body: some View {
        HStack(spacing: 12 * scale) {
            ZStack(alignment: .leading) {
                if text.isEmpty {
                    Text(placeholder)
                        .font(FeatureFontFamily.Pretendard.bold.swiftUIFont(size: 12 * scale))
                        .foregroundColor(FeatureAsset.Color.textPlaceholder.swiftUIColor)
                }

                Group {
                    if isRevealed {
                        TextField("", text: $text)
                            .focused($isFocused)
                    } else {
                        SecureField("", text: $text)
                            .focused($isFocused)
                    }
                }
                .font(FeatureFontFamily.Pretendard.regular.swiftUIFont(size: 14 * scale))
                .foregroundColor(FeatureAsset.Color.textPrimary.swiftUIColor)
                .autocorrectionDisabled()
                .textInputAutocapitalization(.never)
            }

            Button(action: togglePasswordVisibility) {
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
                .frame(width: 17 * scale, height: 14 * scale)
            }
            .buttonStyle(.plain)
        }
        .padding(.leading, 20 * scale)
        .padding(.trailing, 22 * scale)
        .frame(width: 331 * scale, height: 52 * scale)
        .background(errorMessage == nil ? Color.white : FeatureAsset.Color.errorBackground.swiftUIColor)
        .cornerRadius(16 * scale)
        .shadow(color: .black.opacity(0.15), radius: 6 * scale, x: 1 * scale, y: 1 * scale)
        .overlay {
            if keyboard.height > 0 && !isFocused {
                Color.clear
                    .contentShape(Rectangle())
                    .onTapGesture {
                        UIApplication.hideKeyboard()
                    }
            }
        }
    }

    private func togglePasswordVisibility() {
        let wasFocused = isFocused

        withAnimation(.easeInOut(duration: 0.12)) {
            isRevealed.toggle()
        }

        if wasFocused {
            DispatchQueue.main.async {
                isFocused = true
            }
        }
    }
}

private struct LoginButton: View {
    let title: String
    let width: CGFloat
    var scale: CGFloat
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(FeatureFontFamily.Pretendard.bold.swiftUIFont(size: 14 * scale))
                .foregroundColor(.white)
                .frame(width: width * scale, height: 52 * scale)
                .background(FeatureAsset.Color.buttonColor.swiftUIColor)
                .cornerRadius(10 * scale)
                .shadow(color: .black.opacity(0.25), radius: 2 * scale, x: 1 * scale, y: 1 * scale)
        }
        .buttonStyle(.plain)
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
