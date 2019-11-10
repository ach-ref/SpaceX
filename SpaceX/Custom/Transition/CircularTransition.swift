//
//  CircularTransition.swift
//  SpaceX
//
//  Created by Achref Marzouki on 09/11/2019.
//  Copyright © 2019 Achref Marzouki. All rights reserved.
//

import UIKit

class CircularTransition: NSObject {

    // MARK: - Transition type
        
        /// Transition type
        enum CircularTransitionType: Int {
            case present, dismiss, pop
        }
        
        // MARK: - Private
        
        /// An `UIView` subclass representing the transition's background view (a circle).
        private var circle: UIView!
        
        // MARK: - Properties
        
        /// The circle's background view color.
        var circleColor: UIColor = UIColor.black.withAlphaComponent(0.5)
        
        /// The transition duration. The default value is `0.3`.
        var duration = 0.3
        
        /// The transition tye. The default value is `.present`.
        var transitionType: CircularTransitionType = .present
        
        /// The transition's starting point. It's also the center of the expanding circle. The default value is `.zero`.
        var startingPoint: CGPoint = .zero
    }

    // MARK: - UIViewController animated aransitioning protocol

    extension CircularTransition: UIViewControllerAnimatedTransitioning {
        
        func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
            return duration
        }
        
        func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
            let containerView = transitionContext.containerView
            
            if transitionType == .present {
                if let presentedView = transitionContext.view(forKey: .to) {
                    let viewCenter = presentedView.center
                    let viewSize = presentedView.frame.size
                    circle = UIView()
                    circle.frame = frameForCircle(withViewSize: viewSize, startPoint: startingPoint)
                    circle.layer.cornerRadius = circle.frame.width * 0.5
                    circle.center = startingPoint
                    circle.backgroundColor = circleColor
                    containerView.addSubview(circle)
                    
                    circle.transform = CGAffineTransform(scaleX: 0.001, y: 0.001)
                    
                    presentedView.center = startingPoint
                    presentedView.transform = CGAffineTransform(scaleX: 0.001, y: 0.001)
                    presentedView.alpha = 0
                    containerView.addSubview(presentedView)
                    
                    UIView.animate(withDuration: duration, delay: 0, options: .curveEaseInOut, animations: {
                        self.circle.transform = .identity
                        presentedView.transform = .identity
                        presentedView.alpha = 1
                        presentedView.center = viewCenter
                    }, completion: { success in
                        transitionContext.completeTransition(success)
                    })
                }
            }
            else {
                let transitionViewKey: UITransitionContextViewKey = transitionType == .pop ? .to : .from
                if let previousView = transitionContext.view(forKey: transitionViewKey) {
                    let viewCenter = previousView.center
                    let viewSize = previousView.frame.size
                    circle.frame = frameForCircle(withViewSize: viewSize, startPoint: startingPoint)
                    circle.layer.cornerRadius = circle.frame.width * 0.5
                    circle.center = startingPoint
                    
                    UIView.animate(withDuration: duration, delay: 0, options: .curveEaseInOut, animations: {
                        self.circle.transform = CGAffineTransform(scaleX: 0.001, y: 0.001)
                        previousView.transform = CGAffineTransform(scaleX: 0.001, y: 0.001)
                        previousView.center = self.startingPoint
                        previousView.alpha = 0
                        if self.transitionType == .pop {
                            containerView.insertSubview(previousView, belowSubview: previousView)
                            containerView.insertSubview(self.circle, belowSubview: previousView)
                        }
                    }, completion: { success in
                        previousView.center = viewCenter
                        previousView.transform = .identity
                        previousView.removeFromSuperview()
                        self.circle.removeFromSuperview()
                        transitionContext.completeTransition(success)
                    })
                }
            }
        }
        
        /// Calculate the circle's frame according to the given size and starting point.
        /// - Parameter size: The size of the `toView`.
        /// - Parameter startPoint: The current circle center.
        private func frameForCircle(withViewSize size: CGSize, startPoint: CGPoint) -> CGRect {
            let width = fmax(startPoint.x, size.width - startPoint.x)
            let height = fmax(startPoint.y, size.height - startPoint.y)
            let offsetVector = sqrt(width * width + height * height) * 2
            let aSize = CGSize(width: offsetVector, height: offsetVector)
            return CGRect(origin: .zero, size: aSize)
        }
}
