//
//  Parameter.swift
//  BetterWeather
//
//  Created by Filip Andersson on 2018-11-20.
//  Copyright © 2018 Jonatan Flyckt, Filip Andersson, Simon Arvidson, Marcus Gullstrand. All rights reserved.
//

import Foundation

struct Parameter: Codable {
    let name: String
    let levelType: String
    let level: Int
    let unit: String
    let values: [Float]
    
    init(from decoder: Decoder) throws {
        let valuesForParameter = try decoder.container(keyedBy: CodingKeys.self)
        name = try valuesForParameter.decode(String.self, forKey: .name)
        levelType = try valuesForParameter.decode(String.self, forKey: .levelType)
        level = try valuesForParameter.decode(Int.self, forKey: .level)
        unit = try valuesForParameter.decode(String.self, forKey: .unit)
        values = try valuesForParameter.decode([Float].self, forKey: .values)
    }
}
