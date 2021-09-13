

import UIKit

public class TransitionZoom: NSObject, UIViewControllerTransitioningDelegate, UIViewControllerAnimatedTransitioning {
    
    var isPresenting = true
    var duration = 0.4
    
    public func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let container = transitionContext.containerView
        let fromView = transitionContext.view(forKey: UITransitionContextViewKey.from)!
        let toView = transitionContext.view(forKey: UITransitionContextViewKey.to)!
        
        if isPresenting {
            container.addSubview(fromView)
            container.addSubview(toView)
            
            toView.alpha = 0
            toView.transform = CGAffineTransform(scaleX: 2, y: 2)

            SpringAnimation.springEaseInOut(duration: duration) {
                fromView.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
                fromView.alpha = 0
                toView.transform = CGAffineTransform.identity
                toView.alpha = 1
            }
        }
        else {
            container.addSubview(toView)
            container.addSubview(fromView)
            
            SpringAnimation.springEaseInOut(duration: duration) {
                fromView.transform = CGAffineTransform(scaleX: 2, y: 2)
                fromView.alpha = 0
                toView.transform = CGAffineTransform(scaleX: 1, y: 1)
                toView.alpha = 1
            }
        }
        
        delay(delay: duration, closure: {
            transitionContext.completeTransition(true)
        })
    }
    
    public func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return duration
    }
    
    public func animationController(forPresentedController presented: UIViewController, presenting: UIViewController, sourceController source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        isPresenting = true
        return self
    }
    
    public func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        isPresenting = false
        return self
    }
}
