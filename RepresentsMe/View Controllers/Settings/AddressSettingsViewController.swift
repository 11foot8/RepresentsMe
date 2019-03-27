//
//  AddressSettingsViewController.swift
//  RepresentsMe
//
//  Created by Benny Singer on 3/27/19.
//  Copyright © 2019 11foot8. All rights reserved.
//

import UIKit
import CoreData

class AddressSettingsViewController: UIViewController {

    @IBOutlet weak var streetNumberTextField: UITextField!
    @IBOutlet weak var streetNameTextField: UITextField!
    @IBOutlet weak var cityTextField: UITextField!
    @IBOutlet weak var stateTextField: UITextField!
    @IBOutlet weak var zipcodeTextField: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()
        streetNumberTextField.text = userAddr.streetNumber
        streetNameTextField.text = userAddr.streetName
        cityTextField.text = userAddr.city
        stateTextField.text = userAddr.state
        zipcodeTextField.text = userAddr.zipcode
    }

    @IBAction func saveAddress(_ sender: Any) {
        guard
            let streetNumber = streetNumberTextField.text,
            streetNumber.count > 0,
            let streetName = streetNameTextField.text,
            streetName.count > 0,
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

        userAddr = Address(streetNumber: streetNumberTextField.text!,
                           streetName: streetNameTextField.text!,
                           city: cityTextField.text!,
                           state: stateTextField.text!,
                           zipcode: zipcodeTextField.text!)

        let alert = UIAlertController(
            title: "Saved",
            message: nil,
            preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))

        self.present(alert, animated: true, completion: nil)
    }
}
