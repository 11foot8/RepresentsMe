//
//  AddressSettingsViewController.swift
//  RepresentsMe
//
//  Created by Benny Singer on 3/27/19.
//  Copyright © 2019 11foot8. All rights reserved.
//

import UIKit
import CoreData

class AddressSettingsViewController: UIViewController, PickerPopoverViewControllerDelegate, UIPopoverPresentationControllerDelegate {

    // MARK: - Properties
    let usersDB = UsersDatabase.getInstance()
    let popoverSegueIdentifier = "SettingsPickerPopoverSegue"

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        streetAddressTextField.clearButtonMode = UITextField.ViewMode.always
        cityTextField.clearButtonMode = UITextField.ViewMode.always
        zipcodeTextField.clearButtonMode = UITextField.ViewMode.always

        usersDB.getCurrentUserAddress { (address, error) in
            if let _ = error {
                // TODO: Handle error
                print("Error fetching address: \(error.debugDescription)")
            } else {
                if let address = address {
                    self.streetAddressTextField.text = address.streetAddress
                    self.cityTextField.text = address.city
                    self.stateTextField.text = address.state
                    self.zipcodeTextField.text = address.zipcode
                } else {
                    // TODO: Handle nil address
                    print("Address field nil")
                }
            }
        }
    }

    // MARK: - Outlets
    @IBOutlet weak var streetAddressTextField: UITextField!
    @IBOutlet weak var cityTextField: UITextField!
    @IBOutlet weak var stateTextField: UITextField!
    @IBOutlet weak var zipcodeTextField: UITextField!

    // MARK: - Actions
    @IBAction func saveAddress(_ sender: Any) {
        self.view.endEditing(true)
        guard
            let streetAddress = streetAddressTextField.text,
            streetAddress.count > 0,
            let city = cityTextField.text,
            city.count > 0,
            let state = stateTextField.text,
            state.count > 0,
            let zipcode = zipcodeTextField.text,
            zipcode.count > 0
            else {
                let alert = UIAlertController(
                    title: "Empty Fields",
                    message: "An address requires all fields to be filled.",
                    preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default))

                self.present(alert, animated: true, completion: nil)
                return
        }

        let address = Address(streetAddress: streetAddressTextField.text!,
                           city: cityTextField.text!,
                           state: stateTextField.text!,
                           zipcode: zipcodeTextField.text!)

        // TODO: Start loading animation
        usersDB.setUserAddress(uid: usersDB.getCurrentUserUID() ?? "", address: address) { (error) in
            if let _ = error {
                // TODO: Handle error
                // TODO: Stop loading animation
            } else {
                // TODO: Stop loading animation
                let alert = UIAlertController(
                    title: "Saved",
                    message: nil,
                    preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default))

                self.present(alert, animated: true, completion: nil)
            }
        }
    }
    @IBAction func selectStateTouchUp(_ sender: Any) {
        self.view.endEditing(true)
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
