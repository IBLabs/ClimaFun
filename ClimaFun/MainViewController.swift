//
//  ViewController.swift
//  ClimaFun
//
//  Created by Itamar Biton on 28/11/2018.
//  Copyright © 2018 Itamar Biton. All rights reserved.
//

import UIKit
import MapKit
import SDWebImage

class MainViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, MKMapViewDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var closeMapButton:UIButton!
    @IBOutlet weak var capitalCitiesTableView: UITableView!
    @IBOutlet weak var searchResultsTableView: UITableView!
    @IBOutlet weak var settingsButton: UIButton!
    @IBOutlet weak var searchResultsContainerView: UIView!
    @IBOutlet weak var searchTextField: UITextField!
    
    @IBOutlet weak var searchBarTrailingConstraint: NSLayoutConstraint!
    
    struct CellIdentifiers {
        static let capitalCityCell = "CapitalCityCellIdentifier"
    }
    
    struct SegueIdentifiers {
        static let capitalCityDetailsSegue = "CapitalCityDetailsSegueIdentifier"
        static let settingsSegue = "SettingsSegueIdentifier"
    }
    
    struct AnnotationViewIdentifiers {
        static let capitalCityAnnotationIdentidier = "CapitalCityAnnotationIdentidier"
    }
    
    struct UIConstants {
        static let initialSearchBarTrailingConstraintConstant: CGFloat = 16
        static let activeSearchBarTrailingConstraintConstant: CGFloat = 72
    }

    /** An array to hold the list of capital cities received from the server */
    var capitalCities: [CapitalCity]?
    
    /** An array that holds the search results */
    var searchResults: [CapitalCity] = []
    
    /** An array of map annotations used to annotate the map */
    var annotations: [MKPointAnnotation]!
    
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
        countriesHandler.fetchLocalCountries { (capitalCities) in
            // keep the parsed capital cities
            self.capitalCities = capitalCities
            
            // reload the data in the tableview
            self.capitalCitiesTableView.reloadData()
            
            // convert the received array to an array of annotations
            annotations = capitalCities.map({ (capitalCity) -> MKPointAnnotation in
                // create an annotation
                let annotation = MKPointAnnotation()
                annotation.title = capitalCity.name
                annotation.subtitle = capitalCity.countryName
                annotation.coordinate = CLLocationCoordinate2D(latitude: capitalCity.lat!, longitude: capitalCity.lon!)
                
                return annotation
            })
            
            // add the created annotations to the map
            mapView.addAnnotations(annotations)
        }
        
        /*
        countriesHandler.fetchCountries { capitalCities in
            // keep the received array and reload the table
            self.capitalCities = capitalCities
            self.capitalCitiesTableView.reloadData()
        }
         */
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // position the map view off-screen so we can animate it in
        let rootViewHeight = view.bounds.height
        mapView.transform = CGAffineTransform.init(translationX: 0, y: -rootViewHeight)
        closeMapButton.transform = CGAffineTransform.init(translationX: 0, y: rootViewHeight)
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
        // show the cancel button
        self.searchBarTrailingConstraint.constant = UIConstants.activeSearchBarTrailingConstraintConstant
        
        // animate the scroll of the table view
        UIView.animate(withDuration: 0.2) {
            // scroll to the search bar
            self.capitalCitiesTableView.setContentOffset(CGPoint(x: 0, y: 88), animated: false)
            self.view.layoutIfNeeded()
        }
        
        // animate the entry of the overlay view
        UIView.animate(withDuration: 0.4) {
            // show the overlay
            self.searchResultsContainerView.alpha = 1
        }
    }
    
    @IBAction func didChangeSearchTextField(sender: UITextField) {
        // make sure we have some capital cities to filter from
        guard let capitalCities = self.capitalCities else {
            return
        }
        
        // get the search text
        let searchText = sender.text!
        
        if (searchText.isEmpty) {
            // if the term is empty, results are empty as well
            searchResults = []
        } else {
            // filter the capital cities array
            searchResults = capitalCities.filter({ (capitalCity) -> Bool in
                return (capitalCity.countryName.lowercased().contains(searchText)
                    || capitalCity.name.lowercased().contains(searchText))
            })
        }
        
        // reload the table view
        searchResultsTableView.reloadData()
    }
    
    @IBAction func didClickedCancelSearchButton(sender: UIButton) {
        // restore the search bar to it's original size
        searchBarTrailingConstraint.constant = UIConstants.initialSearchBarTrailingConstraintConstant
        
        // animate
        UIView.animate(withDuration: 0.4) {
            // scroll to the top
            self.capitalCitiesTableView.setContentOffset(CGPoint(x: 0, y: 0), animated: false)
            self.view.layoutIfNeeded()
        }
        
        // animate the exit of the overlay view
        UIView.animate(withDuration: 0.2) {
            // hide the overlay
            self.searchResultsContainerView.alpha = 0
        }
        
        // dismiss the keyboard and clear the text field
        searchTextField.text = ""
        searchTextField.resignFirstResponder()
        
        // clear the search results and reload the tableview
        searchResults = []
        searchResultsTableView.reloadData()
    }
    
    @IBAction func didClickedMapButton(sender: UIButton) {
        // get the height of the root view so we can animat based on it
        let rootViewHeight = view.bounds.height
        
        // animate the map view in
        UIView.animate(withDuration: 0.6, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: .allowUserInteraction, animations: {
            self.mapView.transform = CGAffineTransform.identity
            self.closeMapButton.transform = CGAffineTransform.identity
            self.capitalCitiesTableView.transform = CGAffineTransform.init(translationX: 0, y: rootViewHeight)
        }, completion: nil)
    }
    
    @IBAction func didClickedCloseMapButton(sender: UIButton) {
        // get the height of the root view so we can animat based on it
        let rootViewHeight = view.bounds.height
        
        // animate the map view out
        UIView.animate(withDuration: 0.6, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: .allowUserInteraction, animations: {
            self.closeMapButton.transform = CGAffineTransform.init(translationX: 0, y: rootViewHeight)
            self.mapView.transform = CGAffineTransform.init(translationX: 0, y: -rootViewHeight)
            self.capitalCitiesTableView.transform = CGAffineTransform.identity
        }, completion: nil)
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
        if (tableView == capitalCitiesTableView) {
            return capitalCities?.count ?? 0
        } else if (tableView == searchResultsTableView) {
            return searchResults.count
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // get a cell
        let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifiers.capitalCityCell, for: indexPath)
        
        // configure the cell
        if let capitalCityCell = cell as? CapitalCityTableViewCell {
            
            // get the matching capital city object
            var capitalCity: CapitalCity!
            if (tableView == capitalCitiesTableView) {
                capitalCity = capitalCities![indexPath.row]
            } else if (tableView == searchResultsTableView) {
                capitalCity = searchResults[indexPath.row]
            } else {
                capitalCity = CapitalCity(countryName: "unknown", countryCode: "xx", name: "unknown")
            }
            
            // set the information on the cell
            capitalCityCell.countryNameLabel.text = capitalCity.countryName
            capitalCityCell.capitalCityNameLabel.text = capitalCity.name.isEmpty ? "-" : capitalCity.name
            capitalCityCell.flagImageView.sd_setImage(with: capitalCity.flagUrl!, completed: nil)
        }
        
        return cell
    }
    
    // MARK: UITableViewDelegate Methods
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // get the matching capital city object
        if (tableView == capitalCitiesTableView) {
            selectedCapitalCity = capitalCities![indexPath.row]
        } else if (tableView == searchResultsTableView) {
            selectedCapitalCity = searchResults[indexPath.row]
        } else {
            selectedCapitalCity = CapitalCity(countryName: "unknown", countryCode: "xx", name: "unknown")
        }
        
        // call for a status bar update
        isPresentingCapitalCity = true
        
        // move to the capital city details view controller
        performSegue(withIdentifier: SegueIdentifiers.capitalCityDetailsSegue, sender: nil)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        // if this is the capital cities table view return it's cells' height
        if (tableView == self.capitalCitiesTableView || tableView == self.searchResultsTableView) {
            return CapitalCityTableViewCell.Constants.height
        }
        
        return UITableView.automaticDimension
    }
    
    // MARK: MKMapViewDelegate Methods
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        // make sure the annotation is a point annotation
        guard let pointAnnotation = annotation as? MKPointAnnotation else {
            return nil
        }
        
        // get the annotation's index
        let index = annotations.firstIndex { $0 == pointAnnotation} ?? -1
        
        // deqeueue an annotation
        if let annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: AnnotationViewIdentifiers.capitalCityAnnotationIdentidier) {
            // configure the button with the new annotation
            annotationView.rightCalloutAccessoryView?.tag = index
            
            return annotationView
        } else {
            // create a new one
            let pinAnnotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: AnnotationViewIdentifiers.capitalCityAnnotationIdentidier)
            pinAnnotationView.canShowCallout = true
            
            // create the accessory button
            let button = UIButton(type: .detailDisclosure)
            button.tag = index
            button.addTarget(self, action: #selector(didClickedPointAnnotationView(sender:)), for: .touchUpInside)
            pinAnnotationView.rightCalloutAccessoryView = button
            
            return pinAnnotationView
        }
    }
    
    @objc func didClickedPointAnnotationView(sender: UIButton) {
        // get the selected capital city
        selectedCapitalCity = capitalCities![sender.tag]
        
        // call for a status bar update
        isPresentingCapitalCity = true
        
        // move to the capital city details view controller
        performSegue(withIdentifier: SegueIdentifiers.capitalCityDetailsSegue, sender: nil)
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

