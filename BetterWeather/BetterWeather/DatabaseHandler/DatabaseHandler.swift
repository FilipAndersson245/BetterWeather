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
    
    var mockSendWeatherData = [1.35, 5.4, 861204, 4, 15.5, 45, 3.5, 4, 3.3444, 1.24]
    
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
    
    public func insertData(){
        print("Inside insertData()")
        var stmt: OpaquePointer?
        
        let queryString = "INSERT INTO WeatherData (Latitude, Longitude, Date, WeatherType, Temperature, WindDirection, WindSpeed, RelativeHumidity, AirPressure, HorizontalVisibility) VALUES (?,?,?,?,?,?,?,?,?,?)"
        
        if sqlite3_prepare(db, queryString, -1, &stmt, nil) !=  SQLITE_OK{
            let errormessage = String(cString: sqlite3_errmsg(db)!)
            print ("error preparing insert:\(errormessage)")
            return
        }

        sqlite3_bind_double(stmt, 1, mockSendWeatherData[0])
        sqlite3_bind_double(stmt, 2, mockSendWeatherData[1])
        sqlite3_bind_int(stmt, 3, Int32(mockSendWeatherData[2]))
        sqlite3_bind_int(stmt, 4, Int32(mockSendWeatherData[3]))
        sqlite3_bind_double(stmt, 5, mockSendWeatherData[4])
        sqlite3_bind_int(stmt, 6, Int32(mockSendWeatherData[5]))
        sqlite3_bind_double(stmt, 7, mockSendWeatherData[6])
        sqlite3_bind_int(stmt, 8, Int32(mockSendWeatherData[7]))
        sqlite3_bind_double(stmt, 9, mockSendWeatherData[8])
        sqlite3_bind_double(stmt, 10, mockSendWeatherData[9])
        
        if sqlite3_step(stmt) != SQLITE_DONE {
            let errormessage = String(cString: sqlite3_errmsg(db)!)
            print("Failed to insert WeatherData: \(errormessage)")
            return
        }
        
        print("WeatherData saved successfully!")
        
    }
    
    public func readData(){
        print("Inside readData()")
        let queryString = "SELECT * FROM WeatherData"
        var stmt: OpaquePointer?
        
        
        
        if sqlite3_prepare(db, queryString, -1, &stmt, nil) != SQLITE_OK{
            let errormessage = String(cString: sqlite3_errmsg(db)!)
            print("error preparing insert: \(errormessage)")
            return
        }
        
        while(sqlite3_step(stmt) == SQLITE_ROW) {
            let Latitude = sqlite3_column_double(stmt, 0)
            let Longitude = sqlite3_column_double(stmt, 1)
            let Date = sqlite3_column_int(stmt, 2)
            let WeatherType = sqlite3_column_int(stmt, 3)
            let Temperature = sqlite3_column_double(stmt, 4)
            let WindDirection = sqlite3_column_int(stmt, 5)
            let WindSpeed = sqlite3_column_double(stmt, 6)
            let RelativeHumidity = sqlite3_column_int(stmt, 7)
            let AirPressure = sqlite3_column_double(stmt, 8)
            let HorizontalVisibility = sqlite3_column_double(stmt, 9)
            print("WeatherData: \n Latitude: \(Latitude) \n Longitude: \(Longitude) \n Date: \(Date) \n WeatherType: \(WeatherType) \n Temperature: \(Temperature) \n WindDirection: \(WindDirection) \n WindSpeed: \(WindSpeed) \n RelativeHumidity: \(RelativeHumidity) \n AirPressure: \(AirPressure) \n HorizontalVisibility: \(HorizontalVisibility) \n")
        }
        print("WeatherData successfully read.")
        
        
        
        
    }
    
    
}
