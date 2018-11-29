//
//  SettingsViewController.swift
//  ClimaFun
//
//  Created by Itamar Biton on 29/11/2018.
//  Copyright © 2018 Itamar Biton. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController {
    
    @IBOutlet weak var selectedUnitSwitch: UISwitch!
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var overlayButton: UIButton!
    @IBOutlet weak var cardView: UIView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // initialize the UI based on user configurations
        initializeUI()
        
        // prepare the UI for the entry animation
        prepareForEntryAnimation()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // perform the entry animation
        performEntryAnimation()
    }
    
    // MARK: User Interface Methods
    
    func initializeUI() {
        // set the state of the unit switch based on the saved state
        selectedUnitSwitch.setOn(WeatherUtilities.shouldUseFahrenheit(), animated: false)
    }
    
    @IBAction func didClickedCloseButton(sender: UIButton) {
        // perform the exit animation
        performExitAnimation {
            
            // tell the presenting view controller to dismiss
            if let mainViewController = self.presentingViewController as? MainViewController {
                mainViewController.dismissSettingsViewController()
            }
        }
    }
    
    @IBAction func didChangeSelectedUnitSwitch(sender: UISwitch) {
        // set the selected unit system
        WeatherUtilities.setSelectedUnit(isFahrenheit: sender.isOn)
    }
    
    // MARK: Animation Methods
    
    func prepareForEntryAnimation() {
        overlayButton.alpha = 0
        self.cardView.alpha = 0
    }
    
    func performEntryAnimation() {
        // get the height of the root view so we can animate based on it
        let rootViewHeight = view.bounds.height
        
        // position the views off-screen and make it visible
        cardView.transform = CGAffineTransform.init(translationX: 0, y: rootViewHeight)
        cardView.alpha = 1
        
        // animate
        UIView.animate(withDuration: 0.4, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: .allowUserInteraction, animations: {
            self.overlayButton.alpha = 1
            self.cardView.transform = CGAffineTransform.init(translationX: 0, y: self.cardView.layer.cornerRadius)
        }, completion: nil)
    }
    
    func performExitAnimation(completionHandler: @escaping (() -> Void)) {
        // get the height of the root view so we can animate based on it
        let rootViewHeight = view.bounds.height
        
        // animate
        UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseIn, animations: {
            self.overlayButton.alpha = 0
            self.cardView.transform = CGAffineTransform.init(translationX: 0, y: rootViewHeight)
        }, completion: { finished in
            completionHandler()
        })
    }
}
