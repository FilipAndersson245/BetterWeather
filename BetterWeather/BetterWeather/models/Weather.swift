//
//  Weather.swift
//  BetterWeather
//
//  Created by Filip Andersson on 2018-11-21.
//  Copyright © 2018 Jonatan Flyckt, Filip Andersson, Simon Arvidson, Marcus Gullstrand. All rights reserved.
//

import Foundation

struct Weather {
    
    // MARK: - Properties
    
    let time: Date
    
    let weatherType:WeatherTypes
    
    let temperatur: Float
    
    let windDirection: Int?
    
    let windSpeed: Float?
    
    let relativHumidity: Int?
    
    let airPressure: Float?
    
    let HorizontalVisibility: Float?
    
    // MARK: - Methods
    
    init(weatherType:WeatherTypes
        , temperatur: Float
        , time: Date
        , windDirection: Int? = nil
        , windSpeed: Float? = nil
        , relativHumidity: Int? = nil
        , airPressure: Float? = nil
        , HorizontalVisibility: Float? = nil)
    {
        self.time = time
        self.weatherType = weatherType
        self.temperatur = temperatur
        self.windDirection = windDirection
        self.windSpeed = windSpeed
        self.relativHumidity = relativHumidity
        self.airPressure = airPressure
        self.HorizontalVisibility = HorizontalVisibility
    }
}
