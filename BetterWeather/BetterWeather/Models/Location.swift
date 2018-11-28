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
    
    public static func weatherToLocation(weatherArr: Array<DbWeather>) -> Array<Location>{
        var readLocations = [Location]()
        var currentReadLocation = Location(name: "", latitude: 0, longitude: 0, days: [Day]())
        for hour in weatherArr{
            print(hour)
            if (readLocations.count == 0){
                print("Appending first location")
                currentReadLocation = Location(name: hour.name, latitude: hour.latitude, longitude: hour.longitude, days: [Day]())
                readLocations.append(currentReadLocation)
            }
            if (hour.latitude != currentReadLocation.latitude && hour.longitude != currentReadLocation.longitude){
                print("Appending new location")
                currentReadLocation = Location(name: hour.name, latitude: hour.latitude, longitude: hour.longitude, days: [Day]())
                readLocations.append(currentReadLocation)
            }
            if (readLocations.last?.days.count == 0){
                print("Appending first day")
                readLocations.last?.days.append(Day(date: hour.weather.time, averageWeather: hour.weather, hours: [Weather]()))
            }
            else if (Calendar.current.compare(readLocations.last!.days.last!.date, to: hour.weather.time, toGranularity: .day) != .orderedSame){
                print("Appending new day")
                readLocations.last?.days.append(Day(date: hour.weather.time, averageWeather: hour.weather, hours: [Weather]()))
            }
            readLocations.last?.days.last?.hours.append(Weather(weatherType: hour.weather.weatherType, temperatur: hour.weather.temperatur, time: hour.weather.time, windDirection: hour.weather.windDirection, windSpeed: hour.weather.windSpeed, relativHumidity: hour.weather.relativHumidity, airPressure: hour.weather.airPressure, HorizontalVisibility: hour.weather.HorizontalVisibility))
        }
        return readLocations
    }
    
}
