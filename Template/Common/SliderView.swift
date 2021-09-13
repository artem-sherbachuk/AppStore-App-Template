//
//  SliderView.swift
//  Magnifier
//
//  Created by Artem Sherbachuk on 7/1/21.
//

import UIKit

class SliderView: SpringSlider {

    override func awakeFromNib() {
        super.awakeFromNib()
        setupUIColor()
    }

    @objc private func setupUIColor() {
        minimumTrackTintColor = isEnabled ? Theme.buttonActiveColor : Theme.buttonInactiveColor
    }
}

