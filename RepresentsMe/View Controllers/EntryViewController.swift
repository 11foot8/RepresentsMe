//
//  EntryViewController.swift
//  RepresentsMe
//
//  Created by Jacob Hausmann on 4/2/19.
//  Copyright © 2019 11foot8. All rights reserved.
//

import UIKit


class EntryViewController: UIViewController {
    // MARK: - Properties
    let signupSegueIdentifier = "SignupSegue"
    let loginSegueIdentifier = "LoginSegue"
    let signupUnwindSegueIdentifier = "SignupUnwindSegue"
    let loginUnwindSegueIdentifier = "LoginUnwindSegue"

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

    }

    // MARK: - Outlets

    // MARK: - Actions
    @IBAction func signupTouchUp(_ sender: Any) {
        performSegue(withIdentifier: signupSegueIdentifier, sender: nil)
    }

    @IBAction func loginTouchUp(_ sender: Any) {
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }

    @IBAction func unwindToVC(segue:UIStoryboardSegue) {

    }

}
