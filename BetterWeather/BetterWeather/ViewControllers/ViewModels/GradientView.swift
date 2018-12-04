//
//  GradientView.swift
//  BetterWeather
//
//  Created by Simon Arvidsson on 2018-12-04.
//  Copyright © 2018 Jonatan Flyckt, Filip Andersson, Simon Arvidson, Marcus Gullstrand. All rights reserved.
//

import UIKit

@IBDesignable
class GradientView: UIView {
    
    // MARK: - Properties
    
    @IBInspectable var startColor: UIColor = UIColor.clear
    
    @IBInspectable var endColor: UIColor = UIColor.clear
    
    // MARK: - Methods
    
    override func draw(_ rect: CGRect) {
        let gradient: CAGradientLayer = CAGradientLayer()
        gradient.startPoint = CGPoint(x: 0, y: 0)
        gradient.endPoint = CGPoint(x: 1, y: 1)
        gradient.frame = self.bounds
        gradient.colors = [startColor.cgColor, endColor.cgColor]
        gradient.zPosition = -1
        self.layer.addSublayer(gradient)
    }

}
