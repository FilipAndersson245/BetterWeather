//
//  CentralManager.swift
//  BetterWeather
//
//  Created by Jonatan Flyckt on 2018-11-28.
//  Copyright © 2018 Jonatan Flyckt, Filip Andersson, Simon Arvidson, Marcus Gullstrand. All rights reserved.
//

import Foundation

class CentralManager{
    
    // MARK: - Properties
    
    static let shared = CentralManager()
    
    let dbHandler = DatabaseHandler()
    
    let notificationsHandler = NotificationsHandler()
    
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
    
    // MARK: - Methods
    
    init() {
        populateFavoriteLocations()
    }
    
    // Adds a specified favorite location to view and local storage
    func addFavoriteLocation(name: String, longitude: Float, latitude: Float) {
        let todayDate = Date()
        let favorite = DbFavorite(name: name, longitude: longitude, latitude: latitude, lastUpdate: todayDate)
        if(!self.dbHandler.doesFavoriteLocationExist(dbFavorite: favorite))
        {
            self.dbHandler.addOrUpdateFavoriteLocation(favorite)
            ApiHandler.getLocationData(name, longitude, latitude){
                dbWeathers in
                self.favoriteLocations.append(Location.weathersToLocations(dbWeathers).first!)
                self.dbHandler.insertData(dbWeathers)
                NotificationCenter.default.post(name: Notification.Name("reloadViewData"), object: nil)
            }
        }
    }
    
    // Removes a specified favorite location from view and local storage
    func removeFavoriteLocation(location: Location){
        let favorite = DbFavorite(name: location.name, longitude: location.longitude, latitude: location.latitude, lastUpdate: Date())
        if(self.dbHandler.doesFavoriteLocationExist(dbFavorite: favorite)){
            self.dbHandler.removeFavoriteLocation(dbFavorite: favorite)
            self.dbHandler.removeLocationWeatherData(dbFavorite: favorite)
            let indexToUpdate = self.favoriteLocations.index(where: {$0.latitude == location.latitude && $0.longitude == location.longitude})!
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
    
    // Removes old weather data and updates the view and local storage with new data for a specified location
    func updateWeather(favoriteToUpdate: DbFavorite){
        let indexToUpdate = self.favoriteLocations.index(where: {$0.latitude == favoriteToUpdate.latitude && $0.longitude == favoriteToUpdate.longitude})
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
        self.dbHandler.addOrUpdateFavoriteLocation(DbFavorite(name: favoriteToUpdate.name, longitude: favoriteToUpdate.longitude, latitude: favoriteToUpdate.latitude, lastUpdate: Date()))
        ApiHandler.getLocationData(favoriteToUpdate.name, favoriteToUpdate.longitude, favoriteToUpdate.latitude){
            dbWeathers in
            self.isFetching = true
            self.dbHandler.removeLocationWeatherData(dbFavorite: favoriteToUpdate)
            if indexToUpdate != nil {
                self.favoriteLocations.remove(at: indexToUpdate!)
            }
            self.favoriteLocations.insert(Location.weathersToLocations(dbWeathers).first!, at: indexToUpdate ?? self.favoriteLocations.count)
            self.dbHandler.insertData(dbWeathers)
            
            // Updates view with the new data
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
