//
//  SubscriptionPricingTableView.swift
//  Charging play
//
//  Created by Artem Sherbachuk on 8/26/21.
//

import UIKit

final class PricingStackView: UIStackView, UIGestureRecognizerDelegate {

    @IBOutlet weak var discountView: DiscountStackView!

    @IBOutlet weak var centerPricingView: SubscriptionOptionView!

    @IBOutlet weak var moreOptionsButton: UIButton!

    @IBOutlet weak var additionalPricingStackView: SubscriptionsOptionsStackView!

    weak var delegate: SubscriptionOptionViewDelegate? {
        didSet {
            centerPricingView.delegate = delegate
            additionalPricingStackView.delegate = delegate
        }
    }

    var shopItems: [ShopItem]? {
        didSet {

            additionalPricingStackView.option1.shopItem = shopItems?[safe: 0]
            additionalPricingStackView.option2.shopItem = shopItems?[safe: 1]
            additionalPricingStackView.option3.shopItem = shopItems?[safe: 2]

            centerPricingView.shopItem = shopItems?.last
            centerPricingView.isSelected = true
            additionalPricingStackView.isHidden = true
        }
    }

    var allOptions: [SubscriptionOptionView] {
        return [centerPricingView] + additionalPricingStackView.allOptions
    }

    var selectedOption: SubscriptionOptionView? {
        return allOptions.filter({ $0.isSelected }).first
    }


    func animate() {
        animatePricing()
        discountView.animate()
    }


    func animatePricing() {
        let name = iPhone ? "squeezeRight" : "pop"
        centerPricingView.animate(name: name, curve: "liniar", duration: 0.7)
        additionalPricingStackView.animatePricing()
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        centerPricingView.isSelected = true
        additionalPricingStackView.isHidden = true

        centerPricingView.borderColor = #colorLiteral(red: 0, green: 0.9768045545, blue: 0, alpha: 1)

        additionalPricingStackView.option1.borderColor = #colorLiteral(red: 0.4508578777, green: 0.9882974029, blue: 0.8376303315, alpha: 1)
        additionalPricingStackView.option2.borderColor = #colorLiteral(red: 0, green: 0.9768045545, blue: 0, alpha: 1)
        additionalPricingStackView.option3.borderColor = #colorLiteral(red: 0, green: 0.9810667634, blue: 0.5736914277, alpha: 1)


        let tap = UITapGestureRecognizer(target: self,
                                         action: #selector(selectionAction(sender:)))
        tap.delegate = self
        addGestureRecognizer(tap)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        centerPricingView.cornerRadius = 10
    }

    @IBAction func moreOptionsAction(sender: UIButton) {
        sender.isHidden = true
        additionalPricingStackView.isHidden = false
    }

    @objc private func selectionAction(sender: UITapGestureRecognizer) {
        let point = sender.location(in: self)
        allOptions.forEach({ option in
            option.isSelected = false
            selectIf(point: point, inside: option)
        })
        validateSelection()
    }

    private func selectIf(point: CGPoint,
                          inside option: SubscriptionOptionView) {
        if option.point(inside: convert(point, to: option), with: nil) {
            option.isSelected = true
        }
    }

    func validateSelection() {
        //in case of touch made in the spacing between options. not real case but...
        if selectedOption == nil {
            centerPricingView.isSelected = true
        }
    }

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}

final class SubscriptionsOptionsStackView: UIStackView {

    @IBOutlet weak var option1: SubscriptionOptionView!

    @IBOutlet weak var option2: SubscriptionOptionView!

    @IBOutlet weak var option3: SubscriptionOptionView!

    weak var delegate: SubscriptionOptionViewDelegate? {
        didSet {
            option1.delegate = delegate
            option2.delegate = delegate
            option3.delegate = delegate
        }
    }

    var allOptions: [SubscriptionOptionView] {
        return [option1, option2, option3]
    }

    var selectedOption: SubscriptionOptionView? {
        return allOptions.filter({ $0.isSelected }).first
    }

    func animatePricing() {
        animateOption1()
        animateOption2()
        animateOption3()
    }

    private func animateOption1() {
        let name = iPhone ? "squeezeRight" : "pop"
        option1.animate(name: name, curve: "liniar", duration: 0.7)
    }

    private func animateOption2() {
        let name = iPhone ? "squeezeLeft" : "pop"
        option2.animate(name: name, curve: "liniar", delay: 0.4,
                        duration: 0.7)
    }

    private func animateOption3() {
        let name = iPhone ? "squeezeRight" : "pop"
        option3.animate(name: name, curve: "liniar", delay: 0.6,
                        duration: 0.7)
    }
}

protocol SubscriptionOptionViewDelegate: AnyObject {
    func didSelect(shopItem: ShopItem, fromView view: SubscriptionOptionView)
}

final class SubscriptionOptionView: SpringStackView {

    var shopItem: ShopItem? {
        didSet {
            setupShopItem()
        }
    }

    @IBOutlet weak var titleLabel: SpringLabel!

    @IBOutlet weak var checkmarkImageView: SpringImageView!

    @IBOutlet weak var oldPriceLabel: SpringLabel!

    @IBOutlet weak var costLabel: SpringLabel!

    @IBOutlet weak var discountLabel: SpringLabel!

    private var blurView: UIVisualEffectView?

    var borderColor = #colorLiteral(red: 0.9999960065, green: 1, blue: 1, alpha: 0.5)

    weak var delegate: SubscriptionOptionViewDelegate?

    var cornerRadius: CGFloat = 0 {
        didSet {
            blurView?.layer.cornerRadius = cornerRadius
        }
    }

    var isSelected: Bool = false {
        didSet {
            if isSelected {
                checkmarkImageView.isHidden = false
                animateSelection()

                if let shopItem = shopItem {
                    delegate?.didSelect(shopItem: shopItem, fromView: self)
                }

            } else {
                checkmarkImageView.isHidden = true
                transform = CGAffineTransform(scaleX: 0.87, y: 0.87)
            }
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        checkmarkImageView.isHidden = true
        blurView = UIVisualEffectView(effect: UIBlurEffect(style: .systemUltraThinMaterialDark))
        blurView?.layer.masksToBounds = true
        blurView?.layer.cornerRadius = bounds.width / 8
        blurView?.layer.borderWidth = 2
        blurView?.layer.borderColor = borderColor.cgColor
        insertSubview(blurView!, at: 0)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        let bgFrame = CGRect(x: -4, y: -4,
                             width: bounds.width + 8, height: bounds.height + 8)
        blurView?.frame = bgFrame
    }

    func animateSelection() {
        scale(from: 0.87, to: 1)
        checkmarkImageView.animate(name: "pop")
        titleLabel.animate(name: "pop", delay: 0.3)
        oldPriceLabel.animate(name: "pop", delay: 0.5)
        costLabel.animate(name: "pop", delay: 0.6)
        discountLabel.animate(name: "pop", delay: 0.7)
    }

    private func numberFormatterFor(shopItem: ShopItem) -> NumberFormatter {
        let currencyFormatter = NumberFormatter()
        currencyFormatter.usesGroupingSeparator = true
        currencyFormatter.numberStyle = .currency
        currencyFormatter.locale = shopItem.product.priceLocale
        return currencyFormatter
    }

    private func setupShopItem() {
        guard let shopItem = shopItem else {
            isHidden = true
            return
        }

        blurView?.layer.borderColor = borderColor.cgColor
        titleLabel.textColor = borderColor
        isHidden = false

        let period = shopItem.product.subscriptionPeriod
        let periodTitle = period?.localizedPeriod() ?? "Lifetime".localized()
        costLabel.text = shopItem.localizedPriceString
        titleLabel.text = periodTitle.uppercased()

        let oldPrice = numberFormatterFor(shopItem: shopItem).string(from: NSNumber(value:shopItem.product.price.doubleValue * 2)) ?? ""
        let oldPriceString: NSMutableAttributedString =  NSMutableAttributedString(string: oldPrice)
        oldPriceString.addAttribute(.strikethroughStyle, value: 2, range: NSMakeRange(0, oldPriceString.length))
        oldPriceLabel.attributedText = oldPriceString


        if let _trial = shopItem.product.introductoryPrice,
           _trial.price == 0,
           let trialDuration = _trial.subscriptionPeriod.localizedPeriod() {

            discountLabel.isHidden = false
            discountLabel.text = trialDuration + " " + "Trial".localized()

        } else {

            if shopItem.product.productIdentifier == RevenueCat.weeklyId {
                discountLabel.isHidden = false
                discountLabel.text = "Weekly Premium".localized()
            } else if shopItem.product.productIdentifier == RevenueCat.monthlyId {
                discountLabel.isHidden = false
                discountLabel.text = "Monthly Premium".localized()
            } else if shopItem.product.productIdentifier == RevenueCat.annualId {
                discountLabel.isHidden = false
                discountLabel.text = "Annual Premium".localized()
            } else if shopItem.product.productIdentifier == RevenueCat.lifetimeId {
                discountLabel.text = "Forever Premium".localized()
            }

        }
    }
}


final class DiscountStackView: UIStackView {

    @IBOutlet weak var hintLabel: UILabel!

    @IBOutlet weak var discountLabel: UILabel!

    private var discountTimer: Timer?


    func stopTimer() {
        discountTimer?.invalidate()
        discountTimer = nil
    }

    func animate() {
        hintLabel.fadeIn(from: 0, to: 1, delay: 1, duration: 2)
    }

    func startTimer() {

        if discountEndDuration <= 0 {
            discountLabel.text = "Save 50% Now!".localized()
            discountTimer?.invalidate()
            discountTimer = nil
            return
        }

        discountLabel.isHidden = false

        discountTimer?.invalidate()
        discountTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { [weak self] _ in
            discountEndDuration -= 1
            if discountEndDuration <= 0 {
                self?.discountTimer?.invalidate()
                self?.discountTimer = nil
            }

            let time = HoursTimeFormatter.string(from: discountEndDuration) ?? "00:00"
            let discountText = "-50% Ends in: \(time)"
            self?.discountLabel.text = discountText
        })
    }

    func setTrialHintText() {
        let t1 = "No payment required".localized()
        let t2 = "Free to Try!".localized()
        let t3 = "CANCEL ANY TIME!".localized()
        hintLabel.text = t1 + "\n" + t2 + "\n" + t3
    }

    func setLifetimeText() {
        hintLabel.text = "FOREVER PREMIUM!".localized()
    }

    func setSubscriptionText() {
        hintLabel.text = "CANCEL ANY TIME!".localized()
    }

    func removeHintText() {
        hintLabel.text = ""
    }
}
