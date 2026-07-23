import SwiftUI

struct Read365LinkView: View {
    let isSubmitting: Bool
    let serverError: String?
    let onBack: () -> Void
    let onLink: (String, String) -> Void

    @State private var read365Id = ""
    @State private var password = ""
    @State private var isAgreed = false
    @State private var localError: String?
    @StateObject private var keyboard = KeyboardObserver()

    var body: some View {
        GeometryReader { geo in
            let scale = geo.size.width / FigmaDesign.size.width

            ZStack(alignment: .topLeading) {
                FeatureAsset.Color.background.swiftUIColor.ignoresSafeArea()

                AppBackButton(scale: scale, action: onBack)
                    .frame(width: 40 * scale, height: 40 * scale)
                    .background(FeatureAsset.Color.background.swiftUIColor)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10 * scale)
                            .stroke(Color(red: 234/255, green: 234/255, blue: 236/255), lineWidth: 0.6 * scale)
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 10 * scale))
                    .offset(x: 25 * scale, y: 57 * scale)

                SignUpProgressBar(currentStep: 3, scale: scale)
                    .frame(width: 333 * scale, alignment: .leading)
                    .offset(x: 30 * scale, y: 131 * scale)

                VStack(alignment: .leading, spacing: 8 * scale) {
                    Text("계정연동")
                        .font(FeatureFontFamily.Pretendard.medium.swiftUIFont(size: 28 * scale))
                        .foregroundColor(.black)
                    Text("독서마라톤 아이디와 비밀번호를\n입력해 주세요")
                        .font(FeatureFontFamily.Pretendard.medium.swiftUIFont(size: 14 * scale))
                        .foregroundColor(FeatureAsset.Color.textDescription.swiftUIColor)
                        .lineSpacing(3 * scale)
                }
                .offset(x: 25 * scale, y: 191 * scale)

                VStack(alignment: .leading, spacing: 10 * scale) {
                    AuthTextField(
                        icon: nil,
                        placeholder: "독서마라톤 아이디",
                        text: $read365Id,
                        label: "독서마라톤 아이디",
                        fieldWidth: 342,
                        scale: scale
                    )

                    AuthTextField(
                        icon: nil,
                        placeholder: "비밀번호",
                        text: $password,
                        label: "비밀번호",
                        isSecure: true,
                        fieldWidth: 342,
                        scale: scale
                    )

                    Button {
                        isAgreed.toggle()
                        localError = nil
                    } label: {
                        HStack(alignment: .top, spacing: 10 * scale) {
                            Image(systemName: isAgreed ? "checkmark.circle.fill" : "circle")
                                .foregroundColor(isAgreed ? FeatureAsset.Color.buttonColor.swiftUIColor : .secondary)
                            Text("독서마라톤 계정 연동을 위한 ")
                                .foregroundColor(Color(red: 159/255, green: 159/255, blue: 164/255))
                            + Text("개인정보 제3자 제공")
                                .foregroundColor(FeatureAsset.Color.buttonColor.swiftUIColor)
                            + Text("에\n동의합니다.")
                                .foregroundColor(Color(red: 159/255, green: 159/255, blue: 164/255))
                        }
                        .font(FeatureFontFamily.Pretendard.semiBold.swiftUIFont(size: 12 * scale))
                    }
                    .buttonStyle(.plain)

                    HStack(spacing: 24 * scale) {
                        socialIcon(FeatureAsset.Image.googleLoginIcon.swiftUIImage, scale: scale)
                        socialIcon(FeatureAsset.Image.naverLoginIcon.swiftUIImage, scale: scale)
                        socialIcon(FeatureAsset.Image.kakaoLoginIcon.swiftUIImage, scale: scale)
                    }
                    .frame(width: 342 * scale)
                    .padding(.top, 17 * scale)

                    if let message = localError ?? serverError {
                        InlineErrorText(message: message, scale: scale)
                            .lineLimit(2)
                            .frame(width: 342 * scale, alignment: .leading)
                    }
                }
                .offset(x: 25 * scale, y: 296 * scale)

                KeyboardAvoidingBottomButton(
                    screenHeight: geo.size.height,
                    contentBottomY: (734 + 52) * scale,
                    keyboard: keyboard
                ) {
                    PrimaryButton(
                        title: isSubmitting ? "연동 중..." : "연동하기",
                        scale: scale,
                        isEnabled: !isSubmitting,
                        action: submit
                    )
                    .offset(x: 47 * scale, y: 734 * scale)
                }
            }
        }
        .ignoresSafeArea()
        .onChange(of: read365Id) { _ in localError = nil }
        .onChange(of: password) { _ in localError = nil }
    }

    private func socialIcon(_ image: Image, scale: CGFloat) -> some View {
        image.resizable().scaledToFit().frame(width: 44 * scale, height: 44 * scale)
    }

    private func submit() {
        UIApplication.hideKeyboard()
        let id = read365Id.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !id.isEmpty, !password.isEmpty else {
            localError = "아이디와 비밀번호를 모두 입력해주세요."
            return
        }
        guard isAgreed else {
            localError = "개인정보 제3자 제공에 동의해주세요."
            return
        }
        onLink(id, password)
    }
}
