import SwiftUI

public struct SignUpFlowView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var info = SignUpAccountInfo()
    @State private var currentStep: SignUpFlowStep = .school

    private let onFinished: () -> Void

    public init(onFinished: @escaping () -> Void = {}) {
        self.onFinished = onFinished
    }

    public var body: some View {
        ZStack {
            switch currentStep {
            case .school:
                SignUpStep1View(
                    info: $info,
                    onNext: { move(to: .account) }
                )
            case .account:
                SignUpStep2View(
                    info: $info,
                    onNext: { move(to: .marathon) }
                )
            case .marathon:
                SignUpStep3View(
                    info: $info,
                    onNext: { move(to: .complete) }
                )
            case .complete:
                SignUpCompleteView(
                    name: info.name,
                    hasLinkedMarathon: info.isMarathonLinked,
                    onStart: onFinished
                )
            }

            if currentStep != .complete {
                AppBackButton(scale: 1, action: goBack)
                    .frame(width: 44, height: 44)
                    .background(Color.white)
                    .clipShape(Circle())
                    .shadow(color: .black.opacity(0.08), radius: 12, x: 0, y: 6)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                    .padding(.leading, 18)
                    .padding(.top, 29)
                    .zIndex(200)
            }
        }
        .animation(nil, value: currentStep)
        .toolbar(.hidden, for: .navigationBar)
    }

    private func move(to step: SignUpFlowStep) {
        var transaction = Transaction()
        transaction.disablesAnimations = true

        withTransaction(transaction) {
            currentStep = step
        }
    }

    private func goBack() {
        switch currentStep {
        case .school:
            dismiss()
        case .account:
            move(to: .school)
        case .marathon:
            move(to: .account)
        case .complete:
            break
        }
    }
}

private enum SignUpFlowStep {
    case school
    case account
    case marathon
    case complete
}
