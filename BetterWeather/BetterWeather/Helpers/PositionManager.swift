//
//  PositionManager.swift
//  BetterWeather
//
//  Created by Simon Arvidsson on 2018-11-26.
//  Copyright © 2018 Jonatan Flyckt, Filip Andersson, Simon Arvidson, Marcus Gullstrand. All rights reserved.
//

import Foundation
import CoreLocation

class PositionManager {
    
    // MARK: - Properties
    
    static let shared = PositionManager()
    
    // MARK: -
    let internalLocationManager = CLLocationManager()
    var longitude: Float? = nil
    var latitude: Float? = nil
    
    var lastTimeRefreshed: Date = Date(timeIntervalSince1970: 0)
    let refreshInterval: Double = 30    // TODO: Currently 30 sec, change and maybe make global(ish)
    
    private init() {
        // Ask for Authorisation from the User.
        
        // For use in foreground
        internalLocationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            // internalLocationManager.delegate = self
            internalLocationManager.desiredAccuracy = kCLLocationAccuracyKilometer
            internalLocationManager.startUpdatingLocation()
            NotificationCenter.default.post(name: Notification.Name("reloadViewData"), object: nil)
        }
    }
    
    func hasPosition() -> Bool
    {
        return longitude != nil && latitude != nil
    }
    
    func updatePositionAndData()
    {
        // TODO: replace with real fetched data
        if (PositionManager.shared.hasPosition()) {
            CentralManager.shared.currentLocation = Location(name: "New York", latitude: 21.324, longitude: 32.24124, days: [
                Day(date: Date(), averageWeather: Weather(weatherType: .NearlyClearSky, temperatur: 20.3, time:Date()), hours:
                    [
                        Weather(weatherType: .Fog, temperatur: 21, time: Date()),
                        Weather(weatherType: .HeavySnowfall, temperatur: 21.9, time: Date())
                    ]),
                Day(date: Date(), averageWeather: Weather(weatherType: .Thunder, temperatur: -10, time: Date()), hours:
                    [
                        Weather(weatherType: .HeavySleet, temperatur: 2, time: Date()),
                        Weather(weatherType: .Overcast, temperatur: -1.3, time: Date()),
                        Weather(weatherType: .Thunder, temperatur: -9.3, time: Date())
                    ])
                ])
        }
        else
        {
            CentralManager.shared.currentLocation = nil
        }
        NotificationCenter.default.post(name: Notification.Name("reloadViewData"), object: nil)
    }
    
    func checkWhetherToUpdatePosition()
    {
        // Make sure location is enabled
        if CLLocationManager.locationServicesEnabled() {
            // Check if <timeInterval> seconds since last refresh
            if (Date().timeIntervalSince(lastTimeRefreshed) > refreshInterval)
            {
                latitude = nil
                longitude = nil
                let coords = internalLocationManager.location?.coordinate
                if(coords != nil)
                {
                    print("Updating location")
                    latitude = Float(Double(coords!.latitude))
                    longitude = Float(Double(coords!.longitude))
                    updatePositionAndData()
                    lastTimeRefreshed = Date()
                }
            }
        }
        else
        {
            latitude = nil
            longitude = nil
            lastTimeRefreshed = Date(timeIntervalSince1970: 0)  // Sets last refreshed to get newest location when location turned back on
        }
    }
}
