//
//  SignupAddressViewController.swift
//  RepresentsMe
//
//  Created by Jacob Hausmann on 4/8/19.
//  Copyright © 2019 11foot8. All rights reserved.
//

import UIKit

// SignupAddressViewController -> StatePopoverViewController
let POPOVER_SEGUE_IDENTIFIER = "SignupPickerPopoverSegue"
// SignupAddressViewController -> SignupViewController
let SIGNUP_ADDRESS_UNWIND_SEGUE_IDENTIFIER = "SignupAddressUnwindSegue"

/// The view controller to have the user select an address and create their
/// account.
class SignupAddressViewController: UIViewController,
                                   StatePopoverViewControllerDelegate,
                                   UIPopoverPresentationControllerDelegate {
    
    // MARK: - Properties
    
    var email:String?
    var password:String?
    var displayName:String?
    var pickerData:[String] = []

    // MARK: - Outlets
    @IBOutlet weak var streetAddressTextField: UITextField!
    @IBOutlet weak var cityTextField: UITextField!
    @IBOutlet weak var stateButton: UIButton!
    @IBOutlet weak var stateTextField: UITextField!
    @IBOutlet weak var zipcodeTextField: UITextField!

    // MARK: - Lifecycle
    
    /// Sets up the text fields
    override func viewDidLoad() {
        super.viewDidLoad()
        streetAddressTextField.clearButtonMode = UITextField.ViewMode.always
        cityTextField.clearButtonMode = UITextField.ViewMode.always
        zipcodeTextField.clearButtonMode = UITextField.ViewMode.always
    }

    // MARK: - Actions
    
    /// Attempt to create the user's account when they press the create button
    @IBAction func createAccountTouchUp(_ sender: Any) {
        attemptCreateUser()
    }

    @IBAction func useCurrentLocationTouchUp(_ sender: Any) {
        // TODO: Reverse Geocode user location and fill address
        // TODO: Enable User Current Location Button
    }

    /// Unwind to the signup view controller when the cancel button is pressed
    @IBAction func cancelTouchUp(_ sender: Any) {
        performSegue(withIdentifier: SIGNUP_ADDRESS_UNWIND_SEGUE_IDENTIFIER,
                     sender: self)
    }

    func attemptCreateUser() {
        // Check all values are valid
        // TODO: Check that email is in correct form
        guard let email = email else {
            // TODO: Handle Error
            return
        }
        guard let password = password else {
            // TODO: Handle Error
            return
        }

        guard let displayName = displayName else {
            // TODO: Handle Error
            return
        }
        
        guard let address = self.buildAddress() else {
            // TODO: Handle Error
            return
        }

        // Start the loading animation
        let hud = LoadingHUD(self.view)
        self.view.endEditing(true)
        
        // Create the user
        UsersDatabase.shared.createUser(email: email,
                                        password: password,
                                        displayName: displayName,
                                        address: address) {(error) in
            
            // Stop the loading animation
            hud.end()
            
            if let error = error {
                // Failed to create the user
                self.alert(title: "Error", message: error.localizedDescription)
            } else {
                // Successfully created the user
                AppState.homeAddress = address
                
                // Send the user to the officials list
                let storyBoard = UIStoryboard(name:"Main", bundle:nil)
                let tabBarViewController =
                    storyBoard.instantiateViewController(
                        withIdentifier: TAB_BAR_VIEW_CONTROLLER_NAME)
                if let appDel = UIApplication.shared.delegate as? AppDelegate {
                    appDel.window?.rootViewController = tabBarViewController
                }
            }
        }
    }

    /// Set the chosen state when the user selects a state
    func didSelectState(state: String) {
        stateTextField.text = state
    }

    // MARK: - Segue functions
    
    /// Prepare to show the popover for the states select
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == POPOVER_SEGUE_IDENTIFIER {
            let destination = segue.destination as! StatePopoverViewController
            destination.setup(parent: self, view: self.view)
            destination.delegate = self
            destination.selectedValue = stateTextField.text!
        }
    }
    
    func adaptivePresentationStyle(
        for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }

    /// Hide the keyboard when the user touches outside a text field
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    /// Attempts to build the address for the user
    ///
    /// - Returns: the Address or nil if failed to build
    private func buildAddress() -> Address? {
        guard let streetAddress = streetAddressTextField.text else {return nil}
        guard let city = cityTextField.text else {return nil}
        guard let state = stateTextField.text else {return nil}
        guard let zipcode = zipcodeTextField.text else {return nil}

        // TODO: Check address validity
        return Address(streetAddress: streetAddress,
                       city: city,
                       state: state,
                       zipcode: zipcode)
    }
}
