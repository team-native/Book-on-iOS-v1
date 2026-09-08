import SwiftUI
import Service

@MainActor
private final class LoanHistoryViewModel: ObservableObject {
    @Published var currentLoans: [CurrentLoan] = []
    @Published var history: [LoanHistoryItem] = []
    @Published var isLoading = false
    @Published var extendingLoanId: Int?
    @Published var errorMessage: String?
    private let service: LoanService

    init(service: LoanService) { self.service = service }

    func load(status: String) async {
        guard !isLoading else { return }
        isLoading = true; errorMessage = nil
        do {
            if status == "BORROWED" {
                currentLoans = try await service.fetchCurrentLoans()
            } else {
                history = try await service.fetchHistory(status: status).items
            }
        } catch { errorMessage = error.localizedDescription }
        isLoading = false
    }

    func extend(_ loan: CurrentLoan) async {
        guard extendingLoanId == nil, loan.extensionAvailable else { return }
        extendingLoanId = loan.loanId; errorMessage = nil
        do {
            _ = try await service.extendLoan(loanId: loan.loanId)
            currentLoans = try await service.fetchCurrentLoans()
        } catch { errorMessage = error.localizedDescription }
        extendingLoanId = nil
    }
}

public struct LoanHistoryView: View {
    private enum Filter: String { case borrowing = "BORROWED", returned = "RETURNED", all = "ALL" }
    @State private var filter: Filter = .borrowing
    @StateObject private var viewModel: LoanHistoryViewModel
    private let onBack: () -> Void

    public init(loanService: LoanService = LoanService(), onBack: @escaping () -> Void = {}) {
        _viewModel = StateObject(wrappedValue: LoanHistoryViewModel(service: loanService))
        self.onBack = onBack
    }

    public var body: some View {
        GeometryReader { geo in
            let scale = geo.size.width / 392
            ZStack(alignment: .topLeading) {
                Color.white.ignoresSafeArea()
                AppBackButton(scale: scale, action: onBack).offset(x: 25 * scale, y: 64 * scale)
                Text("대출 / 반납 내역").font(FeatureFontFamily.Pretendard.bold.swiftUIFont(size: 16 * scale)).offset(x: 146 * scale, y: 74 * scale)
                HStack(spacing: 10 * scale) {
                    filterChip("대출 중 \(viewModel.currentLoans.count)", .borrowing, scale)
                    filterChip("반납 완료", .returned, scale)
                    filterChip("전체", .all, scale)
                }.offset(x: 23 * scale, y: 118 * scale)

                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 16 * scale) {
                        if viewModel.isLoading { ProgressView().frame(maxWidth: .infinity).padding(.top, 40) }
                        else if let error = viewModel.errorMessage { Text(error).foregroundColor(.red).font(.caption) }
                        else if filter == .borrowing { currentContent(scale: scale) }
                        else { historyContent(scale: scale) }
                    }.padding(.bottom, 30)
                }.frame(width: 344 * scale, height: geo.size.height - 190 * scale).offset(x: 24 * scale, y: 174 * scale)
            }
        }
        .ignoresSafeArea()
        .task { await viewModel.load(status: filter.rawValue) }
    }

    private func filterChip(_ title: String, _ value: Filter, _ scale: CGFloat) -> some View {
        FilterChip(title: title, isSelected: filter == value, scale: scale) {
            filter = value
            Task { await viewModel.load(status: value.rawValue) }
        }
    }

    @ViewBuilder private func currentContent(scale: CGFloat) -> some View {
        if viewModel.currentLoans.isEmpty { Text("현재 대출 중인 도서가 없어요.").foregroundColor(FeatureAsset.Color.textDescription.swiftUIColor) }
        ForEach(viewModel.currentLoans) { loan in
            LoanHistoryRow(
                title: loan.title,
                author: loan.author,
                dueText: "반납 \(loan.dueDate)",
                badge: loan.extensionAvailable
                    ? (viewModel.extendingLoanId == loan.loanId ? "연장 중" : "연장하기")
                    : dDayText(loan.dDay),
                scale: scale,
                action: { Task { await viewModel.extend(loan) } }
            )
        }
    }

    @ViewBuilder private func historyContent(scale: CGFloat) -> some View {
        if viewModel.history.isEmpty { Text("대출 이력이 없어요.").foregroundColor(FeatureAsset.Color.textDescription.swiftUIColor) }
        ForEach(viewModel.history) { loan in
            LoanHistoryRow(
                title: loan.title,
                dueText: loan.returnedAt.map { "반납 \($0)" } ?? "반납 예정 \(loan.dueDate)",
                badge: statusTitle(loan.status),
                isCompleted: loan.status == "RETURNED",
                scale: scale,
                action: {}
            )
        }
    }

    private func statusTitle(_ status: String) -> String {
        switch status { case "RETURNED": return "반납 완료"; case "OVERDUE": return "연체"; default: return "대출 중" }
    }

    private func dDayText(_ dDay: Int) -> String {
        if dDay > 0 { return "D-\(dDay)" }
        if dDay == 0 { return "D-Day" }
        return "D+\(abs(dDay))"
    }
}

struct LoanHistoryView_Previews: PreviewProvider { static var previews: some View { LoanHistoryView().previewDevice("iPhone 16") } }
