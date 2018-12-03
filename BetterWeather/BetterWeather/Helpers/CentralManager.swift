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
    
    private var fetchingQueueGroup = DispatchGroup()
    private var isFetching = false {
        didSet {
            if isFetching {
                fetchingQueueGroup.enter()
            } else {
                fetchingQueueGroup.leave()
            }
        }
    }
    
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
        let indexToUpdate = self.favoriteLocations.index(where: {$0.latitude == favoriteToUpdate.latitude && $0.longitude == favoriteToUpdate.longitude})
        
        // First remove old weather data
        self.dbHandler.removeOldLocationWeatherData()
        if indexToUpdate != nil {
            for (dayIndex, day) in favoriteLocations[indexToUpdate!].days.enumerated() {
                for (hourIndex, hour) in day.hours.enumerated() {
                    if hour.time.compare(Date()) == .orderedAscending {
                        day.hours.remove(at: hourIndex)
                    }
                }
                if day.hours.isEmpty {
                    favoriteLocations[indexToUpdate!].days.remove(at: dayIndex)
                }
            }
        }
        
        // Update FavoriteLocationRefreshTime
        // TODO: Replace with db function that updates
        self.dbHandler.removeFavoriteLocation(dbFavorite: favoriteToUpdate)
        self.dbHandler.addFavoriteLocation(favoriteToUpdate)
        
        ApiHandler.getLocationData(favoriteToUpdate.name, favoriteToUpdate.longitude, favoriteToUpdate.latitude){
            dbWeathers in
            print("örp")
            self.isFetching = true
            
            // Remove
            self.dbHandler.removeLocationWeatherData(dbFavorite: favoriteToUpdate)
            if indexToUpdate != nil {
                self.favoriteLocations.remove(at: indexToUpdate!)
            }
            self.favoriteLocations.insert(Location.weathersToLocations(dbWeathers).first!, at: indexToUpdate ?? self.favoriteLocations.count)
            
            // Insert
            self.dbHandler.insertData(dbWeathers)
            
            
            // Update view
            NotificationCenter.default.post(name: Notification.Name("reloadViewData"), object: nil)
            self.isFetching = false
        }
    }
    
    func updateAllWeathers()
    {
        let favoritesFromDb = dbHandler.readFavoriteLocations()
        if favoritesFromDb == nil{
            return
        }
        for favorite in favoritesFromDb!{
            updateWeather(favoriteToUpdate: favorite)
        }
    }
    
    func getDays(_ isCurrentLocation: Bool, _ locationIndex: Int, completionblock: @escaping ([Day]) -> Void) {
        fetchingQueueGroup.wait()	
        completionblock(isCurrentLocation ? CentralManager.shared.currentLocation!.days : CentralManager.shared.favoriteLocations[locationIndex].days)
    }
    
    func getHours(_ isCurrentLocation: Bool, _ locationIndex: Int, _ dayIndex: Int, completionblock: @escaping ([Weather]) -> Void) {
        fetchingQueueGroup.wait()
        completionblock(isCurrentLocation ? CentralManager.shared.currentLocation!.days[dayIndex].hours : CentralManager.shared.favoriteLocations[locationIndex].days[dayIndex].hours)
    }
}
