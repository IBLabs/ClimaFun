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
    let lat: Float?
    
    /** capital city geolocation longitude */
    let lon: Float?
    
    init(countryName: String, name: String, lat: Float? = nil, lon: Float? = nil) {
        self.countryName = countryName
        self.name = name
        self.lat = lat
        self.lon = lon
    }
}
