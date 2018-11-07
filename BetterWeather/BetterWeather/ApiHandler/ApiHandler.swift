//
//  fetcher.swift
//  BetterWeather
//
//  Created by Filip Andersson on 2018-11-06.
//  Copyright © 2018 Jonatan Flyckt, Filip Andersson, Simon Arvidson, Marcus Gullstrand. All rights reserved.
//

import Foundation



class ApiHandler {
    
    public enum ApiHandlerErrors: Error {
        case NonHandledDataTypeError
        case FailedToFetch
        case InvalidUrl
    }
    
    private func fetch(lon: Float, lat: Float) throws  {
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
                    print(jsonResponse) //Response result
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
        
        switch type {
        case is String.Type: //This should be our model that is yet to be implemented
            return "" as! T
        default:
            throw ApiHandlerErrors.NonHandledDataTypeError
        }
    }
}
