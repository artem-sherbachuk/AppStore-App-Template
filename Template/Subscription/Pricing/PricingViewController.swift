//
//  PricingViewController.swift
//  Charging play
//
//  Created by Artem Sherbachuk on 9/8/21.
//

import UIKit

protocol PricingViewControllerDelegate: AnyObject {
    func didFinish()
}

final class PricingViewController: BaseViewController {

    @IBOutlet weak var blurView: UIVisualEffectView!

    @IBOutlet weak var videView: VideoView!

    @IBOutlet weak var titleLabel: SpringLabel!

    @IBOutlet weak var pricingView: PricingStackView!

    @IBOutlet weak var actionButtonView: SubscriptionButtonView!

    var shopItems: [ShopItem]? {
        didSet {
            if isViewLoaded {
                pricingView.shopItems = shopItems
            }
        }
    }

    weak var delegate: PricingViewControllerDelegate?

    override func viewDidLoad() {
        addParticle = true
        super.viewDidLoad()

        if let particle = view.subviews.compactMap({ $0 as? ParticleView }).first {
            particle.removeFromSuperview()
            particle.frame = view.bounds
            view.insertSubview(particle, aboveSubview: blurView)
            particle.beginUpdate()
        }

        titleLabel.isHidden = true
        
        pricingView.delegate = self
        pricingView.shopItems = shopItems
        pricingView.discountView.startTimer()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if let url = Bundle.main.url(forResource: "pricing_bg", withExtension: "mp4") {
            videView.setupPlayerItem(url: url, isMuted: true)
            videView.play()
        } else {
            videView.isHidden = true
        }

        pricingView.animate()
        actionButtonView.animateAppearance()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        pricingView.discountView.stopTimer()
    }


    
    //MARK: - Target Actions
    @IBAction func subscribeButton(sender: UIButton?) {

        guard let item = pricingView.selectedOption?.shopItem else {
            return
        }

        ActivityIndicator.showActivity(topView: view, color: .white)
        actionButtonView.removeShakingAnimation()
        RevenueCat.purchaseSubscription(package: item) { [weak self] state in
            ActivityIndicator.hideActivity()

            if state == .subscribed {
                self?.dismiss(animated: false) { [weak self] in
                    self?.delegate?.didFinish()
                }
            } else {
                self?.actionButtonView.showIdleAnimation()
            }
        }
    }

    @IBAction func restorePurchaseAction(sender: UIButton) {
        restorePurchase()
    }

    @IBAction func termOfUseAction(sender: UIButton) {
        guard let url = URL(string: "https://artem-sherbachuk.github.io/Charging-Play-Landing/terms/") else { return }
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }

    @IBAction func privacyPolicityAction(sender: UIButton) {
        guard let url = URL(string: "https://artem-sherbachuk.github.io/Charging-Play-Landing/privacypolicy/") else { return }
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
}


extension PricingViewController: SubscriptionOptionViewDelegate {

    func didSelect(shopItem: ShopItem,
                   fromView view: SubscriptionOptionView) {

        let id = shopItem.product.productIdentifier


        if let _trial = shopItem.product.introductoryPrice,
           _trial.price == 0,
           let period = _trial.subscriptionPeriod.localizedPeriod() {
            actionButtonView.setTrialTile(days: period)
            pricingView.discountView.setTrialHintText()
        } else {
            actionButtonView.setUnlockTile()

            if id == RevenueCat.lifetimeId {
                pricingView.discountView.setLifetimeText()
            } else if shopItem.product.subscriptionPeriod != nil {
                pricingView.discountView.setSubscriptionText()
            } else {
                pricingView.discountView.removeHintText()
            }

        }
    }

}
