//
//  fetcher.swift
//  BetterWeather
//
//  Created by Filip Andersson on 2018-11-06.
//  Copyright © 2018 Jonatan Flyckt, Filip Andersson, Simon Arvidson, Marcus Gullstrand. All rights reserved.
//

import Foundation

enum WeatherTypes: Int {
    case ClearSky = 1
    case NearlyClearSky = 2
    case VariableCloudiness = 3
    case HalfclearSky = 4
    case CloudySky = 5
    case Overcast = 6
    case Fog = 7
    case LightRainShowers = 8
    case ModerateRainShowers = 9
    case HeavyRainShowers = 10
    case Thunderstorm = 11
    case LightSleetShowers = 12
    case ModerateSleetShowers = 13
    case HeavySleetShowers = 14
    case LightSnowShowers = 15
    case ModerateSnowShowers = 16
    case HeavySnowShowers = 17
    case LightRain = 18
    case ModerateRain = 19
    case HeavyRain = 20
    case Thunder = 21
    case LightSleet = 22
    case ModerateSleet = 23
    case HeavySleet = 24
    case LightSnowfall = 25
    case ModerateSnowfall = 26
    case HeavySnowfall = 27
    
}


class ApiHandler {
    
    public enum ApiHandlerErrors: Error {
        case NonHandledDataTypeError
        case FailedToFetch
        case InvalidUrl
        case MissingData(String)
    }
    
    private static func fetch(lon: Float, lat: Float, completionBlock: @escaping (WeatherData) -> Void)  {
        let template = "https://opendata-download-metfcst.smhi.se/api/category/pmp3g/version/2/geotype/point/lon/%.4f/lat/%.4f/data.json"
        let urlsString = String(format: template, lon, lat)
        
        guard let baseUrl = URL(string: urlsString) else {
            print("Error invalid url")
            return
        }
        
        let task = URLSession.shared.dataTask(with: baseUrl) {
            (data, response, error)	in
            guard let _ = data,
                    error == nil else {
                        print(error?.localizedDescription ?? "Response Error")
                        return
                    }
                do {
                    //here dataResponse received from a network request
                    let weather = try JSONDecoder().decode(WeatherData.self, from: data!)
                    completionBlock(weather)
                } catch let parsingError {
                    print("Error", parsingError)
                    return
                }
        }
        task.resume()
    }
    
    private static func jsonToDB() {
        
    }
    
    private static func dbToObject() {
        
    }
    
    private static func overviewObject() {
        
    }
    
    private static func dayObject() {
    
    }
    
    private static func hourObject() {
        
    }
    
    //Maybe rename foo?
    public static func foo(_ lon: Float, _ lat: Float,completionBlock: @escaping (Location) -> Void)  {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
        dateFormatter.timeZone = TimeZone(identifier: "UTC")

        fetch(lon: lon, lat: lat) {(data) in
            var day: Array<Weather> = []
            for hourWeather in data.timeSeries {
                
                // Default init values for weather if api misses data in a request.
                var type: WeatherTypes = WeatherTypes.ClearSky
                var t: Float = 10
                for hourWeatherParameter in hourWeather.parameters {
                    switch hourWeatherParameter.name {
                    case .t:
                        t = hourWeatherParameter.values[0]
                    case .Wsymb2, .Wsymb:
                        type = WeatherTypes(rawValue: Int(hourWeatherParameter.values[0]))!
                    default:
                        break
                    }
                }
                let date = dateFormatter.date(from: hourWeather.validTime)
                let hour = Weather(weatherType: type, temperatur: t, time: date!);
                day.append(hour)
                
            }
            
            let avgTemp = day.reduce(0, { rest,item in
                rest + item.temperatur
            }) / Float(day.count)
            
            var avgTypeArr = [WeatherTypes:Int]()
            day.forEach({
                avgTypeArr[$0.weatherType] = (avgTypeArr[$0.weatherType] ?? 0) + 1
            })
            guard let (avgType, _) = avgTypeArr.max(by: {$0.value < $1.value}) else {
                print("Error while getting the avgType of weather")
                return
            }
            
            let date = dateFormatter.date(from: data.approvedTime)
            let avgWeather = Weather(weatherType: avgType, temperatur: avgTemp, time: Date())
            
            let myDay = Day(date: date!, averageWeather: avgWeather, hours: day)
            
            
            
            
            var dbWeathers = [DbWeather]()
            for hour in myDay.hours{ //TODO: Generalize lon and lat and get correct cityname
                dbWeathers.append(DbWeather(name: "cityName", weatherType: hour.weatherType, temperatur: hour.temperatur, time: hour.time, windDirection: hour.windDirection, windSpeed: hour.windSpeed, relativeHumidity: hour.relativHumidity, airPressure: hour.airPressure, HorizontalVisibility: hour.HorizontalVisibility, longitude: lon, latitude: lat))
            }
            
            let dbHandler = DatabaseHandler()
            dbHandler.insertData(dbWeathers)
            var readLocations = dbHandler.readData()
            
            
            //favorite location test
            let testDate = NSDate()
            var favorite = DbFavorite(name: "TEST", longitude: 12, latitude: 12, lastUpdate: testDate as Date)
            dbHandler.addFavoriteLocation(favorite)
            var favorites = dbHandler.readFavoriteLocations()
            //end test
            
            completionBlock(Location(name: "faeiaföoguguödv", latitude: 1, longitude: 1, days: [myDay]))
//                switch type {
//                case is String.Type: //This should be our model that is yet to be implemented
//                    return "" as! T
//                default:
//                    throw ApiHandlerErrors.NonHandledDataTypeError
//                }
        }
    }
}
