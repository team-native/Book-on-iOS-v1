import Combine
import UIKit

final class KeyboardObserver: ObservableObject {
    @Published private(set) var height: CGFloat = 0
    @Published private(set) var isVisible = false

    private var cancellables = Set<AnyCancellable>()

    init() {
        NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] notification in
                self?.update(with: notification)
            }
            .store(in: &cancellables)

        NotificationCenter.default.publisher(for: UIResponder.keyboardWillChangeFrameNotification)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] notification in
                self?.update(with: notification)
            }
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

        let screenHeight = UIScreen.main.bounds.height
        let visibleHeight = max(0, screenHeight - frame.minY)

        if visibleHeight > 0 {
            height = visibleHeight
            isVisible = true
        } else {
            reset()
        }
    }
}
