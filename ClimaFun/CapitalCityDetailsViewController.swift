//
//  CapitalCityDetailsViewController.swift
//  ClimaFun
//
//  Created by Itamar Biton on 28/11/2018.
//  Copyright © 2018 Itamar Biton. All rights reserved.
//

import UIKit
import MapKit

class CapitalCityDetailsViewController: UIViewController {
    
    @IBOutlet weak var mapView: MKMapView!
    
    var capitalCity: CapitalCity!

    override func viewDidLoad() {
        super.viewDidLoad()

        // geocode the capital city's location
        let geocodingHanler = GoogleMapsGeocodingAPIHandler()
        geocodingHanler.geocode(address: capitalCity.name) { (coordinate, span) in
            // update the coordinates of the capital city
            self.capitalCity.lat = coordinate.latitude
            self.capitalCity.lon = coordinate.longitude
            
            // show the location on the map
            self.mapView.setRegion(MKCoordinateRegion(center: coordinate, span: span), animated: true)
            
            // get the forecast for the selected capital city
            let climacellHandler = ClimacellAPIHandler()
            climacellHandler.fetchDailyForecast(coordinate: coordinate) { dailyForecastsArr in
                
                // print the results
                for forecast in dailyForecastsArr {
                    print("date: \(forecast.observationTime)")
                    print("temperature: [max: \(forecast.temperature.min ?? -1), min: \(forecast.temperature.max ?? -1)]")
                    print("precipitation: [max: \(forecast.precipitation.min ?? -1), min: \(forecast.precipitation.max ?? -1)]")
                }
            }
        }
    }
    
    // MARK: Initialization Methods
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
