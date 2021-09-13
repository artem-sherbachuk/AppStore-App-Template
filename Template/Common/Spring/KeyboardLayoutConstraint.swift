import UIKit

class KeyboardLayoutConstraint: NSLayoutConstraint {

    private var offset : CGFloat = 0
    private var keyboardVisibleHeight : CGFloat = 0

    @IBInspectable var keyboardOffset : CGFloat = 0

    private lazy var keyboardNotification = KeyboardNotification()

    override func awakeFromNib() {
        super.awakeFromNib()

        offset = constant

        keyboardNotification.keyboardWillShow = { [weak self] notification in
            self?.keyboardWillShowNotification(notification)
        }

        keyboardNotification.keyboardWillHide = { [weak self] notification in
            self?.keyboardWillHideNotification(notification)
        }
    }

    // MARK: Notification

    @objc func keyboardWillShowNotification(_ notification: Notification) {
        if let userInfo = notification.userInfo {
            if let frameValue = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
                let frame = frameValue.cgRectValue
                keyboardVisibleHeight = frame.size.height + keyboardOffset
            }

            self.updateConstant()
            switch (userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber, userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as? NSNumber) {
            case let (.some(duration), .some(curve)):

                let options = UIView.AnimationOptions(rawValue: curve.uintValue)

                UIView.animate(
                    withDuration: TimeInterval(duration.doubleValue),
                    delay: 0,
                    options: options,
                    animations: {
                        UIApplication.shared.windows.first?.layoutIfNeeded()
                        return
                    }, completion: { finished in
                    })
            default:

                break
            }

        }

    }

    @objc func keyboardWillHideNotification(_ notification: NSNotification) {
        keyboardVisibleHeight = 0
        self.updateConstant()

        if let userInfo = notification.userInfo {

            switch (userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber, userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as? NSNumber) {
            case let (.some(duration), .some(curve)):

                let options = UIView.AnimationOptions(rawValue: curve.uintValue)

                UIView.animate(
                    withDuration: TimeInterval(duration.doubleValue),
                    delay: 0,
                    options: options,
                    animations: {
                        UIApplication.shared.windows.first?.layoutIfNeeded()
                        return
                    }, completion: { finished in
                    })
            default:
                break
            }
        }
    }

    func updateConstant() {
        self.constant = offset + keyboardVisibleHeight
    }

}

final class KeyboardNotification: NSObject {

    var keyboardWillShow: ((Notification) -> Void)?
    var keyboardWillHide: ((NSNotification) -> Void)?

    override init() {
        super.init()
        NotificationCenter.default.addObserver(self, selector: #selector(KeyboardLayoutConstraint.keyboardWillShowNotification(_:)), name: UIWindow.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(KeyboardLayoutConstraint.keyboardWillHideNotification(_:)), name: UIWindow.keyboardWillHideNotification, object: nil)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: Notification

    @objc func keyboardWillShowNotification(_ notification: Notification) {
        keyboardWillShow?(notification)
    }

    @objc func keyboardWillHideNotification(_ notification: NSNotification) {
        keyboardWillHide?(notification)
    }
}
