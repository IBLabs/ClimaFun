//
//  CapitalCityDetailsViewController.swift
//  ClimaFun
//
//  Created by Itamar Biton on 28/11/2018.
//  Copyright © 2018 Itamar Biton. All rights reserved.
//

import UIKit
import MapKit

class CapitalCityDetailsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var dailyForecastsTableView: UITableView!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var countryLabel: UILabel!
    @IBOutlet weak var capitalCityLabel: UILabel!
    @IBOutlet weak var flagImageView: UIImageView!
    @IBOutlet weak var todayTemperatureLabel: UILabel!
    @IBOutlet weak var todayPcpnLabel: UILabel!
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var cardView: UIView!
    @IBOutlet weak var overlayView: UIView!
    @IBOutlet weak var blurView: UIVisualEffectView!
    
    var capitalCity: CapitalCity!
    var dailyForecastsArr: [DailyForecast]?
    
    var dayOfWeekDateFormatter: DateFormatter?
    
    struct CellIdentifiers {
        static let DailyForecastCellIdentifier = "DailyForecastCellIdentifier"
    }
    
    struct SegueIdentifiers {
        static let UnwindToMainViewControllerSegueIdentifier = "UnwindToMainViewControllerSegueIdentifier"
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // initialize the UI
        initializeUI()
        
        // prepare for animation
        prepareForEntryAnimation()

        // geocode the capital city's location
        let geocodingHanler = GoogleMapsGeocodingAPIHandler()
        geocodingHanler.geocode(address: capitalCity.name) { (coordinate, span) in
            // update the coordinates of the capital city
            self.capitalCity.lat = coordinate.latitude
            self.capitalCity.lon = coordinate.longitude
            
            // show the location on the map
            self.mapView.setRegion(MKCoordinateRegion(center: coordinate, span: span), animated: false)
            
            // get the forecast for the selected capital city
            let climacellHandler = ClimacellAPIHandler()
            climacellHandler.fetchDailyForecast(coordinate: coordinate) { dailyForecastsArr in
                
                // keep the daily forecast array and update the UI
                self.dailyForecastsArr = dailyForecastsArr
                self.updateTodayUI()
                
                // reload the table
                self.initializeDayOfWeekDateFormatter()
                self.dailyForecastsTableView.reloadData()
            }
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // start the entry animation
        performEntryAnimation()
    }
    
    // MARK: Animation Methods
    
    func prepareForEntryAnimation() {
        self.blurView.alpha = 0
        self.overlayView.alpha = 0
        self.cardView.alpha = 0
        self.closeButton.alpha = 0
    }
    
    func performEntryAnimation() {
        // get the root view height so we can position other views
        let rootViewHeight = view.bounds.height
        
        // position the views offscreen
        self.cardView.transform = CGAffineTransform.init(translationX: 0, y: -rootViewHeight)
        self.closeButton.transform = CGAffineTransform.init(translationX: 0, y: rootViewHeight)
        
        // make the views visible again
        self.cardView.alpha = 1
        self.closeButton.alpha = 1
        
        // animate
        UIView.animate(withDuration: 0.6, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: .allowUserInteraction, animations: {
            self.overlayView.alpha = 0.8
            self.blurView.alpha = 1
            self.cardView.transform = CGAffineTransform.identity
            self.closeButton.transform = CGAffineTransform.identity
        }, completion: { finished in
            // call for a status bar color update
            self.presentingViewController?.setNeedsStatusBarAppearanceUpdate()
        })
    }
    
    func performExitAnimation(completionHandler: @escaping (() -> Void)) {
        // get the root view height so we can position other views
        let rootViewHeight = view.bounds.height
        
        // animate
        UIView.animate(withDuration: 0.25, delay: 0, options: .curveLinear, animations: {
            self.overlayView.alpha = 0
            self.blurView.alpha = 0
            self.cardView.transform = CGAffineTransform.init(translationX: 0, y: -rootViewHeight)
            self.closeButton.transform = CGAffineTransform.init(translationX: 0, y: rootViewHeight)
        }) { (finished) in
            completionHandler()
        }
    }
    
    // MARK: User Interface Methods
    
    @IBAction func didClickedCloseButton(sender: UIButton) {
        performExitAnimation {
            if let mainViewController = self.presentingViewController as? MainViewController {
                mainViewController.dismissCapitalCityDetailsViewController()
            }
        }
    }
    
    func initializeUI() {
        self.countryLabel.text = capitalCity.countryName
        self.capitalCityLabel.text = capitalCity.name.isEmpty ? "-" : capitalCity.name
        self.flagImageView.sd_setImage(with: capitalCity.flagUrl!, completed: nil)
        self.todayTemperatureLabel.text = "-"
        self.todayPcpnLabel.text = "-"
    }
    
    func initializeDayOfWeekDateFormatter() {
        // create the date formatter
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE"
        dayOfWeekDateFormatter = dateFormatter
    }
    
    func updateTodayUI() {
        // get the forecast of today
        let todayForecast = dailyForecastsArr!.first
        
        // set the text
        self.todayTemperatureLabel.text = WeatherUtilities.stringForTemperature(tempValue: todayForecast!.temperature)
        self.todayPcpnLabel.text = WeatherUtilities.stringForPcpn(pcpnValue: todayForecast!.precipitation, addUnit: false)
    }
    
    // MARK: UITableViewDataSource Methods
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let dailyForecastsArr = dailyForecastsArr {
            return dailyForecastsArr.count - 1
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // get a cell
        let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifiers.DailyForecastCellIdentifier, for: indexPath)
        
        // configure the cell
        if let dailyForecastCell = cell as? DailyForecastTableViewCell {
            // get the matching daily forecast
            let dailyForecast = dailyForecastsArr![indexPath.row + 1]
            
            // set the text on the labels
            dailyForecastCell.dayLabel.text = dayOfWeekDateFormatter!.string(from: dailyForecast.observationTime).capitalized
            dailyForecastCell.tempLabel.text = WeatherUtilities.stringForTemperature(tempValue: dailyForecast.temperature)
            dailyForecastCell.pcpnLabel.text = WeatherUtilities.stringForPcpn(pcpnValue: dailyForecast.precipitation, addUnit: true)
        }
        
        return cell
    }

}

class DailyForecastTableViewCell: UITableViewCell {
    @IBOutlet weak var dayLabel: UILabel!
    @IBOutlet weak var tempLabel: UILabel!
    @IBOutlet weak var pcpnLabel: UILabel!
}
