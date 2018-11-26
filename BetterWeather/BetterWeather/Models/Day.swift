//
//  Day.swift
//  BetterWeather
//
//  Created by Simon Arvidsson on 2018-11-17.
//  Copyright © 2018 Jonatan Flyckt, Filip Andersson, Simon Arvidson, Marcus Gullstrand. All rights reserved.
//

import Foundation

class Day {
    
    init(date: Date, averageWeather: Weather, hours: [ Weather ]) {
        self.date = date
        self.averageWeather = averageWeather
        self.hours = hours
    }
    
    var date: Date
    
    var averageWeather: Weather
    
    var hours: [ Weather ]
    
}
