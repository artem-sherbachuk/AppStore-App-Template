

import UIKit

@IBDesignable class DesignableTabBarController: UITabBarController {
    
    @IBInspectable var normalTint: UIColor = UIColor.clear {
        didSet {
            UITabBar.appearance().tintColor = normalTint
            UITabBarItem.appearance().setTitleTextAttributes([NSAttributedString.Key.foregroundColor: normalTint], for: UIControl.State())
        }
    }
    
    @IBInspectable var selectedTint: UIColor = UIColor.clear {
        didSet {
            UITabBar.appearance().tintColor = selectedTint
            UITabBarItem.appearance().setTitleTextAttributes([NSAttributedString.Key.foregroundColor: selectedTint], for:UIControl.State.selected)
        }
    }
    
    @IBInspectable var fontName: String = "" {
        didSet {
            UITabBarItem.appearance().setTitleTextAttributes([NSAttributedString.Key.foregroundColor: normalTint, NSAttributedString.Key.font: UIFont(name: fontName, size: 11)!], for: UIControl.State())
        }
    }
    
    @IBInspectable var firstSelectedImage: UIImage? {
        didSet {
            if let image = firstSelectedImage {
                let tabBarItems = self.tabBar.items as [UITabBarItem]?
                tabBarItems?[0].selectedImage = image.withRenderingMode(UIImage.RenderingMode.alwaysTemplate)
            }
        }
    }
    
    @IBInspectable var secondSelectedImage: UIImage? {
        didSet {
            if let image = secondSelectedImage {
                let tabBarItems = self.tabBar.items as [UITabBarItem]?
                tabBarItems?[1].selectedImage = image.withRenderingMode(UIImage.RenderingMode.alwaysTemplate)
            }
        }
    }
    
    @IBInspectable var thirdSelectedImage: UIImage? {
        didSet {
            if let image = thirdSelectedImage {
                let tabBarItems = self.tabBar.items as [UITabBarItem]?
                tabBarItems?[2].selectedImage = image.withRenderingMode(UIImage.RenderingMode.alwaysTemplate)
            }
        }
    }
    
    @IBInspectable var fourthSelectedImage: UIImage? {
        didSet {
            if let image = fourthSelectedImage {
                let tabBarItems = self.tabBar.items as [UITabBarItem]?
                tabBarItems?[3].selectedImage = image.withRenderingMode(UIImage.RenderingMode.alwaysTemplate)
            }
        }
    }
    
    @IBInspectable var fifthSelectedImage: UIImage? {
        didSet {
            if let image = fifthSelectedImage {
                let tabBarItems = self.tabBar.items as [UITabBarItem]?
                tabBarItems?[4].selectedImage = image.withRenderingMode(UIImage.RenderingMode.alwaysTemplate)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let items = self.tabBar.items {
            for item in items {
                if let image = item.image {
                    item.image = image.imageWithColor(tintColor: self.normalTint).withRenderingMode(UIImage.RenderingMode.alwaysOriginal)
                }
            }
        }
    }
}

extension UIImage {
    func imageWithColor(tintColor: UIColor) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(self.size, false, self.scale)
        
        let context = UIGraphicsGetCurrentContext()
        context!.translateBy(x: 0, y: self.size.height)
        context!.scaleBy(x: 1.0, y: -1.0);
        context!.setBlendMode(CGBlendMode.normal)
        
        let rect = CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height)
        context?.clip(to: rect, mask: self.cgImage!)
        tintColor.setFill()
        context!.fill(rect)
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext()! as UIImage
        UIGraphicsEndImageContext()
        
        return newImage
    }
}
