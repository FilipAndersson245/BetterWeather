//
//  Weather.swift
//  BetterWeather
//
//  Created by Filip Andersson on 2018-11-20.
//  Copyright © 2018 Jonatan Flyckt, Filip Andersson, Simon Arvidson, Marcus Gullstrand. All rights reserved.
//

import Foundation

struct Weather: Codable {
    let approvedTime: String
    let referenceTime: String
    let geometry: Geometry
    let timeSeries: [DataPoint]
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        approvedTime = try values.decode(String.self, forKey: .approvedTime)
        referenceTime = try values.decode(String.self, forKey: .referenceTime)
        geometry = try values.decode(Geometry.self, forKey: .geometry)
        timeSeries = try values.decode([DataPoint].self, forKey: .timeSeries)
    }
}
