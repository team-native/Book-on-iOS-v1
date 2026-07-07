import SwiftUI

public struct SplashView: View {
    private let onFinished: () -> Void

    @State private var isLogoVisible = false

    public init(onFinished: @escaping () -> Void = {}) {
        self.onFinished = onFinished
    }

    public var body: some View {
        GeometryReader { geo in
            let scale = geo.size.width / FigmaDesign.size.width

            ZStack {
                FeatureAsset.Color.background.swiftUIColor

                FeatureAsset.Image.bookOnLogo.swiftUIImage
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100 * scale, height: 97 * scale)
                    .opacity(isLogoVisible ? 1 : 0)
            }
            .frame(width: geo.size.width, height: geo.size.height)
        }
        .ignoresSafeArea()
        .onAppear {
            withAnimation(.easeOut(duration: 0.4)) {
                isLogoVisible = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                onFinished()
            }
        }
    }
}

struct SplashView_Previews: PreviewProvider {
    static var previews: some View {
        SplashView()
    }
}
