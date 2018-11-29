//
//  ClimacellAPIHandler.swift
//  ClimaFun
//
//  Created by Itamar Biton on 28/11/2018.
//  Copyright © 2018 Itamar Biton. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON
import MapKit

class ClimacellAPIHandler {
    
    /** The API key used to access Climacell's weather API */
    let API_KEY = "mFW54hIC4r5puNkKBrcfQ3Xy3dqFYXCJ"
    
    struct APIURLs {
        static let baseUrl = "https://api2.climacell.co/v2"
        static let dailyForecastUrl = APIURLs.baseUrl + "/weather/forecast/daily/"
    }
    
    struct APIParameterKeys {
        static let apiKey = "apikey"
        struct DailyForecast {
            static let lat = "lat"
            static let lon = "lon"
            static let daysNumber = "num_days"
            static let unitSystem = "unit_system"
            static let fields = "fields"
        }
    }
    
    struct APIParameterValues {
        struct UnitSystem {
            static let celsius = "si"
            static let fahrenheit = "us"
        }
        struct Fields {
            static let temperature = "temp"
            static let precipitation = "precipitation"
        }
    }
    
    struct APIKeys {
        static let dateFormat = "yyyy-MM-dd"
        struct Fields {
            static let temperature = "temp"
            static let precipitation = "precipitation"
        }
        struct FieldValues {
            static let min = "min"
            static let max = "max"
            static let value = "value"
            static let units = "units"
            static let observationTime = "observation_time"
        }
    }
    
    /**
     Uses the Climacell Weather API to fetch the weather forecast for the next 5 days in the specified coordinate.
     
     - Parameter coordinate: The coordinate in which weather should be observed.
     - Parameter completionHandler: A closure that will be run when fetching is complete.
     */
    func fetchDailyForecast(coordinate: CLLocationCoordinate2D, completionHandler: @escaping ((_ dailyForecastsArr: [DailyForecast]) -> Void)) {
        
        // configure the parameters for the request
        let parameters: Parameters = [APIParameterKeys.apiKey: API_KEY,
                                      APIParameterKeys.DailyForecast.daysNumber: 5,
                                      APIParameterKeys.DailyForecast.lat: coordinate.latitude,
                                      APIParameterKeys.DailyForecast.lon: coordinate.longitude,
                                      APIParameterKeys.DailyForecast.unitSystem: APIParameterValues.UnitSystem.celsius,
                                      APIParameterKeys.DailyForecast.fields: [APIParameterValues.Fields.temperature, APIParameterValues.Fields.precipitation]]
        
        // execute the request
        Alamofire.request(APIURLs.dailyForecastUrl, method: .get, parameters: parameters).responseJSON { response in
            // log the result of the serialization process
            print("serialization result: \(response.result)")
            
            // make sure we've received some valid information
            if let responseData = response.result.value {
                
                // convert the received data to a SwiftyJSON object
                let responseJson = JSON(responseData)
                
                // make sure we have received an array of daily forecasts
                if let dailyForecastsJsonArr = responseJson.array {
                    
                    // create an array to hold the generated DailyForecast objects
                    let dailyForecastsArr: [DailyForecast] = dailyForecastsJsonArr.map({ dailyForecastJson -> DailyForecast in
                        
                        // get the observationTime
                        let observationTimeString = dailyForecastJson[APIKeys.FieldValues.observationTime][APIKeys.FieldValues.value].string ?? "unknown"
                        let dateFormatter = DateFormatter()
                        dateFormatter.dateFormat = APIKeys.dateFormat
                        let observationTime = dateFormatter.date(from: observationTimeString) ?? Date()
                        
                        // get the temperature
                        let tempMin = dailyForecastJson[APIKeys.Fields.temperature][0][APIKeys.FieldValues.min][APIKeys.FieldValues.value].float
                        let tempMax = dailyForecastJson[APIKeys.Fields.temperature][1][APIKeys.FieldValues.max][APIKeys.FieldValues.value].float
                        
                        // get the precipitation
                        let precipMin = dailyForecastJson[APIKeys.Fields.precipitation][0][APIKeys.FieldValues.min][APIKeys.FieldValues.value].float
                        var precipMax = dailyForecastJson[APIKeys.Fields.precipitation][1][APIKeys.FieldValues.max][APIKeys.FieldValues.value].float
                        
                        // check if there's only max precipitation
                        if (precipMin == nil) {
                            precipMax = dailyForecastJson[APIKeys.Fields.precipitation][0][APIKeys.FieldValues.max][APIKeys.FieldValues.value].float
                        }
                        
                        // construct a new daily forecast object
                        return DailyForecast(observationTime: observationTime,
                                             temperature: ForecastValue(min: tempMin, max: tempMax),
                                             percipitation: ForecastValue(min: precipMin, max: precipMax))
                    })
                    
                    // invoke the completion handler
                    completionHandler(dailyForecastsArr)
                }
                
            }
        }
        
    }
}
