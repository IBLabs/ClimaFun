//
//  CapitalCity.swift
//  ClimaFun
//
//  Created by Itamar Biton on 28/11/2018.
//  Copyright © 2018 Itamar Biton. All rights reserved.
//

import Foundation

struct CapitalCity {
    /** name of the country the capital city belongs to */
    let countryName: String
    
    /** capital city name */
    let name: String
    
    /** capital city geolocation latitude */
    var lat: Double?
    
    /** capital city geolocation longitude */
    var lon: Double?
    
    init(countryName: String, name: String, lat: Double? = nil, lon: Double? = nil) {
        self.countryName = countryName
        self.name = name
        self.lat = lat
        self.lon = lon
    }
}
