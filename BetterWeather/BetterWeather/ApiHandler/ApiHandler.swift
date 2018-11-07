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
    
    private func fetch() {
    
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
