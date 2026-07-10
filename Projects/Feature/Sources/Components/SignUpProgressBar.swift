import SwiftUI

struct SignUpProgressBar: View {
    let currentStep: Int
    var totalSteps: Int = 3
    var scale: CGFloat = 1

    @State private var fillProgress: CGFloat = 0

    var body: some View {
        let segmentSpacing = 10 * scale
        let segmentWidth = ((333 * scale) - (segmentSpacing * CGFloat(totalSteps - 1))) / CGFloat(totalSteps)

        VStack(alignment: .leading, spacing: 8 * scale) {
            HStack(spacing: segmentSpacing) {
                ForEach(1...totalSteps, id: \.self) { step in
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(FeatureAsset.Color.borderLight.swiftUIColor)

                        if step < currentStep {
                            Capsule()
                                .fill(FeatureAsset.Color.buttonColor.swiftUIColor)
                        } else if step == currentStep {
                            GeometryReader { proxy in
                                Capsule()
                                    .fill(FeatureAsset.Color.buttonColor.swiftUIColor)
                                    .frame(width: proxy.size.width * fillProgress)
                            }
                        }
                    }
                    .clipShape(Capsule())
                    .frame(width: segmentWidth, height: 4 * scale)
                }
            }

            Text("STEP \(currentStep) / \(totalSteps)")
                .font(FeatureFontFamily.Pretendard.semiBold.swiftUIFont(size: 13 * scale))
                .foregroundColor(FeatureAsset.Color.textDescription.swiftUIColor)
        }
        .onAppear {
            fillProgress = 0
            withAnimation(.easeInOut(duration: 0.32)) {
                fillProgress = 1
            }
        }
        .onChange(of: currentStep) { _ in
            fillProgress = 0
            withAnimation(.easeInOut(duration: 0.32)) {
                fillProgress = 1
            }
        }
    }
}
