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
    
    private let refreshInterval: Double = 1800
    
    init() {
        populateFavoriteLocations()
    }
    
    func addFavoriteLocation(name: String, longitude: Float, latitude: Float, completionBlock: @escaping () -> Void) {
        let todayDate = Date()
        var favorite = DbFavorite(name: name, longitude: longitude, latitude: latitude, lastUpdate: todayDate)
        self.dbHandler.addFavoriteLocation(favorite)
        var favorites = dbHandler.readFavoriteLocations()
        
        // TODO: Check if duplicate (with generalized coordinates)
        ApiHandler.getLocationData(name, longitude, latitude){
            dbWeathers in
            self.favoriteLocations.append(Location.weathersToLocations(weatherArr: dbWeathers).first!)
            self.dbHandler.insertData(dbWeathers)
            completionBlock()
        }
    }
    
    func populateFavoriteLocations(){
        favoriteLocations = Location.weathersToLocations(weatherArr: self.dbHandler.readData() ?? [DbWeather]())
    }
    
    func checkWhetherToUpdateWeather(){
        let favoritesFromDb = dbHandler.readFavoriteLocations()
        if favoritesFromDb == nil{
            return
        }
        for favorite in favoritesFromDb!{
            if (Date().timeIntervalSince(favorite.lastUpdate) > refreshInterval){
                updateWeather(favoriteToUpdate: favorite)
            }
        }
    }
    
    func updateWeather(favoriteToUpdate: DbFavorite){
        // TODO: fetch and update in DB a specified favorite location.
    }
    
    
    
}
