//
//  PositionManager.swift
//  BetterWeather
//
//  Created by Simon Arvidsson on 2018-11-26.
//  Copyright © 2018 Jonatan Flyckt, Filip Andersson, Simon Arvidson, Marcus Gullstrand. All rights reserved.
//

import Foundation

import CoreLocation

class PositionManager: NSObject, CLLocationManagerDelegate {
    
    // MARK: - Properties
    
    static let shared = PositionManager()
    
    // MARK: -
    let locationManager = CLLocationManager()
    var longitude: Float? = nil
    
    var latitude: Float? = nil
    
    var lastTimeRefreshed: Date = Date(timeIntervalSince1970: 0)
    
    let refreshInterval: Double = 600
    
    // MARK: - Methods
    
    override private init() {
        super.init()
        
        self.locationManager.requestWhenInUseAuthorization()
        
        if (CLLocationManager.locationServicesEnabled())
        {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
            print("din mamma")
            updatePositionAndData()
            NotificationCenter.default.post(name: Notification.Name("reloadViewData"), object: nil)

        }
    }
    
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        print("BAJS")
        print(status)
        
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
        print("in update")
        if (PositionManager.shared.hasPosition()) {
            getLocationName() {
                name in
                ApiHandler.getLocationData(name, self.longitude!, self.latitude!) {
                    dbWeathers in
                    print("fetched weather")
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
                let coords = locationManager.location?.coordinate
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
