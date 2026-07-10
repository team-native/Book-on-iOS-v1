import SwiftUI
import UIKit

struct MarathonLinkView: View {
    @Binding var info: SignUpAccountInfo
    let onSkip: () -> Void
    let onComplete: () -> Void

    @StateObject private var keyboard = KeyboardObserver()

    private var isFormValid: Bool {
        !info.marathonId.isEmpty && !info.marathonPassword.isEmpty
    }

    var body: some View {
        GeometryReader { geo in
            let scale = geo.size.width / FigmaDesign.size.width

            ZStack(alignment: .topLeading) {
                FeatureAsset.Color.background.swiftUIColor
                    .contentShape(Rectangle())
                    .onTapGesture { hideKeyboard() }

                SignUpProgressBar(currentStep: 3, scale: scale)
                    .frame(width: 333 * scale, alignment: .leading)
                    .offset(x: 30 * scale, y: 160 * scale)

                VStack(alignment: .leading, spacing: 8 * scale) {
                    Text("계정연동")
                        .font(FeatureFontFamily.Pretendard.bold.swiftUIFont(size: 28 * scale))
                        .foregroundColor(.black)

                    Text("독서마라톤 아이디와 비밀번호를\n입력해 주세요")
                        .font(FeatureFontFamily.Pretendard.medium.swiftUIFont(size: 14 * scale))
                        .foregroundColor(FeatureAsset.Color.textDescription.swiftUIColor)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .offset(x: 25 * scale, y: 222 * scale)

                VStack(alignment: .leading, spacing: 20 * scale) {
                    AuthTextField(
                        icon: "envelope",
                        placeholder: "s20000@gsm.hs.kr",
                        text: $info.marathonId,
                        label: "독서마라톤 아이디",
                        scale: scale
                    )

                    AuthTextField(
                        icon: "lock",
                        placeholder: "비밀번호",
                        text: $info.marathonPassword,
                        label: "비밀번호",
                        isSecure: true,
                        scale: scale
                    )
                }
                .offset(x: 25 * scale, y: 312 * scale)

                KeyboardAvoidingBottomButton(
                    screenHeight: geo.size.height,
                    contentBottomY: (726 + 52 + 16 + 17) * scale,
                    keyboard: keyboard
                ) {
                    VStack(spacing: 16 * scale) {
                        PrimaryButton(title: "연동하고 가입완료", scale: scale, action: {
                            hideKeyboard()
                            guard isFormValid else { return }
                            info.isMarathonLinked = true
                            onComplete()
                        })

                        Button(action: onSkip) {
                            Text("나중에 할게요 · 건너뛰기")
                                .font(.system(size: 14 * scale, weight: .semibold))
                                .foregroundColor(FeatureAsset.Color.textPrimary.swiftUIColor)
                        }
                        .buttonStyle(.plain)
                    }
                    .frame(width: geo.size.width, alignment: .center)
                    .offset(y: 726 * scale)
                }
            }
            .frame(width: geo.size.width, height: geo.size.height, alignment: .topLeading)
        }
        .ignoresSafeArea()
    }

    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
