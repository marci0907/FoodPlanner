import UIKit

class ZoomNavigation: NSObject, UIViewControllerAnimatedTransitioning {
    
    var isPop: Bool = false
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.3
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        
        if isPop {
            animatePop(using: transitionContext)
            return
        }
        
        let fromView = transitionContext.view(forKey: UITransitionContextViewKey.from)!
        let toViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to)!
        
        let toFrame = transitionContext.finalFrame(for: toViewController)
        
        // TODO: add frame changes here
        let fOff = toFrame.offsetBy(dx: toFrame.width, dy: toFrame.height)
        toViewController.view.frame = fOff

        transitionContext.containerView.insertSubview(toViewController.view, aboveSubview: fromView)
        
        UIView.animate(
            withDuration: transitionDuration(using: transitionContext),
            animations: {
                // TODO: add animations here
                toViewController.view.frame = toFrame
            },
            completion: { _ in
                transitionContext.completeTransition(true)
            }
        )
    }
    
    func animatePop(using transitionContext: UIViewControllerContextTransitioning) {
        let fromViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from)!
        let toViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to)!
        
        // TODO: add frame changes here

        
        transitionContext.containerView.insertSubview(toViewController.view, belowSubview: fromViewController.view)
        
        UIView.animate(
            withDuration: transitionDuration(using: transitionContext),
            animations: {
                // TODO: add animations here

            },
            completion: { _ in
                transitionContext.completeTransition(true)
            }
        )
    }
    
}
