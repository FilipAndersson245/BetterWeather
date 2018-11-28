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
        }
    }
    
    func hasPosition() -> Bool
    {
        return longitude != nil && latitude != nil
    }
    
    
    func refreshPosition()
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
