//
//  CapitalCity.swift
//  ClimaFun
//
//  Created by Itamar Biton on 28/11/2018.
//  Copyright © 2018 Itamar Biton. All rights reserved.
//

import Foundation
import MapKit

/**
 Represents a capital city received through combining informatio from the REST Countries API and Google's
 Geocoding API.
 */
struct CapitalCity {
    /** name of the country the capital city belongs to */
    let countryName: String
    
    /** The Alpha 2 code of the country the capital city belongs to */
    let countryCode: String
    
    /** URL of the country's flag */
    var flagUrl: URL? {
        get {
            return URL(string: "https://www.countryflags.io/\(countryCode)/flat/64.png")
        }
    }
    
    /** capital city name */
    let name: String
    
    /** capital city geolocation latitude */
    var lat: Double?
    
    /** capital city geolocation longitude */
    var lon: Double?
    
    /** Coordinate of the north east bound of the capital's region */
    var northEastBoundCoordinate: CLLocationCoordinate2D?
    
    /** Coordinate of the south west bound of the capital's region */
    var southWestBoundCoordinate: CLLocationCoordinate2D?
    
    init(countryName: String,
         countryCode: String,
         name: String,
         lat: Double? = nil,
         lon: Double? = nil,
         northEastBoundCoordinate: CLLocationCoordinate2D? = nil,
         southWestBoundCoordinate: CLLocationCoordinate2D? = nil) {
        self.countryName = countryName
        self.countryCode = countryCode
        self.name = name
        self.lat = lat
        self.lon = lon
        self.northEastBoundCoordinate = northEastBoundCoordinate
        self.southWestBoundCoordinate = southWestBoundCoordinate
    }
}
