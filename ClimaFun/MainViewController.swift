//
//  ViewController.swift
//  ClimaFun
//
//  Created by Itamar Biton on 28/11/2018.
//  Copyright © 2018 Itamar Biton. All rights reserved.
//

import UIKit

class MainViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var capitalCitiesTableView: UITableView!
    
    struct CellIdentifiers {
        static let capitalCityCell = "CapitalCityCellIdentifier"
    }
    
    struct SegueIdentifiers {
        static let capitalCityDetailsSegue = "CapitalCityDetailsSegueIdentifier"
    }

    /** An array to hold the list of capital cities received from the server */
    var capitalCities: [CapitalCity]?
    
    /** The capital city selected by the user, used to pass to the details view controller */
    var selectedCapitalCity: CapitalCity?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // create a handler for the REST Countries API
        let countriesHandler = RESTCountriesAPIHandler()
        countriesHandler.fetchCountries { capitalCities in
            
            // keep the received array and reload the table
            self.capitalCities = capitalCities
            self.capitalCitiesTableView.reloadData()
        }
        
    }
    
    // MARK: Navitation Related Methods
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // if we are moving to the capital city details view controller set the capital city
        if let controller  = segue.destination as? CapitalCityDetailsViewController {
            controller.capitalCity = selectedCapitalCity!
        }
    }
    
    // MARK: UITableViewDataSource Methods
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return capitalCities?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // get a cell
        let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifiers.capitalCityCell, for: indexPath)
        
        // configure the cell
        if let capitalCityCell = cell as? CapitalCityTableViewCell {
            
            // get the matching capital city object
            let capitalCity = capitalCities![indexPath.row]
            capitalCityCell.countryNameLabel.text = capitalCity.countryName
            capitalCityCell.capitalCityNameLabel.text = capitalCity.name
        }
        
        return cell
    }
    
    // MARK: UITableViewDelegate Methods
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // if this is the capital cities table view, get the city's coordinates
        if (tableView == self.capitalCitiesTableView) {
            // get the matching capital city
            selectedCapitalCity = capitalCities![indexPath.row]
            
            // move to the capital city details view controller
            performSegue(withIdentifier: SegueIdentifiers.capitalCityDetailsSegue, sender: nil)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        // if this is the capital cities table view return it's cells' height
        if (tableView == self.capitalCitiesTableView) {
            return CapitalCityTableViewCell.Constants.height
        }
        
        return UITableView.automaticDimension
    }
    
}

class CapitalCityTableViewCell: UITableViewCell {
    
    struct Constants {
        static let height: CGFloat = 150
    }
    
    @IBOutlet weak var countryNameLabel: UILabel!
    @IBOutlet weak var capitalCityNameLabel: UILabel!
    
}

