import SwiftUI

struct UsageGuideView: View {
    let onBack: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                AppBackButton(action: onBack)
                    .accessibilityLabel("마이페이지로 돌아가기")
                Spacer()
                Text("이용 안내")
                    .font(FeatureFontFamily.Pretendard.bold.swiftUIFont(size: 18))
                Spacer()
                Color.clear.frame(width: 40, height: 40)
            }
            .padding(.horizontal, 16)
            .padding(.top, 12)

            ScrollView {
                VStack(alignment: .leading, spacing: 28) {
                    guideSection(
                        title: "도서 찾기",
                        detail: "홈에서 도서를 검색하거나 도서실에서 분류별 도서를 살펴볼 수 있어요. 도서를 누르면 상세 정보를 볼 수 있습니다."
                    )
                    guideSection(
                        title: "관심 도서",
                        detail: "도서 상세 화면에서 관심 도서를 추가하거나 해제할 수 있어요. 저장한 도서는 마이페이지의 즐겨찾기 목록에서 확인할 수 있습니다."
                    )
                    guideSection(
                        title: "대출 / 반납 내역",
                        detail: "마이페이지에서 현재 대출 중인 도서와 대출 내역을 확인할 수 있어요."
                    )
                    guideSection(
                        title: "독서마라톤 연동",
                        detail: "마이페이지의 연동하기에서 독서로 로그인을 완료하면 계정을 연결할 수 있어요."
                    )
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 24)
                .padding(.top, 36)
                .padding(.bottom, 40)
            }
        }
        .background(Color.white)
    }

    private func guideSection(title: String, detail: String) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(FeatureFontFamily.Pretendard.bold.swiftUIFont(size: 18))
                .foregroundColor(FeatureAsset.Color.textPrimary.swiftUIColor)
            Text(detail)
                .font(FeatureFontFamily.Pretendard.medium.swiftUIFont(size: 15))
                .foregroundColor(FeatureAsset.Color.textDescription.swiftUIColor)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}
