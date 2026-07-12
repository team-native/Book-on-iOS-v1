import SwiftUI

public struct LoanHistoryView: View {
    private enum Filter { case borrowing, returned, all }
    @State private var filter: Filter = .borrowing
    private let onBack: () -> Void

    public init(onBack: @escaping () -> Void = {}) {
        self.onBack = onBack
    }
    public var body: some View {
        GeometryReader { geo in
            let scale = geo.size.width / 392
            ZStack(alignment: .topLeading) {
                Color.white
                AppBackButton(scale: scale, action: onBack).offset(x: 25 * scale, y: 64 * scale)
                Text("대출 / 반납 내역").font(FeatureFontFamily.Pretendard.bold.swiftUIFont(size: 16 * scale)).offset(x: 146 * scale, y: 74 * scale)
                HStack(spacing: 10 * scale) {
                    FilterChip(title: "대출 중 2", isSelected: filter == .borrowing, scale: scale, action: { filter = .borrowing })
                    FilterChip(title: "반납 완료", isSelected: filter == .returned, scale: scale, action: { filter = .returned })
                    FilterChip(title: "전체", isSelected: filter == .all, scale: scale, action: { filter = .all })
                }.offset(x: 23 * scale, y: 118 * scale)
                content(scale: scale).offset(x: 24 * scale, y: 174 * scale)
            }.frame(width: geo.size.width, height: geo.size.height, alignment: .topLeading)
        }.ignoresSafeArea()
    }
    private func content(scale: CGFloat) -> some View {
        VStack(alignment: .leading, spacing: 16 * scale) {
            if filter != .returned {
                Text("대출 중").font(FeatureFontFamily.Pretendard.semiBold.swiftUIFont(size: 14 * scale)).foregroundColor(Color(red: 142/255, green: 142/255, blue: 147/255)).padding(.bottom, 14 * scale)
                LoanHistoryRow(title: "클린 코드", dueText: "반납 07.11", badge: "D - 3", scale: scale, action: {})
                LoanHistoryRow(title: "클린 아키텍처", dueText: "반납 07.17", badge: "D - 9", scale: scale, action: {})
            }
            if filter != .borrowing {
                Text("지난 대출").font(FeatureFontFamily.Pretendard.semiBold.swiftUIFont(size: 14 * scale)).foregroundColor(Color(red: 142/255, green: 142/255, blue: 147/255)).padding(.top, filter == .all ? 8 * scale : 0)
                LoanHistoryRow(title: "클린 코더", dueText: "반납 04.09", badge: "반납 완료", isCompleted: true, scale: scale, action: {})
                LoanHistoryRow(title: "클린 소프트웨어", dueText: "반납 03.08", badge: "반납 완료", isCompleted: true, scale: scale, action: {})
            }
        }
    }
}

struct LoanHistoryView_Previews: PreviewProvider { static var previews: some View { LoanHistoryView().previewDevice("iPhone 16") } }
