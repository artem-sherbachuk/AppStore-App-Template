//
//  Theme.swift
//  Hearing Aid App
//
//  Created by Artem Sherbachuk on 5/12/21.
//

import UIKit

struct Theme {
    private init() {}

    enum Color: Int {
        case purpule,orange,red,blue,green

        var color: UIColor {
            switch self {
            case .purpule:
                return #colorLiteral(red: 0.4862745098, green: 0.2509803922, blue: 0.8, alpha: 1)
            case .orange:
                return #colorLiteral(red: 1, green: 0.5137254902, blue: 0, alpha: 1)
            case .red:
                return #colorLiteral(red: 1, green: 0, blue: 0, alpha: 1)
            case .blue:
                return #colorLiteral(red: 0, green: 0.4731103778, blue: 1, alpha: 1)
            case .green:
                return #colorLiteral(red: 0.2078431373, green: 0.7803921569, blue: 0.3490196078, alpha: 1)
            }
        }

        var gradientColors: [UIColor] {
            switch self {
            case .purpule:
                return [#colorLiteral(red: 1, green: 0, blue: 0.9607843137, alpha: 1), #colorLiteral(red: 0.4862745098, green: 0.2509803922, blue: 0.8, alpha: 1)]
            case .orange:
                return [#colorLiteral(red: 1, green: 0.7803921569, blue: 0, alpha: 1), #colorLiteral(red: 0.9294117647, green: 0.1019607843, blue: 0.1019607843, alpha: 1)]
            case .red:
                return [#colorLiteral(red: 1, green: 0.5137254902, blue: 0, alpha: 1), #colorLiteral(red: 0.9294117647, green: 0.1019607843, blue: 0.1019607843, alpha: 1)]
            case .blue:
                return [#colorLiteral(red: 0, green: 1, blue: 0.8784313725, alpha: 1), #colorLiteral(red: 0, green: 0.4, blue: 1, alpha: 1)]
            case .green:
                return [#colorLiteral(red: 0.8588235294, green: 1, blue: 0, alpha: 1), #colorLiteral(red: 0.2078431373, green: 0.7803921569, blue: 0.3490196078, alpha: 1)]
            }
        }

        var gradientInactiveColors: [UIColor] {
            return [buttonInactiveColor, buttonInactiveColor]
        }
    }

    static var current: Color = .green

    static func setupAppearance() {
        buttonActiveColor = current.color

        UITabBar.appearance().tintColor = Theme.buttonActiveColor
        UITabBar.appearance().unselectedItemTintColor = Theme.buttonInactiveColor
        UIButton.appearance().tintColor = Theme.buttonActiveColor
    }

    static private(set) var buttonActiveColor = current.color

    static let buttonInactiveColor: UIColor = UIColor(named: "textColor") ?? UIColor.systemGray

    static let whiteColor: UIColor = #colorLiteral(red: 0.9999960065, green: 1, blue: 1, alpha: 1)
    static let greenColor: UIColor = #colorLiteral(red: 0.2078431373, green: 0.7803921569, blue: 0.3490196078, alpha: 1)
    static let bgGradientColors = [#colorLiteral(red: 0.08318006247, green: 0.05184601992, blue: 0.1465682387, alpha: 1),#colorLiteral(red: 0.5568627715, green: 0.3529411852, blue: 0.9686274529, alpha: 1),#colorLiteral(red: 0.9098039269, green: 0.4784313738, blue: 0.6431372762, alpha: 1),#colorLiteral(red: 0.1084984317, green: 0.05867388099, blue: 0.07809757441, alpha: 1)]
    
    static func setControlsColor(_ color: Color) {
        current = color
        buttonActiveColor = color.color
        setupAppearance()
    }
}
