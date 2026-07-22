import SwiftUI
import UIKit

struct SignUpVerificationView: View {
    let email: String
    let isSubmitting: Bool
    let errorMessage: String?
    let onVerify: (String) -> Void
    let onResend: () -> Void

    @State private var verificationCode = ""
    @State private var localError: String?
    @State private var remainingSeconds = 300

    private var remainingTimeText: String {
        String(format: "%02d:%02d", remainingSeconds / 60, remainingSeconds % 60)
    }

    var body: some View {
        GeometryReader { geo in
            let scale = geo.size.width / FigmaDesign.size.width

            ZStack(alignment: .topLeading) {
                FeatureAsset.Color.background.swiftUIColor.ignoresSafeArea()

                SignUpProgressBar(currentStep: 1, scale: scale)
                    .frame(width: 333 * scale, alignment: .leading)
                    .offset(x: 30 * scale, y: 131 * scale)

                VStack(alignment: .leading, spacing: 10 * scale) {
                    Text("인증번호 입력")
                        .font(FeatureFontFamily.Pretendard.bold.swiftUIFont(size: 28 * scale))
                        .foregroundColor(.black)

                    Text(email)
                        .font(FeatureFontFamily.Pretendard.medium.swiftUIFont(size: 12 * scale))
                        .foregroundColor(FeatureAsset.Color.textDescription.swiftUIColor)
                    + Text(" 으로 보낸\n6자리 코드를 입력해 주세요")
                        .font(FeatureFontFamily.Pretendard.semiBold.swiftUIFont(size: 12 * scale))
                        .foregroundColor(FeatureAsset.Color.textDescription.swiftUIColor)
                }
                .frame(width: 331 * scale, alignment: .leading)
                .offset(x: 31 * scale, y: 193 * scale)

                VerificationCodeInputView(code: $verificationCode, scale: scale)
                    .offset(x: 52 * scale, y: 330 * scale)
                    .onChange(of: verificationCode) { value in
                        verificationCode = String(value.filter { $0.isNumber }.prefix(6))
                        localError = nil
                    }

                HStack(spacing: 4 * scale) {
                    Image(systemName: "clock")
                    Text("\(remainingTimeText) 후 만료")
                }
                .font(FeatureFontFamily.Pretendard.medium.swiftUIFont(size: 11 * scale))
                .foregroundColor(FeatureAsset.Color.textDescription.swiftUIColor)
                .offset(x: 52 * scale, y: 372 * scale)

                if let message = localError ?? errorMessage {
                    InlineErrorText(message: message, scale: scale)
                        .offset(x: 52 * scale, y: 396 * scale)
                }

                VStack(spacing: 24 * scale) {
                    PrimaryButton(
                        title: isSubmitting ? "인증 중..." : "인증하고 계속하기",
                        scale: scale,
                        isEnabled: !isSubmitting
                    ) {
                        UIApplication.shared.sendAction(
                            #selector(UIResponder.resignFirstResponder),
                            to: nil,
                            from: nil,
                            for: nil
                        )
                        guard verificationCode.count == 6 else {
                            localError = "인증번호 6자리를 입력해주세요."
                            return
                        }
                        onVerify(verificationCode)
                    }

                    HStack(spacing: 4 * scale) {
                        Text("코드를 받지 못하셨나요?")
                        Button("재전송") {
                            guard !isSubmitting else { return }
                            verificationCode = ""
                            localError = nil
                            remainingSeconds = 300
                            onResend()
                        }
                        .foregroundColor(FeatureAsset.Color.buttonColor.swiftUIColor)
                    }
                    .font(FeatureFontFamily.Pretendard.medium.swiftUIFont(size: 12 * scale))
                    .foregroundColor(FeatureAsset.Color.textDescription.swiftUIColor)
                    .frame(width: 300 * scale)
                }
                .frame(width: geo.size.width)
                .frame(maxHeight: .infinity, alignment: .bottom)
                .padding(.bottom, max(18 * scale, geo.safeAreaInsets.bottom + 8 * scale))
            }
        }
        .onReceive(Timer.publish(every: 1, on: .main, in: .common).autoconnect()) { _ in
            guard remainingSeconds > 0 else { return }
            remainingSeconds -= 1
        }
    }
}
