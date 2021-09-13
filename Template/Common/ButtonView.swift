//
//  ButtonView.swift
//  Notes
//
//  Created by Artem Sherbachuk on 6/18/21.
//

import UIKit

class ButtonView: SpringView {
    @IBOutlet weak var button: SpringButton?
    @IBOutlet weak var imageView: SpringImageView?
    @IBOutlet weak var title: SpringLabel?

    var isSelected: Bool = false {
        didSet {
            setupUIColor()
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        setupUIColor()
        alpha = 0
        animate(name:"pop")
        isSelected = true
    }

    @objc private func setupUIColor() {
        button?.isSelected = isSelected
        title?.textColor = isSelected ? Theme.buttonActiveColor : Theme.buttonInactiveColor
        imageView?.tintColor = isSelected ? Theme.buttonActiveColor : Theme.buttonInactiveColor
    }
}

