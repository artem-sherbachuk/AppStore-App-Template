

import UIKit

open class SpringView: UIView, Springable {
    @IBInspectable public var isRemovedOnCompletion: Bool = true
    public var isAnimationInProgress: Bool = false
    @IBInspectable public var autostart: Bool = false
    @IBInspectable public var autohide: Bool = false
    @IBInspectable public var animation: String = ""
    @IBInspectable public var force: CGFloat = 1
    @IBInspectable public var delay: CGFloat = 0
    @IBInspectable public var duration: CGFloat = 0.7
    @IBInspectable public var damping: CGFloat = 0.7
    @IBInspectable public var velocity: CGFloat = 0.7
    @IBInspectable public var repeatCount: Float = 1
    @IBInspectable public var x: CGFloat = 0
    @IBInspectable public var y: CGFloat = 0
    @IBInspectable public var scaleX: CGFloat = 1
    @IBInspectable public var scaleY: CGFloat = 1
    @IBInspectable public var rotate: CGFloat = 0
    @IBInspectable public var curve: String = ""
    public var opacity: CGFloat = 1
    public var animateFrom: Bool = false

    lazy private var spring : Spring = Spring(self)

    override open func awakeFromNib() {
        super.awakeFromNib()
        self.spring.customAwakeFromNib()
    }

    open override func layoutSubviews() {
        super.layoutSubviews()
        spring.customLayoutSubviews()
    }
    
    public func animate() {
        self.spring.animate()
    }

    public func animateNext(completion: @escaping () -> ()) {
        self.spring.animateNext(completion: completion)
    }

    public func animateTo() {
        self.spring.animateTo()
    }

    public func animateToNext(completion: @escaping () -> ()) {
        self.spring.animateToNext(completion: completion)
    }
}

extension Springable {
    func animate(name: String = "morph",
                      curve: String = "easyOut",
                      delay: CGFloat = 0,
                      y: CGFloat = 0,
                      x: CGFloat = 0,
                      duration: CGFloat = 0.9,
                      force: CGFloat = 1,
                      damping: CGFloat = 0.7,
                      repeatCount: Float = 1,
                      isRemovedOnCompletion: Bool = true,
                      completion: (() -> Void)? = nil) {
        animation = name
        self.repeatCount = repeatCount
        self.curve = "easyOut"
        self.force = force
        self.delay = delay
        self.damping = damping
        self.duration = duration
        self.y = y
        self.x = x
        self.isAnimationInProgress = true
        self.isRemovedOnCompletion = isRemovedOnCompletion
        animateNext {
            self.isAnimationInProgress = false
            completion?()
        }
    }
}

open class SpringVisualEffectView: UIVisualEffectView, Springable {
    @IBInspectable public var isRemovedOnCompletion: Bool = true
    public var isAnimationInProgress: Bool = false
    @IBInspectable public var autostart: Bool = false
    @IBInspectable public var autohide: Bool = false
    @IBInspectable public var animation: String = ""
    @IBInspectable public var force: CGFloat = 1
    @IBInspectable public var delay: CGFloat = 0
    @IBInspectable public var duration: CGFloat = 0.7
    @IBInspectable public var damping: CGFloat = 0.7
    @IBInspectable public var velocity: CGFloat = 0.7
    @IBInspectable public var repeatCount: Float = 1
    @IBInspectable public var x: CGFloat = 0
    @IBInspectable public var y: CGFloat = 0
    @IBInspectable public var scaleX: CGFloat = 1
    @IBInspectable public var scaleY: CGFloat = 1
    @IBInspectable public var rotate: CGFloat = 0
    @IBInspectable public var curve: String = ""
    public var opacity: CGFloat = 1
    public var animateFrom: Bool = false

    lazy private var spring : Spring = Spring(self)

    override open func awakeFromNib() {
        super.awakeFromNib()
        self.spring.customAwakeFromNib()
    }

    open override func layoutSubviews() {
        super.layoutSubviews()
        spring.customLayoutSubviews()
    }

    public func animate() {
        self.spring.animate()
    }

    public func animateNext(completion: @escaping () -> ()) {
        self.spring.animateNext(completion: completion)
    }

    public func animateTo() {
        self.spring.animateTo()
    }

    public func animateToNext(completion: @escaping () -> ()) {
        self.spring.animateToNext(completion: completion)
    }
}


open class SpringStackView: UIStackView, Springable {
    @IBInspectable public var isRemovedOnCompletion: Bool = true
    public var isAnimationInProgress: Bool = false
    @IBInspectable public var autostart: Bool = false
    @IBInspectable public var autohide: Bool = false
    @IBInspectable public var animation: String = ""
    @IBInspectable public var force: CGFloat = 1
    @IBInspectable public var delay: CGFloat = 0
    @IBInspectable public var duration: CGFloat = 0.7
    @IBInspectable public var damping: CGFloat = 0.7
    @IBInspectable public var velocity: CGFloat = 0.7
    @IBInspectable public var repeatCount: Float = 1
    @IBInspectable public var x: CGFloat = 0
    @IBInspectable public var y: CGFloat = 0
    @IBInspectable public var scaleX: CGFloat = 1
    @IBInspectable public var scaleY: CGFloat = 1
    @IBInspectable public var rotate: CGFloat = 0
    @IBInspectable public var curve: String = ""
    public var opacity: CGFloat = 1
    public var animateFrom: Bool = false

    lazy private var spring : Spring = Spring(self)

    override open func awakeFromNib() {
        super.awakeFromNib()
        self.spring.customAwakeFromNib()
    }

    open override func layoutSubviews() {
        super.layoutSubviews()
        spring.customLayoutSubviews()
    }

    public func animate() {
        self.spring.animate()
    }

    public func animateNext(completion: @escaping () -> ()) {
        self.spring.animateNext(completion: completion)
    }

    public func animateTo() {
        self.spring.animateTo()
    }

    public func animateToNext(completion: @escaping () -> ()) {
        self.spring.animateToNext(completion: completion)
    }
}

open class SpringCollectionView: UICollectionView, Springable {
    @IBInspectable public var isRemovedOnCompletion: Bool = true
    public var isAnimationInProgress: Bool = false
    @IBInspectable public var autostart: Bool = false
    @IBInspectable public var autohide: Bool = false
    @IBInspectable public var animation: String = ""
    @IBInspectable public var force: CGFloat = 1
    @IBInspectable public var delay: CGFloat = 0
    @IBInspectable public var duration: CGFloat = 0.7
    @IBInspectable public var damping: CGFloat = 0.7
    @IBInspectable public var velocity: CGFloat = 0.7
    @IBInspectable public var repeatCount: Float = 1
    @IBInspectable public var x: CGFloat = 0
    @IBInspectable public var y: CGFloat = 0
    @IBInspectable public var scaleX: CGFloat = 1
    @IBInspectable public var scaleY: CGFloat = 1
    @IBInspectable public var rotate: CGFloat = 0
    @IBInspectable public var curve: String = ""
    public var opacity: CGFloat = 1
    public var animateFrom: Bool = false

    lazy private var spring : Spring = Spring(self)

    override open func awakeFromNib() {
        super.awakeFromNib()
        self.spring.customAwakeFromNib()
    }

    open override func layoutSubviews() {
        super.layoutSubviews()
        spring.customLayoutSubviews()
    }

    public func animate() {
        self.spring.animate()
    }

    public func animateNext(completion: @escaping () -> ()) {
        self.spring.animateNext(completion: completion)
    }

    public func animateTo() {
        self.spring.animateTo()
    }

    public func animateToNext(completion: @escaping () -> ()) {
        self.spring.animateToNext(completion: completion)
    }
}

open class SpringCollectionViewCell: UICollectionViewCell, Springable {
    @IBInspectable public var isRemovedOnCompletion: Bool = true
    public var isAnimationInProgress: Bool = false
    @IBInspectable public var autostart: Bool = false
    @IBInspectable public var autohide: Bool = false
    @IBInspectable public var animation: String = ""
    @IBInspectable public var force: CGFloat = 1
    @IBInspectable public var delay: CGFloat = 0
    @IBInspectable public var duration: CGFloat = 0.7
    @IBInspectable public var damping: CGFloat = 0.7
    @IBInspectable public var velocity: CGFloat = 0.7
    @IBInspectable public var repeatCount: Float = 1
    @IBInspectable public var x: CGFloat = 0
    @IBInspectable public var y: CGFloat = 0
    @IBInspectable public var scaleX: CGFloat = 1
    @IBInspectable public var scaleY: CGFloat = 1
    @IBInspectable public var rotate: CGFloat = 0
    @IBInspectable public var curve: String = ""
    public var opacity: CGFloat = 1
    public var animateFrom: Bool = false

    lazy private var spring : Spring = Spring(self)

    override open func awakeFromNib() {
        super.awakeFromNib()
        self.spring.customAwakeFromNib()
    }

    open override func layoutSubviews() {
        super.layoutSubviews()
        spring.customLayoutSubviews()
    }

    public func animate() {
        self.spring.animate()
    }

    public func animateNext(completion: @escaping () -> ()) {
        self.spring.animateNext(completion: completion)
    }

    public func animateTo() {
        self.spring.animateTo()
    }

    public func animateToNext(completion: @escaping () -> ()) {
        self.spring.animateToNext(completion: completion)
    }
}

open class SpringTableViewCell: UITableViewCell, Springable {
    @IBInspectable public var isRemovedOnCompletion: Bool = true
    public var isAnimationInProgress: Bool = false
    @IBInspectable public var autostart: Bool = false
    @IBInspectable public var autohide: Bool = false
    @IBInspectable public var animation: String = ""
    @IBInspectable public var force: CGFloat = 1
    @IBInspectable public var delay: CGFloat = 0
    @IBInspectable public var duration: CGFloat = 0.7
    @IBInspectable public var damping: CGFloat = 0.7
    @IBInspectable public var velocity: CGFloat = 0.7
    @IBInspectable public var repeatCount: Float = 1
    @IBInspectable public var x: CGFloat = 0
    @IBInspectable public var y: CGFloat = 0
    @IBInspectable public var scaleX: CGFloat = 1
    @IBInspectable public var scaleY: CGFloat = 1
    @IBInspectable public var rotate: CGFloat = 0
    @IBInspectable public var curve: String = ""
    public var opacity: CGFloat = 1
    public var animateFrom: Bool = false

    lazy private var spring : Spring = Spring(self)

    override open func awakeFromNib() {
        super.awakeFromNib()
        self.spring.customAwakeFromNib()
    }

    open override func layoutSubviews() {
        super.layoutSubviews()
        spring.customLayoutSubviews()
    }

    public func animate() {
        self.spring.animate()
    }

    public func animateNext(completion: @escaping () -> ()) {
        self.spring.animateNext(completion: completion)
    }

    public func animateTo() {
        self.spring.animateTo()
    }

    public func animateToNext(completion: @escaping () -> ()) {
        self.spring.animateToNext(completion: completion)
    }
}

open class SpringSlider: UISlider, Springable {
    @IBInspectable public var isRemovedOnCompletion: Bool = true
    public var isAnimationInProgress: Bool = false
    @IBInspectable public var autostart: Bool = false
    @IBInspectable public var autohide: Bool = false
    @IBInspectable public var animation: String = ""
    @IBInspectable public var force: CGFloat = 1
    @IBInspectable public var delay: CGFloat = 0
    @IBInspectable public var duration: CGFloat = 0.7
    @IBInspectable public var damping: CGFloat = 0.7
    @IBInspectable public var velocity: CGFloat = 0.7
    @IBInspectable public var repeatCount: Float = 1
    @IBInspectable public var x: CGFloat = 0
    @IBInspectable public var y: CGFloat = 0
    @IBInspectable public var scaleX: CGFloat = 1
    @IBInspectable public var scaleY: CGFloat = 1
    @IBInspectable public var rotate: CGFloat = 0
    @IBInspectable public var curve: String = ""
    public var opacity: CGFloat = 1
    public var animateFrom: Bool = false

    lazy private var spring : Spring = Spring(self)

    override open func awakeFromNib() {
        super.awakeFromNib()
        self.spring.customAwakeFromNib()
    }

    open override func layoutSubviews() {
        super.layoutSubviews()
        spring.customLayoutSubviews()
    }

    public func animate() {
        self.spring.animate()
    }

    public func animateNext(completion: @escaping () -> ()) {
        self.spring.animateNext(completion: completion)
    }

    public func animateTo() {
        self.spring.animateTo()
    }

    public func animateToNext(completion: @escaping () -> ()) {
        self.spring.animateToNext(completion: completion)
    }
}

open class SpringSwitch: UISwitch, Springable {
    @IBInspectable public var isRemovedOnCompletion: Bool = true
    public var isAnimationInProgress: Bool = false
    @IBInspectable public var autostart: Bool = false
    @IBInspectable public var autohide: Bool = false
    @IBInspectable public var animation: String = ""
    @IBInspectable public var force: CGFloat = 1
    @IBInspectable public var delay: CGFloat = 0
    @IBInspectable public var duration: CGFloat = 0.7
    @IBInspectable public var damping: CGFloat = 0.7
    @IBInspectable public var velocity: CGFloat = 0.7
    @IBInspectable public var repeatCount: Float = 1
    @IBInspectable public var x: CGFloat = 0
    @IBInspectable public var y: CGFloat = 0
    @IBInspectable public var scaleX: CGFloat = 1
    @IBInspectable public var scaleY: CGFloat = 1
    @IBInspectable public var rotate: CGFloat = 0
    @IBInspectable public var curve: String = ""
    public var opacity: CGFloat = 1
    public var animateFrom: Bool = false

    lazy private var spring : Spring = Spring(self)

    override open func awakeFromNib() {
        super.awakeFromNib()
        self.spring.customAwakeFromNib()
    }

    open override func layoutSubviews() {
        super.layoutSubviews()
        spring.customLayoutSubviews()
    }

    public func animate() {
        self.spring.animate()
    }

    public func animateNext(completion: @escaping () -> ()) {
        self.spring.animateNext(completion: completion)
    }

    public func animateTo() {
        self.spring.animateTo()
    }

    public func animateToNext(completion: @escaping () -> ()) {
        self.spring.animateToNext(completion: completion)
    }
}

