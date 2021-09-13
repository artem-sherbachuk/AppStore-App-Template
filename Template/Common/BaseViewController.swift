//
//  BaseViewController.swift
//  Hearing Aid App
//
//  Created by Artem Sherbachuk on 5/7/21.
//

import UIKit
import MessageUI

class BaseViewController: UIViewController, Gradientable {

    let gradient: CAGradientLayer = CAGradientLayer()

    let user = User.shared

    let transition = CircularTransition()

    let blur = UIView()
    var addVignetteShadow: Bool = true

    lazy var innerShadowLayer: CALayer = {
        let innerShadowLayer = CALayer()
        innerShadowLayer.frame = view.bounds
        let path = UIBezierPath(rect: innerShadowLayer.bounds.insetBy(dx: -50, dy: -50))
        let innerPart = UIBezierPath(rect: innerShadowLayer.bounds).reversing()
        path.append(innerPart)
        innerShadowLayer.shadowPath = path.cgPath
        innerShadowLayer.masksToBounds = true
        innerShadowLayer.shadowColor = UIColor.black.cgColor
        innerShadowLayer.shadowOffset = CGSize.zero
        innerShadowLayer.shadowOpacity = 1
        innerShadowLayer.shadowRadius = 10
        return innerShadowLayer
    }()

    var addCornerRadius: Bool = false {
        didSet {
            if addCornerRadius {
                view.layer.masksToBounds = true
                view.layer.cornerRadius = 20
            } else {
                view.layer.masksToBounds = true
                view.layer.cornerRadius = 0
            }
        }
    }

    var addParticle: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()

        if iPhone && hasTopNotch {
            addCornerRadius = true
        } else {
            addCornerRadius = false
        }

        blur.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.5)
        view.insertSubview(blur, at: 0)

        if addParticle {
            let particle = ParticleView(frame: view.bounds, fileNamed: "Volt")
            particle.particleColor = Theme.whiteColor.withAlphaComponent(0.65)
            view.insertSubview(particle, at: 0)
            particle.beginUpdate()
        }

        addGradientOn(view: view, at: 0, colors: Theme.bgGradientColors)

        NotificationCenter.default.addObserver(self, selector: #selector(didUpdateSubscriptionInfo), name: DidUpdateSubscriptionInfo_NotificationName, object: nil)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        didUpdateSubscriptionInfo()
        Configs.fetchConfigs()
        addInnerShadow()

        AppRating.requestReview(from: self)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        blur.frame = view.bounds
        innerShadowLayer.frame = view.bounds
        updateGradientLayerFrame()
    }

    private func addInnerShadow() {
        guard addVignetteShadow else { return }
        view.layer.addSublayer(innerShadowLayer)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    @objc func didUpdateSubscriptionInfo() {}

    static func instantiate<T:BaseViewController>() -> T {
        let storyboard = UIStoryboard(name: String(describing:T.self),
                                      bundle: nil)
        let viewController = storyboard.instantiateInitialViewController() as! T
        return viewController
    }

    func presentAsPopover(vc: UIViewController, sourceView: UIView,
                          size: CGSize = CGSize(width: 300, height: 300),
                          completion: (() -> Void)? = nil) {

        let navigationController = UINavigationController(rootViewController: vc)
        navigationController.preferredContentSize = size
        navigationController.modalPresentationStyle = .popover
        navigationController.popoverPresentationController?.sourceView = sourceView
        navigationController.popoverPresentationController?.delegate = self
        present(navigationController, animated: true, completion: completion)
    }

    func presentSubscription() {
        if user.isPremium { return }
        transition.startingPoint = view.center

        let vc: SubscriptionViewController = SubscriptionViewController.instantiate()
        vc.transitioningDelegate = self
        vc.modalPresentationStyle = .custom
        present(vc, animated: true, completion: nil)
    }

    func restorePurchase() {
        let title = "Restore purchase".localized()
        presentAlert(controller: self, title: title, message: "", leftActionTitle: "Yes!".localized(), rightActionTitle: "No, Thanks".localized(), leftActionStyle: .default, rightActionStyle: .default) { [unowned self] in
            ActivityIndicator.showActivity(topView: self.view)
            RevenueCat.restoreTransactions {
                ActivityIndicator.hideActivity()
                presentAlert(controller: self, title: "Completed".localized(), message: "")
            }
        } rightActionCompletion: {}
    }
}

extension BaseViewController: MFMailComposeViewControllerDelegate {

    func sendEmail() {
        if MFMailComposeViewController.canSendMail() {
            let mail = MFMailComposeViewController()
            mail.mailComposeDelegate = self
            mail.setToRecipients(["abilodevelopment@gmail.com"])
            mail.setSubject("\(appName) App Support")
            present(mail, animated: true, completion: nil)
        }
    }

    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true)
    }
}

extension BaseViewController: UIViewControllerTransitioningDelegate {

    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {

        if let presentedVC = presented as? PresentedViewType {
            return presentedVC.presentTransitionType.animation
        } else {
            transition.transitionMode = .present
            return transition
        }
    }

    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {

        if let dismissedVC = dismissed as? PresentedViewType {
            return dismissedVC.dismissTransitionType.animation
        } else {
            transition.transitionMode = .dismiss
            return transition
        }
    }

    public func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        if presented is PresentedViewType {
            return PresentationController(presentedViewController: presented, presenting: presenting)
        } else {
            return nil
        }
    }
}

extension BaseViewController: UIPopoverPresentationControllerDelegate {

    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }

    func prepareForPopoverPresentation(_ popoverPresentationController: UIPopoverPresentationController) {
        popoverPresentationController.barButtonItem = navigationItem.rightBarButtonItem
        guard let view = popoverPresentationController.containerView else { return }
        view.alpha = 0
        view.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
        UIView.animate(withDuration: 0.4, delay: 0,
                       usingSpringWithDamping: 0.8,
                       initialSpringVelocity: 0.8,
                       options: .curveEaseOut, animations: {
                        view.alpha = 1
                        view.transform = .identity
                       }, completion: { (success:Bool) in
                       })
    }

    func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
    }
}

class BasePopoverViewController: BaseViewController {

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        animateAppearance()
    }

    func animateAppearance() {
        guard let view = self.view as? SpringView else {
            return
        }
        view.animation = "pop"
        view.curve = "easeOut"
        view.duration =  0.8
        view.y = UIScreen.main.bounds.height
        view.animate()
        view.layoutIfNeeded()
    }

    @discardableResult
    static func presentOn<T:BasePopoverViewController>(controller:BaseViewController,
                                                       inView view: UIView,
                                                       withSize size: CGSize? = nil) -> T {

        if let existing = controller.children.filter({ $0 is Self }).first as? T {
            return existing
        }

        let popover: T = T.instantiate()

        let frame: CGRect
        if iPhone {
            let width = size?.width ?? UIScreen.main.bounds.size.width - 100
            let height = size?.height ?? width
            frame = CGRect(x: view.center.x - (width / 2),
                           y: view.center.y - (height / 2),
                           width: width, height: height)
        } else {
            let width = size?.width ?? UIScreen.main.bounds.size.width - (UIScreen.main.bounds.size.width / 2)
            let height = size?.height ?? width
            frame = CGRect(x: view.center.x - (width / 2),
                           y: view.center.y - (height / 2),
                           width: width, height: height)
        }

        controller.addChildController(popover, inView: view, withFrame: frame)

        return popover
    }


    func remove() {
        parent?.removeChildController(self)
    }

}


func presentError(error: Error? = nil,
                  customTitle: String = "Error".localized(), customDescription: String? = nil) {
    let description = (customDescription ?? error?.localizedDescription) ?? ""
    let errorTitle = customTitle
    let alert = UIAlertController(title: errorTitle, message: description, preferredStyle: .alert)
    let action = UIAlertAction(title: "OK", style: .default) { [weak alert] _ in
        alert?.dismiss(animated: true, completion: nil)
    }
    alert.addAction(action)
    let vc = UIApplication.shared.topMostViewController()
    vc?.present(alert, animated: true, completion: nil)
}

typealias ConfirmCompletion = () -> Void
typealias DiscardCompletion = () -> Void

func presentAlert(controller: UIViewController,
                  title: String, message: String,
                  completion: (() -> Void)? = nil) {
    let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
    let action = UIAlertAction(title: "OK", style: .default) { _ in
        completion?()
    }
    alert.addAction(action)
    controller.present(alert, animated: true, completion: nil)
}


func presentAlert(controller: UIViewController,
                  title: String,
                  message: String,
                  interfaceStyle: UIUserInterfaceStyle? = nil,
                  leftActionTitle: String,
                  rightActionTitle: String,
                  leftActionStyle: UIAlertAction.Style = .cancel,
                  rightActionStyle: UIAlertAction.Style = .default,
                  leftActionCompletion: (() -> Void)? = nil,
                  rightActionCompletion: (() -> Void)? = nil) {
    let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)

    if let interfaceStyle = interfaceStyle {
        alert.overrideUserInterfaceStyle = interfaceStyle
    }

    let actionLeft = UIAlertAction(title: leftActionTitle,
                                   style: leftActionStyle) { _ in
        leftActionCompletion?()
    }
    alert.addAction(actionLeft)

    let actionRight = UIAlertAction(title: rightActionTitle,
                                    style: rightActionStyle) { _ in
        rightActionCompletion?()
    }
    alert.addAction(actionRight)

    controller.present(alert, animated: true, completion: nil)
}



var iPhone: Bool {
    return UIDevice.current.userInterfaceIdiom == .phone
}

var hasTopNotch: Bool {
    let topArea = UIApplication.shared.delegate?.window??.safeAreaInsets.top ?? 0
    return topArea > 1
}

var launchesCount: Int {
    set(newValue) {
        UserDefaults.standard.setValue(newValue, forKey: "SessionsCount")
    }
    get {
        return UserDefaults.standard.integer(forKey: "SessionsCount")
    }
}

var isFirstLaunch: Bool {
    return launchesCount == 1
}

var appName: String { "TOP" }
