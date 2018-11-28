//
//  DailyForecast.swift
//  ClimaFun
//
//  Created by Itamar Biton on 28/11/2018.
//  Copyright © 2018 Itamar Biton. All rights reserved.
//

import Foundation

struct DailyForecast {
    /** The temperature value of the forecast */
    let temperature: ForecastValue
    
    /** The percipiration value of the forecast */
    let precipitation: ForecastValue
    
    /** The time in which the forecast is observed */
    let observationTime: Date
    
    init(observationTime: Date, temperature: ForecastValue, percipitation: ForecastValue) {
        self.observationTime = observationTime
        self.temperature = temperature
        self.precipitation = percipitation
    }
}
