//
//  AnimationHelper.swift
//  BetterWeather
//
//  Created by Filip Andersson on 2018-11-30.
//  Copyright © 2018 Jonatan Flyckt, Filip Andersson, Simon Arvidson, Marcus Gullstrand. All rights reserved.
//

import Foundation
import UIKit

extension UIView {
    func rotate(duration: Double = 1)
    {
        let kAnimationKey = "rotation"
        if self.layer.animation(forKey: kAnimationKey) == nil {
            let animate = CABasicAnimation(keyPath: "transform.rotation")
            animate.duration = duration
            animate.repeatCount = 0
            animate.fromValue = 0.0
            animate.toValue = Float(Double.pi * 2.0)
            animate.timingFunction = CAMediaTimingFunction(controlPoints: 0.45, 0.01, 0.21, 0.99)
            self.layer.add(animate, forKey: kAnimationKey)
        }
    }
}
