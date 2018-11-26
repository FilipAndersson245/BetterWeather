//
//  Geometry.swift
//  BetterWeather
//
//  Created by Filip Andersson on 2018-11-20.
//  Copyright © 2018 Jonatan Flyckt, Filip Andersson, Simon Arvidson, Marcus Gullstrand. All rights reserved.
//

import Foundation

struct Geometry: Codable {
    let type: String
    let coordinates: [[Float]]
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        type = try values.decode(String.self, forKey: .type)
        coordinates = try values.decode([[Float]].self, forKey: .coordinates)
    }
}
