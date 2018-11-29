//
//  RESTCountriesAPIHandler.swift
//  ClimaFun
//
//  Created by Itamar Biton on 28/11/2018.
//  Copyright © 2018 Itamar Biton. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

class RESTCountriesAPIHandler {
    
    let BASE_URL = "https://restcountries.eu/rest/v2/all"
    
    struct APIKeys {
        static let name = "name"
        static let capital = "capital"
        static let flag = "flag"
        static let countryCode = "alpha2Code"
    }
    
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
        
        /**
         Generates a URL using the received country code
         
         - Parameter countryCode: The Alpha 2 code of the country it's flag's URL should be generated.
         - Returns: A URL object for the country's flag
         */
        func generateFlagUrl(countryCode: String) -> URL {
            return URL(string: "https://www.countryflags.io/\(countryCode)/flat/64.png")!
        }
    }
    
}
