//
//  RESTCountriesAPIHandler.swift
//  ClimaFun
//
//  Created by Itamar Biton on 28/11/2018.
//  Copyright © 2018 Itamar Biton. All rights reserved.
//

import Foundation
import MapKit
import Alamofire
import SwiftyJSON

class RESTCountriesAPIHandler {
    
    /** The base URL of the REST Countries API used to fetch information about the world's capital cities */
    let BASE_URL = "https://restcountries.eu/rest/v2/all"
    
    struct APIKeys {
        static let name = "name"
        static let capital = "capital"
        static let flag = "flag"
        static let countryCode = "alpha2Code"
        struct Local {
            static let name = "name"
            static let location = "location"
            static let viewport = "viewport"
            struct Location {
                static let lat = "lat"
                static let lon = "lng"
            }
            struct Viewport {
                static let northeast = "northeast"
                static let southwest = "southwest"
                static let lat = "lat"
                static let lon = "lng"
            }
        }
    }
    
    /**
     Fetches information from the local prefetched countries JSON file so we can display everyting on a map.
     
     - Parameter completionHandler: A closure that will be run when the fetching is finished.
     */
    func fetchLocalCountries(completionHandler: ((_ capitalCities: [CapitalCity]) -> Void)) {
        // make sure we have a file
        guard let path = Bundle.main.path(forResource: "capital_city_information", ofType: "json") else {
            return
        }
        
        // if we can get the JSON data, parse it
        if let data = try? Data(contentsOf: URL(fileURLWithPath: path)) {
            
            // convert the data to JSON object
            let localJson = JSON(data: data)
            
            // make sure the top level object is an array
            if let countriesJson = localJson.array {
                
                // an array to hold the parsed capital cities
                var capitalCities: [CapitalCity] = []
                
                // iterate over all of the countries
                for countryJson in countriesJson {
                    // get the country's general information
                    let countryName = countryJson[APIKeys.name].string!
                    let countryCode = countryJson[APIKeys.countryCode].string!
                    
                    // get the countrie's capital JSON
                    let capitalJson = countryJson[APIKeys.capital]
                    
                    // get the name of the capital
                    let capitalName = capitalJson[APIKeys.Local.name].string!
                    
                    // get the coordinates of the capital
                    let capitalLat = capitalJson[APIKeys.Local.location][APIKeys.Local.Location.lat].double!
                    let capitalLon = capitalJson[APIKeys.Local.location][APIKeys.Local.Location.lon].double!
                    let capitalCoordinate = CLLocationCoordinate2D(latitude: capitalLat, longitude: capitalLon)
                    
                    // get the coordinates of the northeast bound of the capital's region
                    let northEastLat = capitalJson[APIKeys.Local.viewport][APIKeys.Local.Viewport.northeast][APIKeys.Local.Viewport.lat].double!
                    let northEastLon = capitalJson[APIKeys.Local.viewport][APIKeys.Local.Viewport.northeast][APIKeys.Local.Viewport.lon].double!
                    let northEastCoordinate = CLLocationCoordinate2D(latitude: northEastLat, longitude: northEastLon)
                    
                    // get the coordinates of the southwest bound of the capital's region
                    let southWestLat = capitalJson[APIKeys.Local.viewport][APIKeys.Local.Viewport.southwest][APIKeys.Local.Viewport.lat].double!
                    let southWestLon = capitalJson[APIKeys.Local.viewport][APIKeys.Local.Viewport.southwest][APIKeys.Local.Viewport.lon].double!
                    let southWestCoordinate = CLLocationCoordinate2D(latitude: southWestLat, longitude: southWestLon)
                    
                    // create a new capital city
                    capitalCities.append(CapitalCity(countryName: countryName,
                                                     countryCode: countryCode,
                                                     name: capitalName,
                                                     lat: capitalCoordinate.latitude,
                                                     lon: capitalCoordinate.longitude,
                                                     northEastBoundCoordinate: northEastCoordinate,
                                                     southWestBoundCoordinate: southWestCoordinate))
                }
                
                // run the completion handler
                completionHandler(capitalCities)
            }
            
        }
        
    }
    
    /**
     Fetches country and capital cities information for the REST Countries API.
     
     - Parameter completionHandler: A closure that will be run when the information fetching is finished.
     */
    func fetchCountries(completionHandler: @escaping (_ capitalCities: [CapitalCity]) -> Void) {
        Alamofire.request(BASE_URL).responseJSON { response in
            // log the response serialization result
            print("serialization result: \(response.result)")
            
            // make sure we have received a valid JSON response
            if let responseData = response.result.value {
                
                // convert the received data to a SwiftyJSON JSON object
                let responseJson = JSON(responseData)
                
                // make sure the top object is an array of capital cities
                if let countriesArr = responseJson.array {
                    
                    // create an array to hold our capital cities
                    var capitalCities: [CapitalCity] = []
                    
                    // iterate over the received information and create an array of capital cities
                    for countryDict in countriesArr {
                        // create a new capital city
                        let capital = CapitalCity(countryName: countryDict[APIKeys.name].string!,
                                                  countryCode: countryDict[APIKeys.countryCode].string!,
                                                  name: countryDict[APIKeys.capital].string!)
                        
                        // append it to the array
                        capitalCities.append(capital)
                    }
                    
                    // invoke the completion handler
                    completionHandler(capitalCities)
                }
            }
        }
    }
}
