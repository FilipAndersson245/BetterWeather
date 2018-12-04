//
//  fetcher.swift
//  BetterWeather
//
//  Created by Filip Andersson on 2018-11-06.
//  Copyright © 2018 Jonatan Flyckt, Filip Andersson, Simon Arvidson, Marcus Gullstrand. All rights reserved.
//

import Foundation

// MARK: - Weather Enum

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

// MARK: - APIHandler Class

class ApiHandler {
    
    // MARK: - Properties
    
    public enum ApiHandlerErrors: Error {
        case NonHandledDataTypeError
        case FailedToFetch
        case InvalidUrl
        case MissingData(String)
    }
    
    // MARK: - Methods
    
    // Fetches data from the SMHI API
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
    
    // Gets weather data for a specified location
    public static func getLocationData(_ name: String, _ lon: Float, _ lat: Float, completionBlock: @escaping (Array<DbWeather>) -> Void)
    {
        let dateFormatter : DateFormatter = {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
            formatter.timeZone = TimeZone(identifier: "UTC")
            return formatter
        }()

        fetch(lon: lon, lat: lat) {(data) in
            var day: Array<Weather> = []
            for hourWeather in data.timeSeries {
                var type: WeatherTypes = WeatherTypes.ClearSky
                var t: Float = 10
                var windDir = 0
                var windSpeed: Float = 0
                var relativeHumidity = 0
                var airPressure: Float = 0
                var horizontalVis: Float = 0
                for hourWeatherParameter in hourWeather.parameters {
                    switch hourWeatherParameter.name {
                    case .t:
                        t = hourWeatherParameter.values[0]
                    case .Wsymb2, .Wsymb:
                        type = WeatherTypes(rawValue: Int(hourWeatherParameter.values[0]))!
                    case .wd:
                        windDir = Int(hourWeatherParameter.values[0])
                    case .ws:
                        windSpeed = hourWeatherParameter.values[0]
                    case .r:
                        relativeHumidity = Int(hourWeatherParameter.values[0])
                    case .msl:
                        airPressure = hourWeatherParameter.values[0]
                    case .vis:
                        horizontalVis = hourWeatherParameter.values[0]
                    default:
                        break
                    }
                }
                let date = dateFormatter.date(from: hourWeather.validTime)
                let hour = Weather(weatherType: type,
                                   temperatur: t,
                                   time: date!,
                                   windDirection: windDir,
                                   windSpeed: windSpeed,
                                   relativHumidity: relativeHumidity,
                                   airPressure: airPressure,
                                   HorizontalVisibility: horizontalVis
                                   );
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
            
            for hour in myDay.hours{
                dbWeathers.append(DbWeather(name: name, weatherType: hour.weatherType, temperatur: hour.temperatur, time: hour.time, windDirection: hour.windDirection, windSpeed: hour.windSpeed, relativeHumidity: hour.relativHumidity, airPressure: hour.airPressure, HorizontalVisibility: hour.HorizontalVisibility, longitude: lon, latitude: lat))
            }
            
            completionBlock(dbWeathers)
        }
    }
}
