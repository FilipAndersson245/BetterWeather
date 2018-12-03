//
//  DbFavorite.swift
//  BetterWeather
//
//  Created by Jonatan Flyckt on 2018-11-27.
//  Copyright © 2018 Jonatan Flyckt, Filip Andersson, Simon Arvidson, Marcus Gullstrand. All rights reserved.
//

import Foundation

struct DbFavorite {
    let longitude: Float
    let latitude: Float
    let name: String
    let lastUpdate : Date
    
    init(name: String
        , longitude: Float
        , latitude: Float
        , lastUpdate: Date? = nil)
    {
        self.name = name
        self.longitude = longitude
        self.latitude = latitude
        self.lastUpdate = lastUpdate ?? Date()
    }
}
