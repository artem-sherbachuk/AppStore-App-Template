//
//  Gradientable.swift
//
//  Created by Artem Sherbachuk on 1/9/21.
//
import UIKit

protocol Gradientable {
    var gradient: CAGradientLayer { get }
}

extension Gradientable {

    func updateGradientLayerFrame() {
        if let superLayerFrame =  gradient.superlayer?.bounds {
            gradient.frame = superLayerFrame
        }
    }

    func addGradientOn(view: UIView, at index: UInt32, colors: [UIColor]? = nil) {
        gradient.startPoint = .zero
        gradient.endPoint = CGPoint(x: 1, y: 1)
        gradient.colors = colors?.compactMap({ $0.cgColor })
        view.layer.insertSublayer(gradient, at: index)
    }

    func updateGradientColors(colors: [UIColor]) {
        gradient.colors = colors.compactMap({$0.cgColor})
    }

    func showSceletonAnimation() {
        let animationStartPoint = CABasicAnimation(keyPath: "startPoint")
        animationStartPoint.fromValue = CGPoint.zero
        animationStartPoint.toValue = CGPoint(x: 1, y: 1)
        animationStartPoint.autoreverses = true
        animationStartPoint.duration = 0.6
        animationStartPoint.repeatCount = .infinity

        hideSceletonAnimation()
        gradient.add(animationStartPoint, forKey: "sceletonAnimation")
    }

    func hideSceletonAnimation() {
        gradient.removeAnimation(forKey: "sceletonAnimation")
    }
}
