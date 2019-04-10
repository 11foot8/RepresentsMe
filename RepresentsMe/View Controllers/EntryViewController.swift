//
//  EntryViewController.swift
//  RepresentsMe
//
//  Created by Jacob Hausmann on 4/2/19.
//  Copyright © 2019 11foot8. All rights reserved.
//

import UIKit
import MBProgressHUD


class EntryViewController: UIViewController {
    // MARK: - Properties
    let signupSegueIdentifier = "SignupSegue"
    let loginSegueIdentifier = "LoginSegue"
    let signupUnwindSegueIdentifier = "SignupUnwindSegue"
    let loginUnwindSegueIdentifier = "LoginUnwindSegue"
    let signupAddressUnwindSegueIdentifier = "SignupAddressUnwindSegue"
    let usersDB = UsersDatabase.getInstance()

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        emailTextField.clearButtonMode = UITextField.ViewMode.always
        passwordTextField.clearButtonMode = UITextField.ViewMode.always
    }

    // MARK: - Outlets
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!

    // MARK: - Actions
    @IBAction func signupTouchUp(_ sender: Any) {
        performSegue(withIdentifier: signupSegueIdentifier, sender: nil)
    }

    @IBAction func loginTouchUp(_ sender: Any) {
        guard let email = emailTextField.text else {
            // TODO: Handle nil email
            return
        }
        guard let password = passwordTextField.text else {
            // TODO: Handle nil password
            return
        }

        // TODO: Show loading animation
        let hud = LoadingHUD(self.view)
        usersDB.loginUser(withEmail: email, password: password) { (uid, error) in
            if let _ = error {
                // TODO: Handle error
                print(error.debugDescription)
                // TODO: End loading animation
                hud.end()
            } else {
                // TODO: End loading animation
                hud.end()
                self.view.endEditing(true)
                let storyBoard = UIStoryboard(name:"Main", bundle:nil)
                let tabBarViewController = storyBoard.instantiateViewController(withIdentifier: "mainTabBarViewController")
                guard let appDel = UIApplication.shared.delegate as? AppDelegate else { return }
                appDel.window?.rootViewController = tabBarViewController
            }
        }
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }

    @IBAction func unwindToVC(segue:UIStoryboardSegue) {

    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }

}
