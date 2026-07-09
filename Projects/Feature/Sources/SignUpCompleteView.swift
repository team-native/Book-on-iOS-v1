import SwiftUI

struct SignUpCompleteView: View {
    let name: String
    let hasLinkedMarathon: Bool
    let onStart: () -> Void

    @State private var checkScale: CGFloat = 0.72
    @State private var checkProgress: CGFloat = 0
    @State private var glowScale: CGFloat = 0.75
    @State private var glowOpacity: Double = 0
    @State private var circleOpacity: Double = 0
    @State private var firstRippleScale: CGFloat = 0.55
    @State private var firstRippleOpacity: Double = 0
    @State private var secondRippleScale: CGFloat = 0.55
    @State private var secondRippleOpacity: Double = 0
    @State private var burstScale: CGFloat = 0.6
    @State private var burstOpacity: Double = 0
    @State private var bookCount = 0
    @State private var bookCountScale: CGFloat = 1

    var body: some View {
        GeometryReader { geo in
            let scale = geo.size.width / FigmaDesign.size.width
            let successSize = 82 * scale

            ZStack(alignment: .topLeading) {
                FeatureAsset.Color.background.swiftUIColor

                RadialGradient(
                    colors: [Color(red: 0.925, green: 0.980, blue: 0.796).opacity(0.5), .clear],
                    center: UnitPoint(x: 0.5, y: 0),
                    startRadius: 0,
                    endRadius: 260 * scale
                )
                .frame(height: 400 * scale)
                .frame(maxWidth: .infinity)

                ZStack {
                    Circle()
                        .fill(FeatureAsset.Color.buttonColor.swiftUIColor.opacity(0.24))
                        .frame(width: successSize * 1.38, height: successSize * 1.38)
                        .blur(radius: 22 * scale)
                        .scaleEffect(glowScale)
                        .opacity(glowOpacity)

                    Circle()
                        .stroke(FeatureAsset.Color.buttonColor.swiftUIColor, lineWidth: 3 * scale)
                        .scaleEffect(firstRippleScale)
                        .opacity(firstRippleOpacity)

                    Circle()
                        .stroke(FeatureAsset.Color.buttonColor.swiftUIColor, lineWidth: 3 * scale)
                        .scaleEffect(secondRippleScale)
                        .opacity(secondRippleOpacity)

                    SuccessBurstRays(size: successSize)
                        .scaleEffect(burstScale)
                        .opacity(burstOpacity)

                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color(red: 0.561, green: 0.788, blue: 0.227),
                                    Color(red: 0.478, green: 0.671, blue: 0.118)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .overlay(
                            Circle()
                                .stroke(Color.white.opacity(0.35), lineWidth: 2 * scale)
                                .padding(1 * scale)
                                .offset(y: -1 * scale)
                        )
                        .shadow(color: FeatureAsset.Color.buttonColor.swiftUIColor.opacity(0.45), radius: 22 * scale, x: 0, y: 10 * scale)
                        .scaleEffect(checkScale)
                        .opacity(circleOpacity)

                    CheckmarkShape()
                        .trim(from: 0, to: checkProgress)
                        .stroke(
                            Color.white,
                            style: StrokeStyle(lineWidth: 11 * scale, lineCap: .round, lineJoin: .round)
                        )
                        .frame(width: successSize * 0.44, height: successSize * 0.36)
                }
                .frame(width: successSize, height: successSize)
                .offset(x: (geo.size.width - successSize) / 2, y: 266 * scale)

                VStack(spacing: 16 * scale) {
                    Text("가입 완료!")
                        .font(FeatureFontFamily.Pretendard.bold.swiftUIFont(size: 28 * scale))
                        .foregroundColor(.black)

                    Text("\(name) 님, 환영해요.\nBook - on에서 마음껏 읽어보세요.")
                        .multilineTextAlignment(.center)
                        .font(FeatureFontFamily.Pretendard.semiBold.swiftUIFont(size: 16 * scale))
                        .foregroundColor(Color(red: 0.388, green: 0.388, blue: 0.4))
                }
                .frame(width: geo.size.width, alignment: .center)
                .offset(y: 420 * scale)

                if hasLinkedMarathon {
                    HStack(spacing: 0) {
                        statColumn(value: "\(bookCount)", label: "보유 도서", scale: scale, valueScale: bookCountScale)

                        Rectangle()
                            .fill(Color(red: 0.851, green: 0.851, blue: 0.851))
                            .frame(width: 1 * scale, height: 40 * scale)

                        statColumn(value: "연동됨", label: "독서마라톤", scale: scale)
                    }
                    .frame(width: 141 * scale, height: 64 * scale)
                    .background(Color(red: 0.965, green: 0.965, blue: 0.965))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12 * scale)
                            .stroke(Color(red: 0.878, green: 0.878, blue: 0.878), lineWidth: 1.2 * scale)
                    )
                    .cornerRadius(12 * scale)
                    .offset(x: 127 * scale, y: 540 * scale)
                }

                PrimaryButton(title: "로그인", scale: scale, action: onStart)
                    .frame(width: geo.size.width, alignment: .center)
                    .offset(y: 726 * scale)
            }
            .frame(width: geo.size.width, height: geo.size.height, alignment: .topLeading)
        }
        .ignoresSafeArea()
        .onAppear(perform: runEntranceAnimation)
    }

    private func runEntranceAnimation() {
        bookCount = 0
        checkScale = 0
        checkProgress = 0
        glowScale = 0.75
        glowOpacity = 0
        circleOpacity = 0
        firstRippleScale = 0.55
        firstRippleOpacity = 0
        secondRippleScale = 0.55
        secondRippleOpacity = 0
        burstScale = 0.6
        burstOpacity = 0
        bookCountScale = 1

        withAnimation(.spring(response: 0.55, dampingFraction: 0.58).delay(0.1)) {
            checkScale = 1
            glowScale = 1
            glowOpacity = 1
            circleOpacity = 1
        }

        startRipple(after: 0.35, isFirst: true)
        startRipple(after: 0.7, isFirst: false)

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.45) {
            burstScale = 0.6
            burstOpacity = 0

            withAnimation(.easeOut(duration: 0.26)) {
                burstScale = 0.9
                burstOpacity = 0.9
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.26) {
                withAnimation(.easeOut(duration: 0.54)) {
                    burstScale = 1.35
                    burstOpacity = 0
                }
            }
        }

        withAnimation(.easeInOut(duration: 0.42).delay(0.5)) {
            checkProgress = 1
        }

        guard hasLinkedMarathon else { return }

        var delay = 0.7

        for value in 1...10 {
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                withAnimation(.spring(response: 0.18, dampingFraction: 0.55)) {
                    bookCount = value
                    bookCountScale = 1.18
                }

                DispatchQueue.main.asyncAfter(deadline: .now() + 0.12) {
                    withAnimation(.spring(response: 0.22, dampingFraction: 0.72)) {
                        bookCountScale = 1
                    }
                }
            }

            let progress = Double(value) / 10
            delay += 0.16 + pow(progress, 1.6) * 0.16
        }
    }

    private func startRipple(after delay: Double, isFirst: Bool) {
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            if isFirst {
                firstRippleScale = 0.55
                firstRippleOpacity = 0.4

                withAnimation(.easeOut(duration: 1.4)) {
                    firstRippleScale = 1.7
                    firstRippleOpacity = 0
                }
            } else {
                secondRippleScale = 0.55
                secondRippleOpacity = 0.4

                withAnimation(.easeOut(duration: 1.4)) {
                    secondRippleScale = 1.7
                    secondRippleOpacity = 0
                }
            }
        }
    }

    private func statColumn(value: String, label: String, scale: CGFloat, valueScale: CGFloat = 1) -> some View {
        VStack(spacing: 2) {
            Text(value)
                .font(FeatureFontFamily.Pretendard.semiBold.swiftUIFont(size: 14 * scale))
                .foregroundColor(Color(red: 0.482, green: 0.671, blue: 0.122))
                .scaleEffect(valueScale)

            Text(label)
                .font(FeatureFontFamily.Pretendard.semiBold.swiftUIFont(size: 9 * scale))
                .foregroundColor(Color(red: 0.604, green: 0.604, blue: 0.631))
        }
        .frame(maxWidth: .infinity)
    }
}

private struct CheckmarkShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.minX + rect.width * 0.12, y: rect.minY + rect.height * 0.55))
        path.addLine(to: CGPoint(x: rect.minX + rect.width * 0.42, y: rect.maxY - rect.height * 0.12))
        path.addLine(to: CGPoint(x: rect.maxX - rect.width * 0.08, y: rect.minY + rect.height * 0.12))
        return path
    }
}

private struct SuccessBurstRays: View {
    let size: CGFloat

    private let angles: [Double] = [0, 45, 90, 135, 180, 225, 270, 315]

    var body: some View {
        ZStack {
            ForEach(angles, id: \.self) { angle in
                Capsule()
                    .fill(rayColor(for: angle))
                    .frame(width: size * 0.03, height: size * 0.14)
                    .offset(y: -size * 0.58)
                    .rotationEffect(.degrees(angle))
            }
        }
    }

    private func rayColor(for angle: Double) -> Color {
        angle.truncatingRemainder(dividingBy: 90) == 0
            ? Color(red: 0.478, green: 0.671, blue: 0.118)
            : Color(red: 0.561, green: 0.788, blue: 0.227)
    }
}
