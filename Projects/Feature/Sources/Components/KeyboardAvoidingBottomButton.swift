import SwiftUI

struct KeyboardAvoidingBottomButton<Content: View>: View {
    let screenHeight: CGFloat
    let contentBottomY: CGFloat
    @ObservedObject var keyboard: KeyboardObserver
    @ViewBuilder let content: () -> Content

    private var overlap: CGFloat {
        guard keyboard.isVisible, keyboard.height > 0 else { return 0 }

        let keyboardTop = screenHeight - keyboard.height
        return max(0, contentBottomY - keyboardTop)
    }

    var body: some View {
        content()
            .offset(y: -overlap)
            .animation(.easeOut(duration: 0.2), value: overlap)
    }
}
