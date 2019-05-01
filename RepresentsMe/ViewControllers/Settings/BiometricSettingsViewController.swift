//
//  BiometricSettingsViewController.swift
//  RepresentsMe
//
//  Created by Jacob Hausmann on 4/23/19.
//  Copyright © 2019 11foot8. All rights reserved.
//

import UIKit
import LocalAuthentication

class BiometricSettingsViewController: UIViewController {
    // MARK: - Properties

    // MARK: - Outlets
    @IBOutlet weak var biometricSwitch: UISwitch!
    @IBOutlet weak var titleLabel: UILabel!

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        switch biometricType() {
        case .none:
            titleLabel.text = "Biometrics Not Available"
            biometricSwitch.isEnabled = false
            biometricSwitch.isOn = false
            break
        case .faceID:
            titleLabel.text = "Modify Face ID"
            biometricSwitch.isEnabled = true
            break
        case .touchID:
            titleLabel.text = "Modify Touch ID"
            biometricSwitch.isEnabled = true
            break
        }
        biometricSwitch.isOn = Util.biometricEnabled
        // Do any additional setup after loading the view.
    }

    // MARK: - Actions
    @IBAction func biometricSwitchValueChanged(_ sender: Any) {
        Util.biometricEnabled = biometricSwitch.isOn
    }

    // MARK: - Methods
    func biometricType() -> LABiometryType {
        let authContext = LAContext()
        if #available(iOS 11, *) {
            let _ = authContext.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil)
            return authContext.biometryType
        } else {
            return .none
        }
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
