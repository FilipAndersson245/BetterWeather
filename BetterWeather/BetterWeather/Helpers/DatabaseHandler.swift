//
//  DatabaseHandler.swift
//  BetterWeather
//
//  Created by Jonatan Flyckt on 2018-11-13.
//  Copyright © 2018 Jonatan Flyckt, Filip Andersson, Simon Arvidson, Marcus Gullstrand. All rights reserved.
//

import Foundation

import SQLite3

class DatabaseHandler{
    
    // MARK: - Properties
    
    var db: OpaquePointer?
    
    var fileName = "database.sqlite"
    
    // MARK: - Methods
    
    init() {
        createDataTable()
        createFavoriteTable()
    }
    
    // MARK: - Favorite location methods
    
    public func createFavoriteTable(){
        let fileURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false).appendingPathComponent(fileName)
        if sqlite3_open(fileURL.path, &db) != SQLITE_OK {
            print("Error opening database.")
        }
        if sqlite3_exec(db, "CREATE TABLE IF NOT EXISTS FavoriteLocations (Name TEXT, Latitude REAL, Longitude INTEGER, LastUpdate REAL, PRIMARY KEY(Latitude, Longitude))", nil, nil, nil) != SQLITE_OK {
            let errormessage = String(cString: sqlite3_errmsg(db)!)
            print("Error creating table: \(errormessage)")
        }
    }
    
    // Adds a favorite location to local storage
    public func addOrUpdateFavoriteLocation(_ favorite: DbFavorite){
        var stmt: OpaquePointer?
        let queryString = "INSERT OR REPLACE INTO FavoriteLocations (Name, Latitude, Longitude, LastUpdate) VALUES (?,?,?,?)"
        if sqlite3_prepare(db, queryString, -1, &stmt, nil) !=  SQLITE_OK{
            let errormessage = String(cString: sqlite3_errmsg(db)!)
            print ("error preparing insertin addFavoriteLocation: \(errormessage)")
            return
        }
        let name = favorite.name as NSString
        sqlite3_bind_text(stmt, 1,  name.utf8String, -1, nil)
        sqlite3_bind_double(stmt, 2, Double(favorite.latitude))
        sqlite3_bind_double(stmt, 3, Double(favorite.longitude))
        sqlite3_bind_double(stmt, 4, favorite.lastUpdate.timeIntervalSince1970)
        if sqlite3_step(stmt) != SQLITE_DONE {
            let errormessage = String(cString: sqlite3_errmsg(db)!)
            print("Failed to insert favorite data: \(errormessage)")
            return
        }
        sqlite3_reset(stmt)
        sqlite3_finalize(stmt)
    }
    
    // Fetches the favorite locations from local storage
    public func readFavoriteLocations() -> Array<DbFavorite>?{
        let queryString = "SELECT * FROM FavoriteLocations"
        var stmt: OpaquePointer?
        if sqlite3_prepare(db, queryString, -1, &stmt, nil) != SQLITE_OK{
            let errormessage = String(cString: sqlite3_errmsg(db)!)
            print("error in readFavoriteLocation: \(errormessage)")
            return nil
        }
        var favoriteLocations = [DbFavorite]()
        while(sqlite3_step(stmt) == SQLITE_ROW) {
            let Name = String(cString: sqlite3_column_text(stmt, 0))
            let Latitude = sqlite3_column_double(stmt, 1)
            let Longitude = sqlite3_column_double(stmt, 2)
            let lastUpdate = NSDate(timeIntervalSince1970: sqlite3_column_double(stmt, 3))
            let favorite = DbFavorite( name: Name, longitude: Float(Longitude), latitude: Float(Latitude), lastUpdate: lastUpdate as Date)
            favoriteLocations.append(favorite)
        }
        return favoriteLocations
    }
    
    public func doesFavoriteLocationExist(dbFavorite: DbFavorite) -> Bool{
        guard let favoriteLocations = readFavoriteLocations() else {
            return false
        }
        for favorite in favoriteLocations{
            if (favorite.latitude == dbFavorite.latitude && favorite.longitude == dbFavorite.longitude){
                return true
            }
        }
        return false
    }
    
    // Removes a location in local storage from the favorite table
    public func removeFavoriteLocation(dbFavorite: DbFavorite){
        var stmt: OpaquePointer?
        let queryString = "DELETE FROM FavoriteLocations WHERE (Latitude = ? AND Longitude = ?)"
        if sqlite3_prepare(db, queryString, -1, &stmt, nil) !=  SQLITE_OK{
            let errormessage = String(cString: sqlite3_errmsg(db)!)
            print ("error removing favorite location:\(errormessage)")
            return
        }
        sqlite3_bind_double(stmt, 1, Double(dbFavorite.latitude))
        sqlite3_bind_double(stmt, 2, Double(dbFavorite.longitude))
        if sqlite3_step(stmt) != SQLITE_DONE {
            let errormessage = String(cString: sqlite3_errmsg(db)!)
            print("Failed to remove favoriteData: \(errormessage)")
            return
        }
        sqlite3_finalize(stmt)
    }
    
    // MARK: - Weather data methods
    
    public func createDataTable() {
        let fileURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false).appendingPathComponent(fileName)
        if sqlite3_open(fileURL.path, &db) != SQLITE_OK {
            print("Error opening database.")
        }
        if sqlite3_exec(db, "CREATE TABLE IF NOT EXISTS WeatherData (Name TEXT, Latitude REAL, Longitude REAL, Date REAL, WeatherType INTEGER, Temperature REAL, WindDirection INTEGER, WindSpeed REAL, RelativeHumidity INTEGER, AirPressure REAL, HorizontalVisibility REAL, PRIMARY KEY(Latitude, Longitude, Date))", nil, nil, nil) != SQLITE_OK {
            let errormessage = String(cString: sqlite3_errmsg(db)!)
            print("Error creating table: \(errormessage)")
        }
    }
    
    // Removes all the weather data in local storage for a specified favorite location
    public func removeLocationWeatherData(dbFavorite: DbFavorite){
        var stmt: OpaquePointer?
        let queryString = "DELETE FROM WeatherData WHERE (Latitude = ? AND Longitude = ?)"
        if sqlite3_prepare(db, queryString, -1, &stmt, nil) !=  SQLITE_OK{
            let errormessage = String(cString: sqlite3_errmsg(db)!)
            print ("error removing weather data:\(errormessage)")
            return
        }
        sqlite3_bind_double(stmt, 1, Double(dbFavorite.latitude))
        sqlite3_bind_double(stmt, 2, Double(dbFavorite.longitude))
        if sqlite3_step(stmt) != SQLITE_DONE {
            let errormessage = String(cString: sqlite3_errmsg(db)!)
            print("Failed to remove favoriteData: \(errormessage)")
            return
        }
        sqlite3_finalize(stmt)
    }
    
    // Removes outdated weather data in local storage for all locations
    public func removeOldLocationWeatherData(){
        var stmt: OpaquePointer?
        let queryString = "DELETE FROM WeatherData WHERE (Date <= ?)"
        if sqlite3_prepare(db, queryString, -1, &stmt, nil) !=  SQLITE_OK{
            let errormessage = String(cString: sqlite3_errmsg(db)!)
            print ("error removing weather data:\(errormessage)")
            return
        }
        sqlite3_bind_double(stmt, 1, Double(Date().timeIntervalSince1970))
        if sqlite3_step(stmt) != SQLITE_DONE {
            let errormessage = String(cString: sqlite3_errmsg(db)!)
            print("Failed to remove favoriteData: \(errormessage)")
            return
        }
        sqlite3_finalize(stmt)
    }
    
    // Saves weather data for a location into local storage
    public func insertData(_ dbWeathers: Array<DbWeather>){
        var stmt: OpaquePointer?
        let queryString = "INSERT OR REPLACE INTO WeatherData (Name, Latitude, Longitude, Date, WeatherType, Temperature, WindDirection, WindSpeed, RelativeHumidity, AirPressure, HorizontalVisibility) VALUES (?,?,?,?,?,?,?,?,?,?,?)"
        if sqlite3_prepare(db, queryString, -1, &stmt, nil) !=  SQLITE_OK{
            let errormessage = String(cString: sqlite3_errmsg(db)!)
            print ("error preparing insert data:\(errormessage)")
            return
        }
        for hour in dbWeathers {
            let name = hour.name as NSString
            sqlite3_bind_text(stmt, 1, name.utf8String, -1, nil)
            sqlite3_bind_double(stmt, 2, Double(hour.latitude))
            sqlite3_bind_double(stmt, 3, Double(hour.longitude))
            sqlite3_bind_double(stmt, 4, hour.weather.time.timeIntervalSince1970)
            sqlite3_bind_int(stmt, 5, Int32(hour.weather.weatherType.rawValue))
            sqlite3_bind_double(stmt, 6, Double(hour.weather.temperatur))
            // Need to cast values, even though it causes warnings
            hour.weather.windDirection != nil ? sqlite3_bind_int(stmt, 7, Int32(hour.weather.windDirection!)) : sqlite3_bind_null(stmt, 7)
            hour.weather.windSpeed != nil ? sqlite3_bind_double(stmt, 8, Double(hour.weather.windDirection!)) : sqlite3_bind_null(stmt, 8)
            hour.weather.relativHumidity != nil ? sqlite3_bind_int(stmt, 9, Int32(hour.weather.relativHumidity!)) : sqlite3_bind_null(stmt, 9)
            hour.weather.airPressure != nil ? sqlite3_bind_double(stmt, 10, Double(hour.weather.airPressure!)) : sqlite3_bind_null(stmt, 10)
            hour.weather.HorizontalVisibility != nil ? sqlite3_bind_double(stmt, 11, Double(hour.weather.HorizontalVisibility!)) : sqlite3_bind_null(stmt, 11)
            if sqlite3_step(stmt) != SQLITE_DONE {
                let errormessage = String(cString: sqlite3_errmsg(db)!)
                print("Failed to insert WeatherData: \(errormessage)")
                return
            }
            sqlite3_reset(stmt)
        }
        sqlite3_finalize(stmt)
    }
    
    // Reads all the weather data for all favorite locations from local storage
    public func readData() -> Array<DbWeather>?{
        let queryString = "SELECT * FROM WeatherData"
        var stmt: OpaquePointer?
        if sqlite3_prepare(db, queryString, -1, &stmt, nil) != SQLITE_OK{
            let errormessage = String(cString: sqlite3_errmsg(db)!)
            print("error reading weather data: \(errormessage)")
            return nil
        }
        var readHours = [DbWeather]()
        while(sqlite3_step(stmt) == SQLITE_ROW) {
            let Name = String(cString: sqlite3_column_text(stmt, 0))
            let Latitude = sqlite3_column_double(stmt, 1)
            let Longitude = sqlite3_column_double(stmt, 2)
            let Date = NSDate(timeIntervalSince1970: sqlite3_column_double(stmt, 3))
            let WeatherType = sqlite3_column_int(stmt, 4)
            let Temperature = sqlite3_column_double(stmt, 5)
            let WindDirection = sqlite3_column_int(stmt, 6)
            let WindSpeed = sqlite3_column_double(stmt, 7)
            let RelativeHumidity = sqlite3_column_int(stmt, 8)
            let AirPressure = sqlite3_column_double(stmt, 9)
            let HorizontalVisibility = sqlite3_column_double(stmt, 10)
            let hour = DbWeather( name: Name,weatherType: WeatherTypes(rawValue: Int(WeatherType))!, temperatur: Float(Temperature), time: Date as Date, windDirection: Int(WindDirection), windSpeed: Float(WindSpeed), relativeHumidity: Int(RelativeHumidity), airPressure: Float(AirPressure), HorizontalVisibility: Float(HorizontalVisibility), longitude: Float(Longitude), latitude: Float(Latitude))
            readHours.append(hour)
        }
        return readHours
    }
}
