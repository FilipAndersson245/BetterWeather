//
//  Position.swift
//  BetterWeather
//
//  Created by Filip Andersson on 2018-11-23.
//  Copyright © 2018 Jonatan Flyckt, Filip Andersson, Simon Arvidson, Marcus Gullstrand. All rights reserved.
//

import Foundation


struct Position {
    let lon: Float
    let lat: Float
    let name: String
    
    init(_ lon: Float, _ lat: Float, _ name: String) {
        self.lon = lon
        self.lat = lat
        self.name = name
    }
}
