//
//  SubscriptionViewController.swift
//  Drum Pad Beat Maker - Music Production
//
//  Created by Artem Sherbachuk on 1/21/21.
//
import UIKit

var discountEndDuration: TimeInterval = 0//3600

var HoursTimeFormatter: DateComponentsFormatter = {
    let formatter =  DateComponentsFormatter()
    formatter.unitsStyle = .positional
    formatter.allowedUnits = [ .day, .hour, .minute, .second ]
    formatter.zeroFormattingBehavior = [ .pad ]
    return formatter
}()

final class SubscriptionViewController: BaseViewController {

    @IBOutlet weak var titleLabel: SpringLabel!

    @IBOutlet weak var benefitsView: SubscriptionBenefitsStackView!

    @IBOutlet weak var continueAction: SubscriptionButtonView!

    @IBOutlet weak var closeButton: UIButton!

    private let pricingViewController: PricingViewController = PricingViewController.instantiate()

    override func viewDidLoad() {
        addParticle = true
        super.viewDidLoad()
        setup()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        benefitsView.animateAppearance()
        continueAction.animateAppearance()
    }

    func setup() {
        pricingViewController.delegate = self

        titleLabel.alpha = 0
        titleLabel.animate(name:"fadeIn", delay: 0)
        titleLabel.text = "Premium Charging Animations".localized()
        continueAction.setTitle("Continue".localized())
        closeButton.isHidden = true
        //discountEndDuration = user.trialEndDate.timeIntervalSinceNow
        closeButton.tintColor = Theme.whiteColor
        fetchSubscriptions()
//        DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) { [weak self] in
//            self?.closeButton.isHidden = false
//        }
    }

    func fetchSubscriptions() {
        ActivityIndicator.showActivity(topView: view, color: .white)

        RevenueCat.fetchSubscriptionOptions { [weak self] subscriptions in
            ActivityIndicator.hideActivity()
            self?.pricingViewController.shopItems = subscriptions
        }
    }

    @IBAction func closeAction(sender: UIButton?) {
        dismiss(animated: true, completion: nil)
    }

    @IBAction func continueAction(sender: UIButton) {
        transition.startingPoint = sender.superview?.center ?? view.center
        pricingViewController.modalPresentationStyle = .custom
        pricingViewController.transitioningDelegate = self
        present(pricingViewController, animated: true, completion: nil)
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }

    override var shouldAutorotate: Bool {
        false
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
}

extension SubscriptionViewController: PricingViewControllerDelegate {
    func didFinish() {
        closeAction(sender: nil)
    }
}


final class SubscriptionBenefit: SpringStackView {
    @IBOutlet weak var titleLabel: UILabel!
}

final class SubscriptionBenefitsStackView: UIStackView {

    @IBOutlet weak var benefit1: SubscriptionBenefit!

    @IBOutlet weak var benefit2: SubscriptionBenefit!

    @IBOutlet weak var benefit3: SubscriptionBenefit!

    @IBOutlet weak var benefit4: SubscriptionBenefit!

    @IBOutlet weak var benefit5: SubscriptionBenefit!

    override func awakeFromNib() {
        super.awakeFromNib()
        benefit1.titleLabel.text = "Unlock All Charging Animations".localized()
        benefit2.titleLabel.text = "Customize Your Own Animations".localized()
        benefit3.titleLabel.text = "New Contents Updated Regularly".localized()
        benefit4.titleLabel.text = "Fast And Friendly Support".localized()
    }

    func animateAppearance() {
        [benefit1, benefit2, benefit3, benefit4].forEach({ $0?.alpha = 0 })
        benefit1.animate(name:"fadeIn", delay: 0.2)
        benefit2.animate(name:"fadeIn", delay: 0.35)
        benefit3.animate(name:"fadeIn", delay: 0.5)
        benefit4.animate(name:"fadeIn", delay: 0.65)
    }
}
