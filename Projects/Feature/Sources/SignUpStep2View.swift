import SwiftUI
import UIKit

struct SignUpStep2View: View {
    @Binding var info: SignUpAccountInfo
    let onNext: () -> Void

    @State private var isTermsExpanded = false
    @State private var isPasswordHintShown = false
    @State private var passwordError: String?
    @State private var confirmError: String?
    @StateObject private var keyboard = KeyboardObserver()

    private var isPasswordValid: Bool {
        info.password.count >= 6 && info.password.count <= 15
            && info.password.contains { $0.isLetter }
            && info.password.contains { $0.isNumber }
    }

    private var isFormValid: Bool {
        isPasswordValid && info.password == info.passwordConfirm && info.isAgreedToPrivacyPolicy
    }

    var body: some View {
        GeometryReader { geo in
            let scale = geo.size.width / FigmaDesign.size.width

            ZStack(alignment: .topLeading) {
                FeatureAsset.Color.background.swiftUIColor
                    .contentShape(Rectangle())
                    .onTapGesture { hideKeyboard() }

                SignUpProgressBar(currentStep: 2, scale: scale)
                    .frame(width: 333 * scale, alignment: .leading)
                    .offset(x: 30 * scale, y: 131 * scale)

                PasswordHintButton(isShown: $isPasswordHintShown, scale: scale)
                    .frame(width: 118 * scale, height: 32 * scale, alignment: .trailing)
                    .offset(x: 250 * scale, y: 74 * scale)
                    .zIndex(101)

                if isPasswordHintShown {
                    Color.clear
                        .contentShape(Rectangle())
                        .onTapGesture {
                            withAnimation(.easeInOut(duration: 0.22)) {
                                isPasswordHintShown = false
                            }
                        }
                        .zIndex(99)

                    PasswordHintBubble(scale: scale)
                        .offset(x: 207 * scale, y: 99 * scale)
                        .transition(
                            .asymmetric(
                                insertion: .opacity.combined(
                                    with: .scale(scale: 0.96, anchor: .topTrailing)
                                ),
                                removal: .opacity
                                    .combined(with: .scale(scale: 0.72, anchor: .topTrailing))
                                    .combined(with: .offset(x: 54 * scale, y: -12 * scale))
                            )
                        )
                        .zIndex(100)
                }

                VStack(alignment: .leading, spacing: 8 * scale) {
                    Text("계정 정보")
                        .font(FeatureFontFamily.Pretendard.bold.swiftUIFont(size: 28 * scale))
                        .foregroundColor(.black)

                    Text("비밀번호를 설정해주세요")
                        .font(FeatureFontFamily.Pretendard.semiBold.swiftUIFont(size: 14 * scale))
                        .foregroundColor(FeatureAsset.Color.textDescription.swiftUIColor)
                }
                .frame(width: 300 * scale, alignment: .leading)
                .offset(x: 31 * scale, y: 193 * scale)

                VStack(alignment: .leading, spacing: 10 * scale) {
                    AuthTextField(
                        icon: "lock",
                        placeholder: "비밀번호",
                        text: $info.password,
                        label: "비밀번호",
                        isSecure: true,
                        errorMessage: passwordError,
                        fieldWidth: 331,
                        scale: scale
                    )

                    AuthTextField(
                        icon: "lock",
                        placeholder: "비밀번호 확인",
                        text: $info.passwordConfirm,
                        label: "확인",
                        isSecure: true,
                        errorMessage: confirmError,
                        fieldWidth: 331,
                        scale: scale
                    )

                    AgreementAccordion(
                        isExpanded: $isTermsExpanded,
                        isAgreed: $info.isAgreedToPrivacyPolicy,
                        scale: scale
                    )
                    .frame(width: 331 * scale)
                    .simultaneousGesture(
                        TapGesture().onEnded {
                            hideKeyboard()
                        }
                    )
                }
                .offset(x: 31 * scale, y: 283 * scale)

                KeyboardAvoidingBottomButton(
                    screenHeight: geo.size.height,
                    contentBottomY: (734 + 52) * scale,
                    keyboard: keyboard
                ) {
                    PrimaryButton(title: "가입 완료", scale: scale, action: validateAndProceed)
                        .offset(x: 47 * scale, y: 734 * scale)
                }
            }
            .frame(width: geo.size.width, height: geo.size.height, alignment: .topLeading)
        }
        .ignoresSafeArea()
        .onAppear(perform: refreshValidationMessages)
        .onChange(of: info.password) { _ in
            refreshValidationMessages()
        }
        .onChange(of: info.passwordConfirm) { _ in
            refreshValidationMessages()
        }
    }

    private func validateAndProceed() {
        hideKeyboard()

        guard isPasswordValid else {
            passwordError = "비밀번호 주의사항을 확인해주세요"
            return
        }
        passwordError = nil

        guard info.password == info.passwordConfirm else {
            confirmError = "비밀번호를 다시 확인해주세요"
            return
        }
        confirmError = nil

        guard info.isAgreedToPrivacyPolicy else { return }

        onNext()
    }

    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        keyboard.reset()
    }

    private func refreshValidationMessages() {
        if isPasswordValid {
            passwordError = nil
        }

        if info.passwordConfirm.isEmpty || info.password == info.passwordConfirm {
            confirmError = nil
        }
    }
}
