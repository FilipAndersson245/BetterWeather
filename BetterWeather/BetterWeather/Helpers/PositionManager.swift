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
    
    let internalLocationManager = CLLocationManager()
    
    var longitude: Float? = nil
    
    var latitude: Float? = nil
    
    var lastTimeRefreshed: Date = Date(timeIntervalSince1970: 0)
    
    let refreshInterval: Double = 600
    
    // MARK: - Methods
    
    private init() {
        internalLocationManager.requestWhenInUseAuthorization()
        if CLLocationManager.locationServicesEnabled() {
            internalLocationManager.desiredAccuracy = kCLLocationAccuracyKilometer
            internalLocationManager.startUpdatingLocation()
            NotificationCenter.default.post(name: Notification.Name("reloadViewData"), object: nil)
        }
    }
    
    func hasPosition() -> Bool
    {
        return longitude != nil && latitude != nil
    }
    
    private func getLocationName(completionblock: @escaping (String) -> Void) {
        CLGeocoder().reverseGeocodeLocation(CLLocation(latitude: Double(latitude!), longitude: Double(longitude!))) {
            placemarks, error in
            if error != nil {
                completionblock("Current Location")
            } else {
                completionblock(placemarks!.first!.locality ?? "Current Location")
            }
        }
    }
    
    func updatePositionAndData()
    {
        latitude = nil
        longitude = nil
        let coords = internalLocationManager.location?.coordinate
        if(coords != nil)
        {
            latitude = Float(Double(coords!.latitude))
            longitude = Float(Double(coords!.longitude))
        }
            
        if (PositionManager.shared.hasPosition()) {
            getLocationName() {
                name in
                ApiHandler.getLocationData(name, self.longitude!, self.latitude!) {
                    dbWeathers in
                    CentralManager.shared.currentLocation = Location.weathersToLocations(dbWeathers).first!
                    NotificationCenter.default.post(name: Notification.Name("reloadViewData"), object: nil)
                }
            }
        }
        else
        {
            CentralManager.shared.currentLocation = nil
            NotificationCenter.default.post(name: Notification.Name("reloadViewData"), object: nil)
        }
        lastTimeRefreshed = Date()
    }
    
    func checkWhetherToUpdatePosition()
    {
        // Make sure location is enabled
        if CLLocationManager.locationServicesEnabled() {
            // Check if <timeInterval> seconds since last refresh
            if (Date().timeIntervalSince(lastTimeRefreshed) > refreshInterval)
            {
                updatePositionAndData()
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
