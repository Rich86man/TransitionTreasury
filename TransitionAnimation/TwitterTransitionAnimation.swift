//
//  TwitterTransitionAnimation.swift
//  TransitionTreasury
//
//  Created by DianQK on 12/20/15.
//  Copyright © 2016 TransitionTreasury. All rights reserved.
//

import TransitionTreasury

/// Like Twitter Present.
open class TwitterTransitionAnimation: NSObject, TRViewControllerAnimatedTransitioning {

    open var transitionStatus: TransitionStatus

    open var transitionContext: UIViewControllerContextTransitioning?

    fileprivate var anchorPointBackup: CGPoint?

    fileprivate var positionBackup: CGPoint?

    fileprivate var transformBackup: CATransform3D?

    public init(status: TransitionStatus = .present) {
        transitionStatus = status
        super.init()
    }

    open func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.3
    }

    open func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        self.transitionContext = transitionContext
        var fromVC = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from)
        var toVC = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to)

        let containView = transitionContext.containerView
        let screenBounds = UIScreen.main.bounds
        var angle = M_PI/48
        var transform = CATransform3DIdentity
        transform.m34 = -1.0/500.0

        var fromView = fromVC?.view.snapshotView(afterScreenUpdates: true)
        var toView = toVC?.view.snapshotView(afterScreenUpdates: true)

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
        toVC?.view.isHidden = true
        fromVC?.view.isHidden = true

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
                toVC?.view.isHidden = false
                fromVC?.view.isHidden = false
        }
    }
}
