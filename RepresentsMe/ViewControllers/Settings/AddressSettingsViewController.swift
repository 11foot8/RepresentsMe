//
//  AddressSettingsViewController.swift
//  RepresentsMe
//
//  Created by Benny Singer on 3/27/19.
//  Copyright © 2019 11foot8. All rights reserved.
//

import UIKit
import CoreData
import MapKit

/// The view controller to allow the user to change their home address.
class AddressSettingsViewController: UIViewController, StatePopoverViewControllerDelegate, LocationSelectionDelegate {



    // MARK: - Properties
    let popoverSegueIdentifier = "SettingsPickerPopoverSegue"
    let selectLocationSegue = "SelectLocationSegue"

    // MARK: - Outlets
    
    @IBOutlet weak var streetAddressTextField: UITextField!
    @IBOutlet weak var cityTextField: UITextField!
    @IBOutlet weak var stateTextField: UITextField!
    @IBOutlet weak var zipcodeTextField: UITextField!
    
    // MARK: - Lifecycle
    
    /// Setup the views and load the current address
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setup the text fields
        self.setupTextFields()
        
        // Load the current address
        self.loadAddress()
    }

    // MARK: - Actions
    
    /// Save the user's entered address
    @IBAction func saveAddress(_ sender: Any) {
        // Hide the keyboard
        self.view.endEditing(true)
        
        // Build and save the address
        if let address = self.buildAddress() {
            // Successfully built, save it
            self.save(address: address)
        } else {
            // The address is missing fields
            self.alert(title: "Empty Fields",
                       message: "An address requires all fields to be filled.")
        }
    }
    
    /// Shows the state select popover
    @IBAction func selectStateTouchUp(_ sender: Any) {
        self.view.endEditing(true)
        performSegue(withIdentifier: popoverSegueIdentifier, sender: self)
    }
    
    /// Sets the state to the given selection
    ///
    /// - Parameter selection:  the selected state
    func didSelectState(state: String) {
        stateTextField.text = state
    }

    func didSelectLocation(location: CLLocationCoordinate2D, address: Address) {
        setAddress(address)
    }

    func setAddress(_ address:Address) {
        self.streetAddressTextField.text = address.streetAddress
        self.cityTextField.text = address.city
        self.stateTextField.text = address.state
        self.zipcodeTextField.text = address.zipcode
    }

    // MARK: - Segue functions
    
    /// Prepare to show the state select popover
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == popoverSegueIdentifier {
            let destination = segue.destination as! StatePopoverViewController
            destination.setup(in: self.view)
            destination.delegate = self
            destination.selectedValue = stateTextField.text!
        } else if segue.identifier == selectLocationSegue {
            let destination = segue.destination as! MapViewController
            destination.reachType = .settings
            destination.delegate = self
        }
    }

    /// Hide the keyboard when the user clicks away from a text field
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    /// Sets up the text fields for the view
    private func setupTextFields() {
        streetAddressTextField.clearButtonMode = UITextField.ViewMode.always
        cityTextField.clearButtonMode = UITextField.ViewMode.always
        zipcodeTextField.clearButtonMode = UITextField.ViewMode.always
    }
    
    /// Loads in the user's current address
    private func loadAddress() {
        // Disable the back button while loading
        self.navigationItem.hidesBackButton = true
        
        // Show a loading indicator
        let hud = LoadingHUD(self.view)
        
        // Get the current address
        UsersDatabase.getCurrentUserAddress {(address, error) in
            // Stop the loading animation
            hud.end()
            self.navigationItem.hidesBackButton = false
            
            if error != nil {
                // TODO: Handle error
            } else {
                if let address = address {
                    self.streetAddressTextField.text = address.streetAddress
                    self.cityTextField.text = address.city
                    self.stateTextField.text = address.state
                    self.zipcodeTextField.text = address.zipcode
                } else {
                    // TODO: Handle nil address
                }
            }
        }
    }
    
    /// Builds the address from the views
    ///
    /// - Returns: the Address or nil if missing a field
    private func buildAddress() -> Address? {
        guard let streetAddress = streetAddressTextField.text,
            !streetAddress.isEmpty else {
                return nil
        }
        guard let city = cityTextField.text, !city.isEmpty else {
            return nil
        }
        guard let state = stateTextField.text, !state.isEmpty else {
            return nil
        }
        guard let zipcode = zipcodeTextField.text, !zipcode.isEmpty else {
            return nil
        }
        
        return Address(streetAddress: streetAddress,
                       city: city,
                       state: state,
                       zipcode: zipcode)
    }

    /// Saves the address.
    ///
    /// - Parameter address:    the Address to save
    private func save(address:Address) {
        // Start the loading animation
        self.navigationItem.hidesBackButton = true
        let hud = LoadingHUD(self.view)
        
        if let uid = UsersDatabase.currentUserUID {
            UsersDatabase.shared.setUserAddress(uid: uid,
                                                address: address)
            {(error) in
                // Stop the loading animation
                hud.end()
                self.navigationItem.hidesBackButton = false

                if error != nil {
                    // TODO: Handle error
                } else {
                    AppState.homeAddress = address
                    self.alert(title: "Saved")
                }
            }
        }
    }
}
