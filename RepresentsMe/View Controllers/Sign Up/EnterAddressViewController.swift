//
//  EnterAddressViewController.swift
//  RepresentsMe
//
//  Created by Jacob Hausmann on 4/8/19.
//  Copyright © 2019 11foot8. All rights reserved.
//

import UIKit

class EnterAddressViewController: UIViewController, PickerPopoverViewControllerDelegate, UIPopoverPresentationControllerDelegate {
    // MARK: - Properties
    var email:String?
    var password:String?
    var displayName:String?
    let popoverSegueIdentifier = "SignupPickerPopoverSegue"
    var pickerData: [String] = [String]()

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        streetAddressTextField.clearButtonMode = UITextField.ViewMode.always
        cityTextField.clearButtonMode = UITextField.ViewMode.always
        zipcodeTextField.clearButtonMode = UITextField.ViewMode.always
        // Do any additional setup after loading the view.
    }

    // MARK: - Outlets
    @IBOutlet weak var streetAddressTextField: UITextField!
    @IBOutlet weak var cityTextField: UITextField!
    @IBOutlet weak var stateButton: UIButton!
    @IBOutlet weak var stateTextField: UITextField!
    @IBOutlet weak var zipcodeTextField: UITextField!

    // MARK: - Actions
    @IBAction func createAccountTouchUp(_ sender: Any) {
        attemptCreateUser()
    }

    @IBAction func useCurrentLocationTouchUp(_ sender: Any) {
        // TODO: Reverse Geocode user location and fill address
        // TODO: Enable User Current Location Button
    }

    @IBAction func cancelTouchUp(_ sender: Any) {
        performSegue(withIdentifier: "SignupAddressUnwindSegue", sender: self)
    }

    func attemptCreateUser() {
        // Check all values are valid
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

        // TODO: Check address validity

        let address = Address(streetAddress: streetAddress, city: city, state: state, zipcode: zipcode)

        // Display loading animation
        let hud = LoadingHUD(self.view)
        UsersDatabase.shared.createUser(email: email, password: password, displayName:displayName, address:address) { error in
            if let _ = error {
                // TODO: Handle error
                print(error.debugDescription)
                // End loading animation
                hud.end()
                // TODO: display error alert
            } else {
                // End loading animation
                hud.end()
                self.view.endEditing(true)
                let storyBoard = UIStoryboard(name:"Main", bundle:nil)
                let tabBarViewController = storyBoard.instantiateViewController(withIdentifier: "mainTabBarViewController")
                guard let appDel = UIApplication.shared.delegate as? AppDelegate else { return }
                appDel.window?.rootViewController = tabBarViewController
            }
        }
    }

    func pickerDoneTouchUp(selection: String) {
        stateTextField.text = selection
    }

    // MARK: - Segue functions
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

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)

    }
}
