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
    
    public static func foo(_ lon: Float, _ lat: Float,completionBlock: @escaping (WeatherData) -> Void)  {
            fetch(lon: lon, lat: lat) {(data) in
                print(data)
                completionBlock(data)
//                switch type {
//                case is String.Type: //This should be our model that is yet to be implemented
//                    return "" as! T
//                default:
//                    throw ApiHandlerErrors.NonHandledDataTypeError
//                }
            }
    }
}
