//
//  GradientTableView.swift
//  BetterWeather
//
//  Created by Simon Arvidsson on 2018-12-04.
//  Copyright © 2018 Jonatan Flyckt, Filip Andersson, Simon Arvidson, Marcus Gullstrand. All rights reserved.
//

import UIKit

class GradientTableView: UITableView {
    @IBInspectable var startColor: UIColor = UIColor.clear
    @IBInspectable var endColor: UIColor = UIColor.clear
    
    override func draw(_ rect: CGRect) {
        let gradientBackgroundColors = [startColor.cgColor, endColor.cgColor]
        let gradientLocations: [NSNumber] = [0.0,1.0]

        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = gradientBackgroundColors
        gradientLayer.locations = gradientLocations

        gradientLayer.frame = UIScreen.main.bounds
        let backgroundView = UIView(frame: self.superview!.bounds)
        backgroundView.layer.insertSublayer(gradientLayer, at: 0)
        self.backgroundView = backgroundView
    }

}
