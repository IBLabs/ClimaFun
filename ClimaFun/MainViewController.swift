//
//  ViewController.swift
//  ClimaFun
//
//  Created by Itamar Biton on 28/11/2018.
//  Copyright © 2018 Itamar Biton. All rights reserved.
//

import UIKit
import SDWebImage

class MainViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate {
    
    @IBOutlet weak var capitalCitiesTableView: UITableView!
    @IBOutlet weak var selectedUnitSwitch: UISwitch!
    @IBOutlet weak var settingsButton: UIButton!
    @IBOutlet weak var searchResultsContainerView: UIView!
    
    struct CellIdentifiers {
        static let capitalCityCell = "CapitalCityCellIdentifier"
    }
    
    struct SegueIdentifiers {
        static let capitalCityDetailsSegue = "CapitalCityDetailsSegueIdentifier"
        static let settingsSegue = "SettingsSegueIdentifier"
    }

    /** An array to hold the list of capital cities received from the server */
    var capitalCities: [CapitalCity]?
    
    /** The capital city selected by the user, used to pass to the details view controller */
    var selectedCapitalCity: CapitalCity?
    
    /** Used to manage the status bar color (light when a city is being presented) */
    var isPresentingCapitalCity = false
    
    /** Used to manage the status bar color (light when the settings screen is being presented) */
    var isPresentingSettings = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // initialize the UI
        initializeUI()
        
        // create a handler for the REST Countries API
        let countriesHandler = RESTCountriesAPIHandler()
        countriesHandler.fetchCountries { capitalCities in
            
            // keep the received array and reload the table
            self.capitalCities = capitalCities
            self.capitalCitiesTableView.reloadData()
        }
        
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        if (isPresentingCapitalCity) { return .lightContent } else { return .default }
    }
    
    override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
        return .fade
    }
    
    // MARK: User Interface Methods
    
    @IBAction func didClickedSettingsButton(sender: UIButton) {
        // give a subtle animation to the settings button
        UIView.animate(withDuration: 0.6, delay: 0, options: .curveEaseInOut, animations: {
            self.settingsButton.transform = CGAffineTransform.init(rotationAngle: CGFloat(0.95 * Double.pi))
        }, completion: { finsihed in
            self.settingsButton.transform = CGAffineTransform.identity
        })
        
        // move to the settings view controller
        performSegue(withIdentifier: SegueIdentifiers.settingsSegue, sender: nil)
    }
    
    @IBAction func didBeginEditingSearchTextField(sender: UITextField) {
        // animate the scroll of the table view
        UIView.animate(withDuration: 0.2) {
            // scroll to the search bar
            self.capitalCitiesTableView.setContentOffset(CGPoint(x: 0, y: 88), animated: false)
        }
        
        // animate the entry of the overlay view
        UIView.animate(withDuration: 0.4) {
            // show the overlay
            self.searchResultsContainerView.alpha = 1
        }
    }
    
    func dismissCapitalCityDetailsViewController() {
        // dismiss the view controller
        dismiss(animated: false, completion: nil)
        
        // reset the "capital city presenting" flag
        isPresentingCapitalCity = false
        
        // call for a status bar update
        setNeedsStatusBarAppearanceUpdate()
    }
    
    func dismissSettingsViewController() {
        // dismiss the view controller
        dismiss(animated: false, completion: nil)
        
        // reset the presenting flag
        isPresentingSettings = false
        
        // call for a status bar update
        setNeedsStatusBarAppearanceUpdate()
    }
    
    func initializeUI() {
        // prepare for transparent transitions
        self.modalPresentationStyle = .currentContext
    }
    
    // MARK: Navitation Related Methods
    
    @IBAction func unwindToMainViewController(segue: UIStoryboardSegue) { }
    
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
            capitalCityCell.capitalCityNameLabel.text = capitalCity.name.isEmpty ? "-" : capitalCity.name
            capitalCityCell.flagImageView.sd_setImage(with: capitalCity.flagUrl!, completed: nil)
        }
        
        return cell
    }
    
    // MARK: UITableViewDelegate Methods
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // if this is the capital cities table view, get the city's coordinates
        if (tableView == self.capitalCitiesTableView) {
            // get the matching capital city
            selectedCapitalCity = capitalCities![indexPath.row]
            
            // call for a status bar update
            isPresentingCapitalCity = true
            
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
        static let height: CGFloat = 88
    }
    
    @IBOutlet weak var countryNameLabel: UILabel!
    @IBOutlet weak var capitalCityNameLabel: UILabel!
    @IBOutlet weak var flagImageView: UIImageView!
    
}

