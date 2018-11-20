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
    
    var db: OpaquePointer?
    
    var fileName = "database.sqlite"
    
    var mockWeatherData = [1, 15.5, 90, 4.5, 40, 20, 1.4]
    
    public func createDB() {
        print("Inside createDB()")
        let fileURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false).appendingPathComponent(fileName)
        if sqlite3_open(fileURL.path, &db) != SQLITE_OK {
            print("Error opening database.")
        }
        
        if sqlite3_exec(db, "CREATE TABLE IF NOT EXISTS WeatherData (Latitude REAL, Longitude REAL, Date INTEGER, WeatherType INTEGER, Temperature REAL, WindDirection INTEGER, WindSpeed REAL, RelativeHumidity INTEGER, AirPressure REAL, HorizontalVisibility REAL, PRIMARY KEY(Latitude, Longitude, Date))", nil, nil, nil) != SQLITE_OK {
            let errormessage = String(cString: sqlite3_errmsg(db)!)
            print("Error creating table: \(errormessage)")
        }
    }
    
/*
     let weatherType:WeatherTypes // Enum 1-27
     let temperatur: Float
     let windDirection: Int // Degree
     let windSpeed: Float
     let relativHumidity: Int // 0-100
     let airPressure: Float
     let HorizontalVisibility: Float
 */
    
    
    
}
