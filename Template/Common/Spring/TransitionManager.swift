
import UIKit

public class TransitionManager: NSObject, UIViewControllerTransitioningDelegate, UIViewControllerAnimatedTransitioning {
    
    var isPresenting = true
    var duration = 0.3
    
    public func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let container = transitionContext.containerView
        let fromView = transitionContext.view(forKey: UITransitionContextViewKey.from)!
        let toView = transitionContext.view(forKey: UITransitionContextViewKey.to)!
        
        if isPresenting {
            toView.frame = container.bounds
            toView.transform = CGAffineTransform(translationX: 0, y: container.frame.size.height)
            container.addSubview(fromView)
            container.addSubview(toView)
            SpringAnimation.springEaseInOut(duration: duration) {
                fromView.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
                fromView.alpha = 0.5
                toView.transform = CGAffineTransform.identity
            }
        }
        else {

            // 1. Rotating will change the bounds
            // 2. we have to properly reset toView
            // to the actual container's bounds, at
            // the same time take consideration of
            // previous transformation when presenting
            let transform = toView.transform
            toView.transform = CGAffineTransform.identity
            toView.frame = container.bounds
            toView.transform = transform

            container.addSubview(toView)
            container.addSubview(fromView)

            SpringAnimation.springEaseInOut(duration: duration) {
                fromView.transform = CGAffineTransform(translationX: 0, y: fromView.frame.size.height)
                toView.transform = CGAffineTransform.identity
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
