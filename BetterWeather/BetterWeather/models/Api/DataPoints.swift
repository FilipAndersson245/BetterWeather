//
//  DataPoints.swift
//  BetterWeather
//
//  Created by Filip Andersson on 2018-11-20.
//  Copyright © 2018 Jonatan Flyckt, Filip Andersson, Simon Arvidson, Marcus Gullstrand. All rights reserved.
//

import Foundation

struct DataPoint: Codable {
    let validTime: String
    let parameters: [Parameter]
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        validTime = try values.decode(String.self, forKey: .validTime)
        parameters = try values.decode([Parameter].self, forKey: .parameters)
    }
}
