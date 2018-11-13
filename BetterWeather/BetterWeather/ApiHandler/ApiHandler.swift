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

struct Weather {
    let time: String
    let weatherType:WeatherTypes // Enum 1-27
    let temperatur: Float
    let windDirection: Int // Degree
    let windSpeed: Float
    let relativHumidity: Int // 0-100
    let airPressure: Float
    let HorizontalVisibility: Float
}

class ApiHandler {
    
    public enum ApiHandlerErrors: Error {
        case NonHandledDataTypeError
        case FailedToFetch
        case InvalidUrl
        case MissingData(String)
    }
    
    private static func jsonToWeather(jsonData: Dictionary<String, Any>) -> Array<Weather> {
        var weathers: Array<Weather> = []
        let listOfWeather = jsonData["timeseries"] as? Array<Dictionary<String, Any>>
        for weather in listOfWeather! {
            let time = weather["validTime"] as! String
            let parameters = weather["parameters"] as? Array<Dictionary<String, Any>>
            
            var weatherType:WeatherTypes? // Enum 1-27
            var temperatur: Float?
            var windDirection: Int? // Degree
            var windSpeed: Float?
            var relativHumidity: Int? // 0-100
            var airPressure: Float?
            var HorizontalVisibility: Float?
            
            for parameter in parameters! {
                let values = parameter["values"] as! Array<Any>
                switch parameter["name"] as! String {
                case "Wsymb2":
                    weatherType = values[0] as! WeatherTypes
                case "Wsymb":
                    weatherType = values[0] as! WeatherTypes
                case "t":
                    temperatur = values[0] as! Float
                case "wd":
                    windDirection = values[0] as! Int
                case "ws":
                    windSpeed = values[0] as! Float
                case "r":
                    relativHumidity = values[0] as! Int
                case "msl":
                    airPressure = values[0] as! Float
                case "vis":
                    HorizontalVisibility = values[0] as! Float
                default:
                    break
                }
            }
            
            let weatherObj = Weather(time: time, weatherType: weatherType!, temperatur: temperatur!, windDirection: windDirection!, windSpeed: windSpeed!, relativHumidity: relativHumidity!, airPressure: airPressure!, HorizontalVisibility: HorizontalVisibility!)
            weathers.append(weatherObj)
        }
        return weathers
    }
    
    private static func fetch(lon: Float, lat: Float, completionBlock: @escaping (Array<Weather>) -> Void) throws  {
        let template = "https://opendata-download-metfcst.smhi.se/api/category/pmp3g/version/2/geotype/point/lon/%.4f/lat/%.4f/data.json"
        let urlsString = String(format: template, lon, lat)
        guard let baseUrl = URL(string: urlsString) else {
            print("Error invalid url")
            throw ApiHandlerErrors.InvalidUrl
        }
        
        let task = URLSession.shared.dataTask(with: baseUrl) {
            (data, response, error)	in
                guard let dataResponse = data,
                    error == nil else {
                        print(error?.localizedDescription ?? "Response Error")
                        return
                    }
                do {
                    //here dataResponse received from a network request
                    let jsonResponse = try JSONSerialization.jsonObject(with: dataResponse, options: [])
                    completionBlock(ApiHandler.jsonToWeather(jsonData: jsonResponse as! Dictionary<String, Any>))
                    
                } catch let parsingError {
                    print("Error", parsingError)
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
    
    public static func foo<T>(_ lon: Float, _ lat: Float, type: T.Type) throws ->T  {
        do {
            let a = try ApiHandler.fetch(lon: lon, lat: lat) {(data) in
                
            }
        }
        switch type {
        case is String.Type: //This should be our model that is yet to be implemented
            return "" as! T
        default:
            throw ApiHandlerErrors.NonHandledDataTypeError
        }
    }
}
