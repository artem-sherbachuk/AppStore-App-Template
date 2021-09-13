//
//  ColorSelectionViewController.swift
//  Charging play
//
//  Created by Artem Sherbachuk on 8/9/21.
//

import UIKit


protocol ColorSelectionDelegate: AnyObject {
    func didSelectColor(color: UIColor)
}

extension ColorSelectionDelegate {
    func didToggleRandomColor(_ isOn: Bool) {}
}

final class ColorSelectionViewController: BaseViewController {

    private let picker = UIColorPickerViewController()

    weak var delegate: ColorSelectionDelegate?

    var selectedColor: UIColor? {
        didSet {
            if isViewLoaded, let color = selectedColor {
                picker.selectedColor = color
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        addVignetteShadow = false

        title = "Color Setting".localized()
        view.backgroundColor = .clear

        addChildController(picker, inView: view)

        let color = selectedColor ?? Theme.whiteColor
        picker.selectedColor = color
        picker.delegate = self

        let size = iPhone ? CGSize(width: 350, height: 500) : CGSize(width: 350, height: 600)
        navigationController?.preferredContentSize = size
    }
}

extension ColorSelectionViewController: UIColorPickerViewControllerDelegate {
    func colorPickerViewControllerDidSelectColor(_ viewController: UIColorPickerViewController) {
        let color = viewController.selectedColor
        delegate?.didSelectColor(color: color)
    }
}
