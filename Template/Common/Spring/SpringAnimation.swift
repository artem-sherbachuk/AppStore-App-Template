

import UIKit

@objc public class SpringAnimation: NSObject {
    public class func spring(duration: TimeInterval, animations: @escaping () -> Void) {
        UIView.animate(
            withDuration: duration,
            delay: 0,
            usingSpringWithDamping: 0.7,
            initialSpringVelocity: 0.7,
            options: [],
            animations: {
                animations()
            },
            completion: nil
        )
    }

    public class func springEaseIn(duration: TimeInterval, animations: (() -> Void)!) {
        UIView.animate(
            withDuration: duration,
            delay: 0,
            options: .curveEaseIn,
            animations: {
                animations()
            },
            completion: nil
        )
    }

    public class func springEaseOut(duration: TimeInterval, animations: (() -> Void)!) {
        UIView.animate(
            withDuration: duration,
            delay: 0,
            options: .curveEaseOut,
            animations: {
                animations()
            }, completion: nil
        )
    }

    public class func springEaseInOut(duration: TimeInterval, animations: (() -> Void)!) {
        UIView.animate(
            withDuration: duration,
            delay: 0,
            options: UIView.AnimationOptions(),
            animations: {
                animations()
            }, completion: nil
        )
    }

    public class func springLinear(duration: TimeInterval, animations: (() -> Void)!) {
        UIView.animate(
            withDuration: duration,
            delay: 0,
            options: .curveLinear,
            animations: {
                animations()
            }, completion: nil
        )
    }

    public class func springWithDelay(duration: TimeInterval, delay: TimeInterval, animations: (() -> Void)!) {
        UIView.animate(
            withDuration: duration,
            delay: delay,
            usingSpringWithDamping: 0.7,
            initialSpringVelocity: 0.7,
            options: [],
            animations: {
                animations()
            }, completion: nil
        )
    }

    public class func springWithCompletion(duration: TimeInterval, animations: (() -> Void)!, completion: ((Bool) -> Void)!) {
        UIView.animate(
            withDuration: duration,
            delay: 0,
            usingSpringWithDamping: 0.7,
            initialSpringVelocity: 0.7,
            options: [],
            animations: {
                animations()
            }, completion: { finished in
                completion(finished)
            }
        )
    }
}
