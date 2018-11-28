//
//  GoogleMapsGeocodingAPIHandler.swift
//  ClimaFun
//
//  Created by Itamar Biton on 28/11/2018.
//  Copyright © 2018 Itamar Biton. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

class GoogleMapsGeocodingAPIHandler {
    
    let API_KEY = "AIzaSyDgyhwD5JUg2LqqbV0nuwndEWkkzcEICmg"
    let BASE_URL = "https://maps.googleapis.com/maps/api/geocode/json"
    
    struct APIKeys {
        static let results = "results"
        static let geometry = "geometry"
        struct GeometryKeys {
            static let location = "location"
            struct LocationKeys {
                static let lat = "lat"
                static let lon = "lng"
            }
        }
    }
    
    func geocode(address: String, completionHandler: @escaping ((_ lat: Float, _ lon: Float) -> Void)) {
        
        // create the request's parameters
        let parameters: Parameters = ["key": API_KEY, "address": address]
        
        // execute the request
        Alamofire.request(BASE_URL, method: .get, parameters: parameters).responseJSON { response in
            
            // log the response serialization result
            print("serialization result: \(response.result)")
            
            // make sure we have received a valid JSON object
            if let responseData = response.result.value as? Dictionary<String, Any> {
                
                // extract the required information from the resposne
                let responseJson = JSON(responseData)
                let lat = responseJson[APIKeys.results][0][APIKeys.geometry][APIKeys.GeometryKeys.location][APIKeys.GeometryKeys.LocationKeys.lat].float ?? 0
                let lon = responseJson[APIKeys.results][0][APIKeys.geometry][APIKeys.GeometryKeys.location][APIKeys.GeometryKeys.LocationKeys.lon].float ?? 0
                
                // run the completion handler
                completionHandler(lat, lon)
            }
            
        }
        
    }
    
}
