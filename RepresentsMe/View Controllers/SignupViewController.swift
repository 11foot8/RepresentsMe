//
//  SignupViewController.swift
//  RepresentsMe
//
//  Created by Jacob Hausmann on 4/2/19.
//  Copyright © 2019 11foot8. All rights reserved.
//

import UIKit
import Firebase

class SignupViewController: UIViewController, PickerPopoverViewControllerDelegate, UIPopoverPresentationControllerDelegate {

    // MARK: - Properties
    let popoverSegueIdentifier = "PickerPopoverSegue"

    let usersDB = UsersDatabase.getInstance()


    var pickerData: [String] = [String]()

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        emailTextField.clearButtonMode = UITextField.ViewMode.always
        passwordTextField.clearButtonMode = UITextField.ViewMode.always
        confirmPasswordTextField.clearButtonMode = UITextField.ViewMode.always
        displayNameTextField.clearButtonMode = UITextField.ViewMode.always
        streetAddressTextField.clearButtonMode = UITextField.ViewMode.always
        cityTextField.clearButtonMode = UITextField.ViewMode.always
        zipcodeTextField.clearButtonMode = UITextField.ViewMode.always
    }

    // MARK: - Outlets
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var confirmPasswordTextField: UITextField!
    @IBOutlet weak var displayNameTextField: UITextField!
    @IBOutlet weak var streetAddressTextField: UITextField!
    @IBOutlet weak var cityTextField: UITextField!
    @IBOutlet weak var stateButton: UIButton!
    @IBOutlet weak var stateTextField: UITextField!
    @IBOutlet weak var zipcodeTextField: UITextField!

    // MARK: - Action
    @IBAction func signUpDidTouch(_ sender: Any) {
        attemptCreateUser()
    }
    @IBAction func cancelTouchUp(_ sender: Any) {
        performSegue(withIdentifier: "SignupUnwindSegue", sender: self)
    }

    @IBAction func useCurrentLocationTouchUp(_ sender: Any) {
        // TODO: Reverse Geocode user location and fill address
    }

    func pickerDoneTouchUp(selection: String) {
        stateTextField.text = selection
    }

    func attemptCreateUser() {
        // Check all values are valid
        guard let email = emailTextField.text else {
            // TODO: Handle Error
            return
        }
        guard let password = passwordTextField.text else {
            // TODO: Handle Error
            return
        }
        guard let confirmPassword = confirmPasswordTextField.text else {
            // TODO: Handle Error
            return
        }

        guard let displayName = displayNameTextField.text else {
            // TODO: Handle Error
            return
        }

        guard let streetAddress = streetAddressTextField.text else {
            // TODO: Handle Error
            return
        }

        guard let city = cityTextField.text else {
            // TODO: Handle Error
            return
        }

        guard let state = stateTextField.text else {
            // TODO: Handle Error
            return
        }

        guard let zipcode = zipcodeTextField.text else {
            // TODO: Handle Error
            return
        }

        // TODO: Check that email is in correct form

        guard password == confirmPassword else {
            // TODO: Alert users passwords dont match
            return
        }

        // TODO: Check address validity

        usersDB.createUser(email: email, password: password, displayName:displayName, streetAddress: streetAddress, city: city, state: state, zipcode: zipcode) { error in
            if let _ = error {
                // TODO: Handle error
                print(error.debugDescription)
            } else {
                let storyBoard = UIStoryboard(name:"Main", bundle:nil)
                let tabBarViewController = storyBoard.instantiateViewController(withIdentifier: "mainTabBarViewController")
                self.present(tabBarViewController, animated: true, completion: {})
            }
        }
    }

    // MARK: Segue functions
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == popoverSegueIdentifier {
            let popoverViewController = segue.destination as! PickerPopoverViewController
            popoverViewController.modalPresentationStyle = UIModalPresentationStyle.overFullScreen
            popoverViewController.popoverPresentationController?.delegate=self
            popoverViewController.delegate = self
            popoverViewController.popoverPresentationController?.sourceRect = CGRect(x: view.center.x, y: view.center.y, width: 0, height: 0)
            popoverViewController.popoverPresentationController?.sourceView = view
            popoverViewController.popoverPresentationController?.permittedArrowDirections = UIPopoverArrowDirection(rawValue: 0)
            popoverViewController.selectedValue = stateTextField.text!
            
        }
    }
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
}
