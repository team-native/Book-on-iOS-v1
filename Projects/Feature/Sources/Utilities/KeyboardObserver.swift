import Combine
import UIKit

final class KeyboardObserver: ObservableObject {
    @Published private(set) var height: CGFloat = 0
    @Published private(set) var isVisible = false

    private var cancellables = Set<AnyCancellable>()

    init() {
        NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] notification in self?.update(with: notification) }
            .store(in: &cancellables)

        NotificationCenter.default.publisher(for: UIResponder.keyboardWillChangeFrameNotification)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] notification in self?.update(with: notification) }
            .store(in: &cancellables)

        NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in self?.reset() }
            .store(in: &cancellables)

        NotificationCenter.default.publisher(for: UIResponder.keyboardDidHideNotification)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in self?.reset() }
            .store(in: &cancellables)
    }

    func reset() {
        height = 0
        isVisible = false
    }

    private func update(with notification: Notification) {
        guard let frame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else {
            reset()
            return
        }

        let visibleHeight = max(0, UIScreen.main.bounds.height - frame.minY)
        height = visibleHeight
        isVisible = visibleHeight > 0
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
