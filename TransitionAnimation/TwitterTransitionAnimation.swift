//
//  TwitterTransitionAnimation.swift
//  TransitionTreasury
//
//  Created by DianQK on 12/20/15.
//  Copyright © 2016 TransitionTreasury. All rights reserved.
//

import TransitionTreasury

/// Like Twitter Present.
public class TwitterTransitionAnimation: NSObject, TRViewControllerAnimatedTransitioning {

    public var transitionStatus: TransitionStatus

    public var transitionContext: UIViewControllerContextTransitioning?

    private var anchorPointBackup: CGPoint?

    private var positionBackup: CGPoint?

    private var transformBackup: CATransform3D?

    public init(status: TransitionStatus = .present) {
        transitionStatus = status
        super.init()
    }

    public func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.3
    }

    public func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        self.transitionContext = transitionContext
        var fromVC = transitionContext.viewController(forKey: UITransitionContextFromViewControllerKey)
        var toVC = transitionContext.viewController(forKey: UITransitionContextToViewControllerKey)

        let containView = transitionContext.containerView
        let screenBounds = UIScreen.main.bounds
        var angle = M_PI/48
        var transform = CATransform3DIdentity
        transform.m34 = -1.0/500.0

        var fromView = fromVC?.view.snapshotViewAfterScreenUpdates(true)
        var toView = toVC?.view.snapshotViewAfterScreenUpdates(true)

        transformBackup = fromVC?.view.layer.transform

        var startFrame = screenBounds.offsetBy(dx: 0, dy: screenBounds.size.height)
        var finalFrame = screenBounds

        if transitionStatus == .Dismiss {
            swap(&fromView, &toView)
            swap(&fromVC, &toVC)
            swap(&startFrame, &finalFrame)

            let t = CATransform3DRotate(transform, CGFloat(angle), 1, 0, 0)
            fromView?.layer.anchorPoint = CGPoint(x: 0.5, y: 1)
            fromView?.layer.position = CGPoint(x: fromView!.layer.position.x, y: fromView!.layer.position.y + fromView!.layer.bounds.height / 2)
            fromView?.layer.transform = t
		} else if transitionStatus == .Present {
            transform = CATransform3DRotate(transform, CGFloat(angle), 1, 0, 0)
            anchorPointBackup = fromVC?.view.layer.anchorPoint
            positionBackup = fromVC?.view.layer.position
            fromView?.layer.anchorPoint = CGPoint(x: 0.5, y: 1)
            fromView?.layer.position = CGPoint(x: fromView!.layer.position.x, y: fromView!.layer.position.y + fromView!.layer.bounds.height / 2)
        }

        toView?.layer.frame = startFrame

        containView.addSubview(fromVC!.view)
        containView.addSubview(toVC!.view)
        toVC?.view.hidden = true
        fromVC?.view.hidden = true

        UIView.animate(withDuration: transitionDuration(using: transitionContext), delay: 0, options: .curveEaseInOut, animations: {
          fromView?.layer.transform = transform
          toView?.layer.frame = finalFrame
            }) { finished in
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
                if self.transitionStatus == .dismiss && finished {
                  fromView?.layer.anchorPoint = self.anchorPointBackup ?? CGPoint(x: 0.5, y: 0.5)
                  fromView?.layer.position = self.positionBackup ?? CGPoint(x: fromView!.layer.position.x, y: fromView!.layer.position.y - fromView!.layer.bounds.height / 2)
                  fromView?.layer.transform = self.transformBackup ?? CATransform3DIdentity
                }
                toView?.removeFromSuperview()
                fromView?.removeFromSuperview()
                toVC?.view.hidden = false
                fromVC?.view.hidden = false
        }
    }
}
