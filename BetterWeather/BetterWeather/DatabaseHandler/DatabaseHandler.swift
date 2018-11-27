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
        
        //sqlite3_exec(db, "DROP TABLE WeatherData;", nil, nil, nil)
        
        if sqlite3_exec(db, "CREATE TABLE IF NOT EXISTS WeatherData (Name TEXT, Latitude REAL, Longitude INTEGER, Date REAL, WeatherType INTEGER, Temperature REAL, WindDirection INTEGER, WindSpeed REAL, RelativeHumidity INTEGER, AirPressure REAL, HorizontalVisibility REAL, PRIMARY KEY(Latitude, Longitude, Date))", nil, nil, nil) != SQLITE_OK {
            let errormessage = String(cString: sqlite3_errmsg(db)!)
            print("Error creating table: \(errormessage)")
        }
    }
    
    public func insertData(_ locations: Array<Location>){
        print("Inside insertData()")
        var stmt: OpaquePointer?
        
        let queryString = "INSERT OR REPLACE INTO WeatherData (Name, Latitude, Longitude, Date, WeatherType, Temperature, WindDirection, WindSpeed, RelativeHumidity, AirPressure, HorizontalVisibility) VALUES (?,?,?,?,?,?,?,?,?,?,?)"
        
        if sqlite3_prepare(db, queryString, -1, &stmt, nil) !=  SQLITE_OK{
            let errormessage = String(cString: sqlite3_errmsg(db)!)
            print ("error preparing insert:\(errormessage)")
            return
        }
        
        for location in locations {
            for day in location.days {
                for hour in day.hours {
                    sqlite3_bind_text(stmt, 1, location.name, -1, nil)
                    sqlite3_bind_double(stmt, 2, Double(location.latitude))
                    sqlite3_bind_double(stmt, 3, Double(location.longitude))
                    sqlite3_bind_double(stmt, 4, hour.time.timeIntervalSince1970)
                    sqlite3_bind_int(stmt, 5, Int32(hour.weatherType.rawValue))
                    sqlite3_bind_double(stmt, 6, Double(hour.temperatur))
                    hour.windDirection != nil ? sqlite3_bind_int(stmt, 7, Int32(hour.windDirection!)) : sqlite3_bind_null(stmt, 7)
                    hour.windSpeed != nil ? sqlite3_bind_double(stmt, 8, Double(hour.windDirection!)) : sqlite3_bind_null(stmt, 8)
                    hour.relativHumidity != nil ? sqlite3_bind_int(stmt, 9, Int32(hour.relativHumidity!)) : sqlite3_bind_null(stmt, 9)
                    hour.airPressure != nil ? sqlite3_bind_double(stmt, 10, Double(hour.airPressure!)) : sqlite3_bind_null(stmt, 10)
                    hour.HorizontalVisibility != nil ? sqlite3_bind_double(stmt, 11, Double(hour.HorizontalVisibility!)) : sqlite3_bind_null(stmt, 11)
                    if sqlite3_step(stmt) != SQLITE_DONE {
                        let errormessage = String(cString: sqlite3_errmsg(db)!)
                        print("Failed to insert WeatherData: \(errormessage)")
                        return
                    }
                    sqlite3_reset(stmt)
                }
            }
        }
        sqlite3_finalize(stmt)
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
        print("WeatherData successfully read.")
        
        var readLocations = [Location]()
        var currentReadLocation = Location(name: "", latitude: 0, longitude: 0, days: [Day]())
        for hour in readHours{
            print(hour)
            if (readLocations.count == 0){
                print("Appending first location")
                currentReadLocation = Location(name: hour.name, latitude: hour.latitude, longitude: hour.longitude, days: [Day]())
                readLocations.append(currentReadLocation)
            }
            if (hour.latitude != currentReadLocation.latitude && hour.longitude != currentReadLocation.longitude){
                print("Appending new location")
                currentReadLocation = Location(name: hour.name, latitude: hour.latitude, longitude: hour.longitude, days: [Day]())
                readLocations.append(currentReadLocation)
            }
            if (readLocations.last?.days.count == 0){
                print("Appending first day")
                readLocations.last?.days.append(Day(date: hour.weather.time, averageWeather: hour.weather, hours: [Weather]()))
            }
            else if (Calendar.current.compare(readLocations.last!.days.last!.date, to: hour.weather.time, toGranularity: .day) != .orderedSame){
                print("Appending new day")
                readLocations.last?.days.append(Day(date: hour.weather.time, averageWeather: hour.weather, hours: [Weather]()))
            }
            readLocations.last?.days.last?.hours.append(Weather(weatherType: hour.weather.weatherType, temperatur: hour.weather.temperatur, time: hour.weather.time, windDirection: hour.weather.windDirection, windSpeed: hour.weather.windSpeed, relativHumidity: hour.weather.relativHumidity, airPressure: hour.weather.airPressure, HorizontalVisibility: hour.weather.HorizontalVisibility))
            
        }
        return readLocations
    }
    
    
}


