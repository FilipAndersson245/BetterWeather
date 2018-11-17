//
//  LocationOverview.swift
//  BetterWeather
//
//  Created by Simon Arvidsson on 2018-11-06.
//  Copyright © 2018 Jonatan Flyckt, Filip Andersson, Simon Arvidson, Marcus Gullstrand. All rights reserved.
//

import Foundation

class Location {
    
    init(name: String, latitude: Float, longitude: Float, days: [ Day ]) {
        self.name = name
        self.latitude = latitude
        self.longitude = longitude
        self.days = days
    }
    
    var name: String
    
    var latitude: Float
    
    var longitude: Float
    
    var days: [ Day ]
    
}
