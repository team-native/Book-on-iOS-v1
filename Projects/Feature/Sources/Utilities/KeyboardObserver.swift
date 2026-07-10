import Combine
import UIKit

final class KeyboardObserver: ObservableObject {
    @Published private(set) var height: CGFloat = 0

    private var cancellables = Set<AnyCancellable>()

    init() {
        NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)
            .compactMap { $0.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect }
            .map(\.height)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in self?.height = $0 }
            .store(in: &cancellables)

        NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in self?.height = 0 }
            .store(in: &cancellables)
    }
}

enum KeyboardButtonLayout {
    static func bottomY(
        containerHeight: CGFloat,
        buttonHeight: CGFloat,
        scale: CGFloat,
        keyboardHeight: CGFloat,
        hiddenY: CGFloat? = nil,
        subtractKeyboardHeightWhenVisible: Bool = false
    ) -> CGFloat {
        let visibleKeyboardHeight = keyboardHeight > (120 * scale) ? keyboardHeight : 0

        if visibleKeyboardHeight > 0 {
            let availableHeight = subtractKeyboardHeightWhenVisible
                ? containerHeight - visibleKeyboardHeight
                : containerHeight

            return max(0, availableHeight - buttonHeight - (8 * scale))
        }

        if let hiddenY {
            return hiddenY * scale
        }

        return containerHeight - buttonHeight - (26 * scale)
    }
}

extension UIApplication {
    static func hideKeyboard() {
        shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
