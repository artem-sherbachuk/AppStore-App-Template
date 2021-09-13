//
//  Extensions.swift
//  Hearing Aid App
//
//  Created by Artem Sherbachuk on 5/11/21.
//

import UIKit

extension String {
    func localized() -> String {
        return NSLocalizedString(self, comment: "")
    }
}

extension UIImage {
    var averageColor: UIColor? {
        guard let inputImage = CIImage(image: self) else { return nil }
        let extentVector = CIVector(x: inputImage.extent.origin.x, y: inputImage.extent.origin.y, z: inputImage.extent.size.width, w: inputImage.extent.size.height)

        guard let filter = CIFilter(name: "CIColumnAverage", parameters: [kCIInputImageKey: inputImage, kCIInputExtentKey: extentVector]) else { return nil }
        guard let outputImage = filter.outputImage else { return nil }

        var bitmap = [UInt8](repeating: 0, count: 4)
        let context = CIContext(options: [.workingColorSpace: kCFNull!])
        context.render(outputImage, toBitmap: &bitmap, rowBytes: 4, bounds: CGRect(x: 0, y: 0, width: 1, height: 1), format: .RGBA8, colorSpace: nil)

        return UIColor(red: CGFloat(bitmap[0]) / 255, green: CGFloat(bitmap[1]) / 255, blue: CGFloat(bitmap[2]) / 255, alpha: CGFloat(bitmap[3]) / 255)
    }
}

extension UIView {
    func addShadow(color: UIColor = #colorLiteral(red: 0.370555222, green: 0.3705646992, blue: 0.3705595732, alpha: 1),
                   shadowRadius: CGFloat = 5,
                   shadowOffset: CGSize = CGSize(width: 3, height: 4) ) {
        layer.shadowPath = UIBezierPath(rect: bounds).cgPath
        layer.shadowColor = color.cgColor
        layer.shadowOpacity = 0.7
        layer.shadowOffset = shadowOffset
        layer.shadowRadius = shadowRadius
    }

    func constraintsToParent(view: UIView) {
        leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
    }

    func scale(from: CGFloat, to: CGFloat,
               delay: TimeInterval = 0,
               duration: TimeInterval = 0.3, completion: ((Bool) -> Void)? = nil) {
        transform = CGAffineTransform(scaleX: from, y: from)
        UIView.animate(withDuration: duration, delay: delay, usingSpringWithDamping: 1.0, initialSpringVelocity: 0.5,
                       options: [.allowUserInteraction], animations: {
                        self.transform = CGAffineTransform(scaleX: to, y: to)
                       }, completion: completion)
    }

    func fadeIn(from: CGFloat, to: CGFloat,
                delay: TimeInterval = 0,
                duration: TimeInterval = 0.3, completion: ((Bool) -> Void)? = nil) {
        alpha = from
        UIView.animate(withDuration: duration, delay: delay,
                       options: [.allowUserInteraction, .curveEaseIn], animations: {
                        self.alpha = to
                       }, completion: completion)
    }

    func animateBackgoundColor(fromColor: UIColor,
                               toColor: UIColor,
                               delay: TimeInterval = 0,
                               duration: TimeInterval = 0.3) {
        backgroundColor = fromColor
        UIView.animate(withDuration: duration, delay: delay, usingSpringWithDamping: 1.0, initialSpringVelocity: 0.5, options: [.curveEaseOut, .allowUserInteraction], animations: {
            self.backgroundColor = toColor
        }, completion: nil)
    }

    static let shakingAnimationKey = "shakingAnimationKey"
    func addShakingAnimation(speed: Float = 1.0) {
        if layer.animation(forKey: UIView.shakingAnimationKey) != nil { return }

        let animation = CAKeyframeAnimation(keyPath: "transform")

        let wobbleAngle: CGFloat = speed > 1.0 ? 0.02 : 0.03

        let valLeft = NSValue(caTransform3D: CATransform3DMakeRotation(wobbleAngle, 0.0, 0.0, 1.0))
        let valRight = NSValue(caTransform3D: CATransform3DMakeRotation(-wobbleAngle, 0.0, 0.0, 1.0))

        animation.values = [valLeft,valRight]
        animation.timingFunction = CAMediaTimingFunction(name: .easeIn)
        animation.autoreverses = true
        animation.duration = 0.125
        animation.speed = max(1.0, speed)
        animation.repeatCount = .infinity

        layer.add(animation, forKey: UIView.shakingAnimationKey)
    }

    func removeShakingAnimation() {
        layer.removeAnimation(forKey: UIView.shakingAnimationKey)
    }
}

extension Collection {
    /// Returns the element at the specified index iff it is within bounds, otherwise nil.
    subscript (safe index: Index) -> Iterator.Element? {
        return indices.contains(index) ? self[index] : nil
    }
}

extension UIViewController {
    func topMostViewController() -> UIViewController? {
        if self.presentedViewController == nil {
            return self
        }
        if let navigation = self.presentedViewController as? UINavigationController {
            return navigation.visibleViewController?.topMostViewController()
        }
        if let tab = self.presentedViewController as? UITabBarController {
            if let selectedTab = tab.selectedViewController {
                return selectedTab.topMostViewController()
            }
            return tab.topMostViewController()
        }
        return self.presentedViewController?.topMostViewController()
    }
}

extension UIApplication {
    func topMostViewController() -> UIViewController? {
        return self.windows.first?.rootViewController?.topMostViewController()
    }
}

extension UITextView {

    @IBInspectable var actionsBar: Bool{
        get {
            return self.actionsBar
        }
        set (hasDone) {
            if hasDone {
                addActionsBar()
            }
        }
    }

    func addActionsBar() {
        let doneToolbar: UIToolbar = UIToolbar(frame: CGRect.init(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 50))
        doneToolbar.barStyle = .default

        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)

        let done: UIBarButtonItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(self.doneButtonAction))
        done.tintColor = Theme.buttonActiveColor

        let copyAll: UIBarButtonItem = UIBarButtonItem(title: "Copy All".localized(), style: .plain, target: self, action: #selector(copyAll))
        copyAll.tintColor = Theme.buttonActiveColor

        let items = [copyAll,flexSpace,done]
        doneToolbar.items = items
        doneToolbar.sizeToFit()

        self.inputAccessoryView = doneToolbar
    }

    @objc func doneButtonAction() {
        resignFirstResponder()
        TapticEngine.impact.feedback(.medium)
    }

    @objc func copyAll() {
        guard let text = text, !text.isEmpty else { return }
        UIPasteboard.general.string = text
        TapticEngine.notification.feedback(.success)
    }
}

extension UITextField {

    @IBInspectable var actionsBar: Bool{
        get {
            return self.actionsBar
        }
        set (hasDone) {
            if hasDone {
                addActionsBar()
            }
        }
    }

    func addActionsBar() {
        let doneToolbar: UIToolbar = UIToolbar(frame: CGRect.init(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 50))
        doneToolbar.barStyle = .default

        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)

        let done: UIBarButtonItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(self.doneButtonAction))
        done.tintColor = Theme.buttonActiveColor

        let copyAll: UIBarButtonItem = UIBarButtonItem(title: "Copy All".localized(), style: .plain, target: self, action: #selector(copyAll))
        copyAll.tintColor = Theme.buttonActiveColor

        let items = [copyAll,flexSpace,done]
        doneToolbar.items = items
        doneToolbar.sizeToFit()

        self.inputAccessoryView = doneToolbar
    }

    @objc func doneButtonAction() {
        resignFirstResponder()
        TapticEngine.impact.feedback(.medium)
    }

    @objc func copyAll() {
        guard let text = text, !text.isEmpty else { return }
        UIPasteboard.general.string = text
        TapticEngine.notification.feedback(.success)
    }
}

extension UIViewController {
    func addChildController(_ child: UIViewController,
                            inView container: UIView, withFrame frame: CGRect? = nil,
                            atIndex index: Int? = nil) {
        self.addChild(child)

        if let frame = frame {
            child.view.frame = frame
        } else {
            child.view.frame = container.bounds
        }

        if let index = index {
            container.insertSubview(child.view, at: index)
        } else {
            container.addSubview(child.view)
        }
        child.didMove(toParent: self)
    }

    func removeChildController(_ child: UIViewController) {
        child.willMove(toParent: nil)
        child.view.removeFromSuperview()
        child.removeFromParent()
    }
}

extension UITableView {
    func cell(_ view: UIView) -> UITableViewCell? {
        var superview = view.superview
        while superview is UITableViewCell == false && superview != nil {
            superview = superview?.superview
        }

        return superview as? UITableViewCell
    }

    func indexPathFor(_ view: UIView) -> IndexPath? {
        guard let cell = cell(view) else { return nil }
        return indexPath(for: cell)
    }
}



extension UserDefaults {
    func colorForKey(key: String) -> UIColor? {
        var colorReturnded: UIColor?
        if let colorData = data(forKey: key) {
            do {
                if let color = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(colorData) as? UIColor {
                    colorReturnded = color
                }
            } catch {
                print("Error UserDefaults")
            }
        }
        return colorReturnded
    }

    func setColor(color: UIColor?, forKey key: String) {
        var colorData: NSData?
        if let color = color {
            do {
                let data = try NSKeyedArchiver.archivedData(withRootObject: color, requiringSecureCoding: false) as NSData?
                colorData = data
            } catch {
                print("Error UserDefaults")
            }
        }
        set(colorData, forKey: key)
    }
}

extension UIColor {
    var isLight: Bool {
        var white: CGFloat = 0
        getWhite(&white, alpha: nil)
        return white > 0.5
    }

    func inverted(by percentage: CGFloat = 50) -> UIColor {
        // Usage
        if isLight {
            return darker(by: percentage)
        } else {
            return lighter(by: percentage)
        }
    }

    func lighter(by percentage: CGFloat = 30.0) -> UIColor {
        return self.adjust(by: abs(percentage) )
    }

    func darker(by percentage: CGFloat = 30.0) -> UIColor {
        return self.adjust(by: -1 * abs(percentage) )
    }

    func adjust(by percentage: CGFloat = 30.0) -> UIColor {
        var red: CGFloat = 0, green: CGFloat = 0, blue: CGFloat = 0, alpha: CGFloat = 0
        if self.getRed(&red, green: &green, blue: &blue, alpha: &alpha) {
            return UIColor(red: min(red + percentage/100, 1.0),
                           green: min(green + percentage/100, 1.0),
                           blue: min(blue + percentage/100, 1.0),
                           alpha: alpha)
        } else {
            return self
        }
    }
}


extension TimeInterval{

    func stringMinutesTime() -> String {
        let time = Int(self)
        let seconds = time % 60
        let minutes = (time / 60) % 60
        return String(format: "%0.2d:%0.2d",minutes,seconds)
    }
}
