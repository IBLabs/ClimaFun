//
//  ForecastValue.swift
//  ClimaFun
//
//  Created by Itamar Biton on 28/11/2018.
//  Copyright © 2018 Itamar Biton. All rights reserved.
//

import Foundation

struct ForecastValue {
    var min: Float?
    var max: Float?
    
    init(min: Float? = nil, max: Float? = nil) {
        self.min = min
        self.max = max
    }
}
