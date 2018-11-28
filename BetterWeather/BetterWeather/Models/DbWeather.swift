//
//  DbWeather.swift
//  BetterWeather
//
//  Created by Jonatan Flyckt on 2018-11-27.
//  Copyright © 2018 Jonatan Flyckt, Filip Andersson, Simon Arvidson, Marcus Gullstrand. All rights reserved.
//

import Foundation

struct DbWeather {
    var weather: Weather
    let longitude: Float
    let latitude: Float
    let name: String
    
    init(name: String
        , weatherType:WeatherTypes
        , temperatur: Float
        , time: Date
        , windDirection: Int? = nil
        , windSpeed: Float? = nil
        , relativeHumidity: Int? = nil
        , airPressure: Float? = nil
        , HorizontalVisibility: Float? = nil
        , longitude: Float
        , latitude: Float)
    {
        self.name = name
        self.weather = Weather(weatherType: weatherType, temperatur: temperatur, time: time, windDirection: windDirection, windSpeed: windSpeed, relativHumidity: relativeHumidity, airPressure: airPressure, HorizontalVisibility: HorizontalVisibility)
        self.longitude = longitude
        self.latitude = latitude
    }
}
