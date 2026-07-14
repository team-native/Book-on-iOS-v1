import SwiftUI

public struct SignUpFlowView: View {
    @State private var info = SignUpAccountInfo()
    @State private var currentStep: SignUpFlowStep

    private let onFinished: () -> Void

    public init(
        startsAtAccountStep: Bool = false,
        onFinished: @escaping () -> Void = {}
    ) {
        _currentStep = State(initialValue: startsAtAccountStep ? .account : .school)
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
        }
        .animation(nil, value: currentStep)
        .navigationBarBackButtonHidden(currentStep == .complete)
    }

    private func move(to step: SignUpFlowStep) {
        var transaction = Transaction()
        transaction.disablesAnimations = true

        withTransaction(transaction) {
            currentStep = step
        }
    }
}

private enum SignUpFlowStep {
    case school
    case account
    case marathon
    case complete
}
