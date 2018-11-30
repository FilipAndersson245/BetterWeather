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
        let favorite = DbFavorite(name: name, longitude: longitude, latitude: latitude, lastUpdate: todayDate)
        self.dbHandler.addFavoriteLocation(favorite)
        sleep(2)
        let hey = self.dbHandler.doesFavoriteLocationExist(dbFavorite: favorite)
        
        print(hey)
        
        // TODO: Check if duplicate (with generalized coordinates)
        //var hey = dbHandler.doesFavoriteLocationExist(dbFavorite: favorite)
        
        ApiHandler.getLocationData(name, longitude, latitude){
            dbWeathers in
            self.favoriteLocations.append(Location.weathersToLocations(dbWeathers).first!)
            self.dbHandler.insertData(dbWeathers)
            completionBlock()
        }
    }
    
    func populateFavoriteLocations(){
        favoriteLocations = Location.weathersToLocations(self.dbHandler.readData() ?? [DbWeather]())
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
        // Requires that favoriteToUpdate exists in favoriteLocations
        // TODO: fetch and update in DB a specified favorite location.
        
        ApiHandler.getLocationData(favoriteToUpdate.name, favoriteToUpdate.longitude, favoriteToUpdate.latitude){
            dbWeathers in
            
            // Remove
            self.dbHandler.removeLocationWeatherData(dbFavorite: favoriteToUpdate)
            let indexToUpdate = self.favoriteLocations.index(where: {$0.latitude == favoriteToUpdate.latitude && $0.longitude == favoriteToUpdate.longitude})!  // Can always find favorite
            self.favoriteLocations.remove(at: indexToUpdate)
            
            
            // Insert
            self.dbHandler.insertData(dbWeathers)
            self.favoriteLocations.insert(Location.weathersToLocations(dbWeathers).first!, at: indexToUpdate)
        }
    }
    
    
    
}
