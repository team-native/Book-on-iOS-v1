import SwiftUI

struct BookCardSkeleton: View {
    var scale: CGFloat = 1
    var isAnimating = true
    @State private var shimmer = false
    var body: some View {
        RoundedRectangle(cornerRadius: 8 * scale)
            .fill(Color(red: 226/255, green: 226/255, blue: 228/255))
            .frame(width: 132 * scale, height: 177 * scale)
            .overlay(
                LinearGradient(colors: [.clear, .white.opacity(0.55), .clear], startPoint: .leading, endPoint: .trailing)
                    .offset(x: shimmer ? 150 * scale : -150 * scale)
            )
            .clipShape(RoundedRectangle(cornerRadius: 8 * scale))
            .onAppear {
                guard isAnimating else { return }
                withAnimation(.linear(duration: 0.9).repeatForever(autoreverses: false)) { shimmer = true }
            }
    }
}
