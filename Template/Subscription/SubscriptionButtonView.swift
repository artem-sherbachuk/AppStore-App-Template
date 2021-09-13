//
//  SubscriptionButtonView.swift
//  Charging play
//
//  Created by Artem Sherbachuk on 9/13/21.
//

import UIKit

final class SubscriptionButtonView: SpringView {

    @IBOutlet weak var button: UIButton!

    override func awakeFromNib() {
        super.awakeFromNib()
        layer.cornerRadius = bounds.height / 2
        layer.masksToBounds = true
        layer.borderWidth = 2
        layer.borderColor = #colorLiteral(red: 0.9999960065, green: 1, blue: 1, alpha: 0.5)
        transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
        setUnlockTile()

        tintColor = Theme.whiteColor
        button.setTitleColor(Theme.whiteColor, for: .normal)
        button.tintColor = Theme.whiteColor
        backgroundColor = Theme.greenColor
    }

    func showIdleAnimation() {
        addShakingAnimation(speed: 1.01)
    }

    func animateAppearance() {
        let name = iPhone ? "squeezeRight" : "pop"
        animate(name: name, curve: "liniar", delay: 0.7, duration: 0.7)
        showIdleAnimation()
    }

    func setTitle(_ title: String) {
        button.setTitle(title, for: .normal)
    }

    func setTrialTile(days: String) {
        let text = String(format: "Activate %@ Trial Now!".localized(), days.uppercased())
        button.setTitle(text, for: .normal)
    }

    func setUnlockTile() {
        button.setTitle("Activate Now!".localized(), for: .normal)
    }
}
