//
//  WeatherTableViewCell.swift
//  BetterWeather
//
//  Created by Simon Arvidsson on 2018-11-06.
//  Copyright © 2018 Jonatan Flyckt, Filip Andersson, Simon Arvidson, Marcus Gullstrand. All rights reserved.
//

import UIKit

@IBDesignable
class WeatherTableViewCell: UITableViewCell {

    // MARK: - Outlets
    
    @IBOutlet weak var mainView: UIView!
    
    @IBOutlet weak var title: UILabel!
    
    @IBOutlet weak var weatherImage: UIImageView!
    
    @IBOutlet weak var temperatureLabel: UILabel!
    
    // MARK: - Properties
    
    var isRotating = false
    
    // MARK: - General methods
    
    func setImage(_ weatherType: WeatherTypes)
    {
        let imageName = [
            "clear": [1,2],
            "half clear": [3,4],
            "cloudy": [5,6],
            "fog": [7],
            "light rain": [8, 18],
            "moderate rain": [9, 19],
            "heavy rain": [10, 20],
            "thunder": [11, 21],
            "sleet": [12, 13, 14, 22, 23, 24],
            "snow": [15, 16, 17, 25, 26, 27]
        ].filter { $0.1.contains(weatherType.rawValue) }.first!.0
        weatherImage.image = UIImage(named: imageName + ".png")
    }
    
    func setTemperature(_ temperature: Float)
    {
        temperatureLabel.text = String(Int(round(temperature)))
    }
    
    func animate() {
        weatherImage.rotate()
    }
    
    // MARK: - Overridden methods
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.backgroundColor = UIColor.clear
        var backGroundSelected = UIView()
        backGroundSelected.backgroundColor = UIColor.clear
        self.selectedBackgroundView = backGroundSelected
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        if(selected) {
            animate()
        }
    }

}
