//
//  Parameter.swift
//  BetterWeather
//
//  Created by Filip Andersson on 2018-11-20.
//  Copyright © 2018 Jonatan Flyckt, Filip Andersson, Simon Arvidson, Marcus Gullstrand. All rights reserved.
//

import Foundation

struct Parameter: Codable {
    
    // MARK: - Properties
    
    let name: ParameterNames
    
    let levelType: String
    
    let level: Int
    
    let unit: String
    
    let values: [Float]
    
    // MARK: - Methods
    
    init(from decoder: Decoder) throws {
        let valuesForParameter = try decoder.container(keyedBy: CodingKeys.self)
        name = try valuesForParameter.decode(ParameterNames.self, forKey: .name)
        levelType = try valuesForParameter.decode(String.self, forKey: .levelType)
        level = try valuesForParameter.decode(Int.self, forKey: .level)
        unit = try valuesForParameter.decode(String.self, forKey: .unit)
        values = try valuesForParameter.decode([Float].self, forKey: .values)
    }
}

// MARK: - Parameter Names enum

// Enum for how data is presented in the SMHI API
enum ParameterNames: String, Codable {
    case msl
    case t
    case vis
    case wd
    case ws
    case r
    case tstm
    case tcc_mean
    case lcc_mean
    case mcc_mean
    case hcc_mean
    case gust
    case pmin
    case pmax
    case spp
    case pcat
    case pmean
    case pmedian
    case Wsymb2
    case Wsymb
}

