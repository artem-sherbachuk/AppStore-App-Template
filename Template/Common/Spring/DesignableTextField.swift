

import UIKit

@IBDesignable public class DesignableTextField: SpringTextField {
    
    @IBInspectable public var placeholderColor: UIColor = UIColor.clear {
        didSet {
            guard let placeholder = placeholder else { return }
            attributedPlaceholder = NSAttributedString(string: placeholder, attributes: [NSAttributedString.Key.foregroundColor: placeholderColor])
            layoutSubviews()
            
        }
    }
    
    @IBInspectable public var sidePadding: CGFloat = 0 {
        didSet {
            let padding = UIView(frame: CGRect(x: 0, y: 0, width: sidePadding, height: sidePadding))
            
            leftViewMode = UITextField.ViewMode.always
            leftView = padding
            
            rightViewMode = UITextField.ViewMode.always
            rightView = padding
        }
    }
    
    @IBInspectable public var leftPadding: CGFloat = 0 {
        didSet {
            let padding = UIView(frame: CGRect(x: 0, y: 0, width: leftPadding, height: 0))
            
            leftViewMode = UITextField.ViewMode.always
            leftView = padding
        }
    }
    
    @IBInspectable public var rightPadding: CGFloat = 0 {
        didSet {
            let padding = UIView(frame: CGRect(x: 0, y: 0, width: rightPadding, height: 0))
            
            rightViewMode = UITextField.ViewMode.always
            rightView = padding
        }
    }
    
    @IBInspectable public var borderColor: UIColor = UIColor.clear {
        didSet {
            layer.borderColor = borderColor.cgColor
        }
    }
    
    @IBInspectable public var borderWidth: CGFloat = 0 {
        didSet {
            layer.borderWidth = borderWidth
        }
    }
    
    @IBInspectable public var cornerRadius: CGFloat = 0 {
        didSet {
            layer.cornerRadius = cornerRadius
        }
    }
   
    @IBInspectable public var lineHeight: CGFloat = 1.5 {
        didSet {
            let font = UIFont(name: self.font!.fontName, size: self.font!.pointSize)
            guard let text = self.text else { return }
            
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.lineSpacing = lineHeight
            
            let attributedString = NSMutableAttributedString(string: text)
            attributedString.addAttribute(NSAttributedString.Key.paragraphStyle, value: paragraphStyle, range: NSRange(location: 0, length: attributedString.length))
            attributedString.addAttribute(NSAttributedString.Key.font, value: font!, range: NSRange(location: 0, length: attributedString.length))
            
            self.attributedText = attributedString
        }
    }
    
}
