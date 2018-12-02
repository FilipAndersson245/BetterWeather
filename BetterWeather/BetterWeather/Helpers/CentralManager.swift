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
    
    func addFavoriteLocation(name: String, longitude: Float, latitude: Float) {
        let todayDate = Date()
        let favorite = DbFavorite(name: name, longitude: longitude, latitude: latitude, lastUpdate: todayDate)
        
        // Check if not exists already
        if(!self.dbHandler.doesFavoriteLocationExist(dbFavorite: favorite))
        {
            self.dbHandler.addFavoriteLocation(favorite)
            ApiHandler.getLocationData(name, longitude, latitude){
                dbWeathers in
                self.favoriteLocations.append(Location.weathersToLocations(dbWeathers).first!)
                self.dbHandler.insertData(dbWeathers)
                NotificationCenter.default.post(name: Notification.Name("reloadViewData"), object: nil)
            }
        }
        // TODO: Add alert that says position already added.
    }
    
    func removeFavoriteLocation(location: Location){
        let favorite = DbFavorite(name: location.name, longitude: location.longitude, latitude: location.latitude, lastUpdate: Date())
        if(self.dbHandler.doesFavoriteLocationExist(dbFavorite: favorite)){
            self.dbHandler.removeFavoriteLocation(dbFavorite: favorite)
            self.dbHandler.removeLocationWeatherData(dbFavorite: favorite)
            let indexToUpdate = self.favoriteLocations.index(where: {$0.latitude == location.latitude && $0.longitude == location.longitude})!  // Can always find favorite
            self.favoriteLocations.remove(at: indexToUpdate)
            NotificationCenter.default.post(name: Notification.Name("reloadViewData"), object: nil)
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
        
        ApiHandler.getLocationData(favoriteToUpdate.name, favoriteToUpdate.longitude, favoriteToUpdate.latitude){
            dbWeathers in
            
            // Remove
            self.dbHandler.removeLocationWeatherData(dbFavorite: favoriteToUpdate)
            let indexToUpdate = self.favoriteLocations.index(where: {$0.latitude == favoriteToUpdate.latitude && $0.longitude == favoriteToUpdate.longitude})!  // Can always find favorite
            self.favoriteLocations.remove(at: indexToUpdate)
            
            
            // Update FavoriteLocationRefreshTime
            // TODO: Replace with db function that updates
            self.dbHandler.removeFavoriteLocation(dbFavorite: favoriteToUpdate)
            self.dbHandler.addFavoriteLocation(favoriteToUpdate)
            
            
            // Insert
            self.dbHandler.insertData(dbWeathers)
            self.favoriteLocations.insert(Location.weathersToLocations(dbWeathers).first!, at: indexToUpdate)
            
            // Update view
            NotificationCenter.default.post(name: Notification.Name("reloadViewData"), object: nil)
        }
    }
}
