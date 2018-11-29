//
//  ForecastValue.swift
//  ClimaFun
//
//  Created by Itamar Biton on 28/11/2018.
//  Copyright © 2018 Itamar Biton. All rights reserved.
//

import Foundation

/**
 Represents a forecast value (either temperature or precipitation) received from Climacell's weather forecast API.
 */
struct ForecastValue {
    var min: Float?
    var max: Float?
    
    init(min: Float? = nil, max: Float? = nil) {
        self.min = min
        self.max = max
    }
}
