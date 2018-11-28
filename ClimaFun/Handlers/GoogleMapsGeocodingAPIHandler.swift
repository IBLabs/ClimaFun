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
import MapKit

class GoogleMapsGeocodingAPIHandler {
    
    let API_KEY = "AIzaSyDgyhwD5JUg2LqqbV0nuwndEWkkzcEICmg"
    let BASE_URL = "https://maps.googleapis.com/maps/api/geocode/json"
    
    struct APIKeys {
        static let results = "results"
        static let geometry = "geometry"
        struct GeometryKeys {
            static let location = "location"
            static let viewport = "viewport"
            struct LocationKeys {
                static let lat = "lat"
                static let lon = "lng"
            }
            struct ViewportKeys {
                static let northEast = "northeast"
                static let southWest = "southwest"
                static let lat = "lat"
                static let lon = "lng"
            }
        }
    }
    
    func geocode(address: String, completionHandler: @escaping ((_ coordinate: CLLocationCoordinate2D, _ span: MKCoordinateSpan) -> Void)) {
        
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
                let lat = responseJson[APIKeys.results][0][APIKeys.geometry][APIKeys.GeometryKeys.location][APIKeys.GeometryKeys.LocationKeys.lat].double ?? 0
                let lon = responseJson[APIKeys.results][0][APIKeys.geometry][APIKeys.GeometryKeys.location][APIKeys.GeometryKeys.LocationKeys.lon].double ?? 0
                let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: lon)
                
                // get the north-east bound coordinate
                let northEastLat = responseJson[APIKeys.results][0][APIKeys.geometry][APIKeys.GeometryKeys.viewport][APIKeys.GeometryKeys.ViewportKeys.northEast][APIKeys.GeometryKeys.ViewportKeys.lat].double ?? 0
                let northEastLon = responseJson[APIKeys.results][0][APIKeys.geometry][APIKeys.GeometryKeys.viewport][APIKeys.GeometryKeys.ViewportKeys.northEast][APIKeys.GeometryKeys.ViewportKeys.lon].double ?? 0
                
                // get the south-west bound coordinate
                let southWestLat = responseJson[APIKeys.results][0][APIKeys.geometry][APIKeys.GeometryKeys.viewport][APIKeys.GeometryKeys.ViewportKeys.southWest][APIKeys.GeometryKeys.ViewportKeys.lat].double ?? 0
                let southWestLon = responseJson[APIKeys.results][0][APIKeys.geometry][APIKeys.GeometryKeys.viewport][APIKeys.GeometryKeys.ViewportKeys.southWest][APIKeys.GeometryKeys.ViewportKeys.lon].double ?? 0
                
                // calculate the span
                let span = MKCoordinateSpan(latitudeDelta: abs(southWestLat - northEastLat),
                                            longitudeDelta: abs(southWestLon - northEastLon))
                
                // run the completion handler
                completionHandler(coordinate, span)
            }
            
        }
        
    }
    
}
