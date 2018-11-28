//
//  CentralManager.swift
//  BetterWeather
//
//  Created by Jonatan Flyckt on 2018-11-28.
//  Copyright © 2018 Jonatan Flyckt, Filip Andersson, Simon Arvidson, Marcus Gullstrand. All rights reserved.
//

import Foundation

class CentralManager{
    
    static let shared = CentralManager()
    
    let dbHandler = DatabaseHandler()
    
    var favoriteLocations = Array<Location>()
    
    var currentLocation: Location? = nil
    
    init() {
        populateFavoriteLocations()
    }
    
    func addFavoriteLocation(name: String, longitude: Float, latitude: Float) {
        let todayDate = NSDate()
        var favorite = DbFavorite(name: name, longitude: longitude, latitude: latitude, lastUpdate: todayDate as Date)
        self.dbHandler.addFavoriteLocation(favorite)
        var favorites = dbHandler.readFavoriteLocations()
        
        // TODO: Check if duplicate (with generalized coordinates)
        ApiHandler.getLocationData(name, longitude, latitude){
            dbWeathers in
            self.favoriteLocations.append(Location.weathersToLocations(weatherArr: dbWeathers).first!)
            self.dbHandler.insertData(dbWeathers)
        }
    }
    
    func populateFavoriteLocations(){
        favoriteLocations = Location.weathersToLocations(weatherArr: self.dbHandler.readData() ?? [DbWeather]())
    }
    
    
    
    
    
    
    
}
