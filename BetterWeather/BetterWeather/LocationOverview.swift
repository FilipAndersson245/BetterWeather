//
//  LocationOverview.swift
//  BetterWeather
//
//  Created by Simon Arvidsson on 2018-11-06.
//  Copyright © 2018 Jonatan Flyckt, Filip Andersson, Simon Arvidson, Marcus Gullstrand. All rights reserved.
//

class LocationOverview {
    
    init(name: String, temperature: Int, weather: String) {
        self.name = name
        self.temperature = temperature
        self.weather = weather
    }
    
    var name: String
    
    var temperature: Int
    
    var weather: String
}
