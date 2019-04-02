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

    @IBOutlet weak var streetAddressTextField: UITextField!
    @IBOutlet weak var cityTextField: UITextField!
    @IBOutlet weak var stateTextField: UITextField!
    @IBOutlet weak var zipcodeTextField: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()
        streetAddressTextField.text = userAddr.streetAddress
        cityTextField.text = userAddr.city
        stateTextField.text = userAddr.state
        zipcodeTextField.text = userAddr.zipcode
    }

    @IBAction func saveAddress(_ sender: Any) {
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

        userAddr = Address(streetAddress: streetAddressTextField.text!,
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
