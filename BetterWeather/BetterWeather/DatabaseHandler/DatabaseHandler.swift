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
    
    public func insertData(_ locations: Array<Location>){
        print("Inside insertData()")
        var stmt: OpaquePointer?
        
        let queryString = "INSERT INTO WeatherData (Latitude, Longitude, Date, WeatherType, Temperature, WindDirection, WindSpeed, RelativeHumidity, AirPressure, HorizontalVisibility) VALUES (?,?,?,?,?,?,?,?,?,?)"
        
        if sqlite3_prepare(db, queryString, -1, &stmt, nil) !=  SQLITE_OK{
            let errormessage = String(cString: sqlite3_errmsg(db)!)
            print ("error preparing insert:\(errormessage)")
            return
        }
        
        for location in locations {
            for day in location.days {
                for hour in day.hours {
                    //print(hour)
                    var dateFormatter = ISO8601DateFormatter()
//                    var dateString = dateFormatter.string(from: hour.time) //Make hour.time into Date type
                    sqlite3_bind_double(stmt, 1, Double(location.latitude))
                    sqlite3_bind_double(stmt, 2, Double(location.longitude))
  //                  sqlite3_bind_text(stmt, 3, dateString, -1, nil)
                    sqlite3_bind_int(stmt, 4, Int32(hour.weatherType.rawValue))
                    sqlite3_bind_double(stmt, 5, Double(hour.temperatur))
                    hour.windDirection != nil ? sqlite3_bind_int(stmt, 6, Int32(hour.windDirection!)) : sqlite3_bind_null(stmt, 6)
                    hour.windSpeed != nil ? sqlite3_bind_double(stmt, 7, Double(hour.windDirection!)) : sqlite3_bind_null(stmt, 7)
                    hour.relativHumidity != nil ? sqlite3_bind_int(stmt, 8, Int32(hour.relativHumidity!)) : sqlite3_bind_null(stmt, 8)
                    hour.airPressure != nil ? sqlite3_bind_double(stmt, 9, Double(hour.airPressure!)) : sqlite3_bind_null(stmt, 9)
                    hour.HorizontalVisibility != nil ? sqlite3_bind_double(stmt, 10, Double(hour.HorizontalVisibility!)) : sqlite3_bind_null(stmt, 10)
                }
            }
        }
        
        if sqlite3_step(stmt) != SQLITE_DONE {
            let errormessage = String(cString: sqlite3_errmsg(db)!)
            print("Failed to insert WeatherData: \(errormessage)")
            return
        }
        print("WeatherData saved successfully!")
    }
    
    public func readData() -> Array<Location>?{
        print("Inside readData()")
        let queryString = "SELECT * FROM WeatherData"
        var stmt: OpaquePointer?
        
        if sqlite3_prepare(db, queryString, -1, &stmt, nil) != SQLITE_OK{
            let errormessage = String(cString: sqlite3_errmsg(db)!)
            print("error preparing insert: \(errormessage)")
            return nil
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
        
        
        return nil
        
    }
    
    
}
