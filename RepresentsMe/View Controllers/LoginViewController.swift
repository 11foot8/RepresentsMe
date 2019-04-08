//
//  LoginViewController.swift
//  RepresentsMe
//
//  Created by Jacob Hausmann on 4/2/19.
//  Copyright © 2019 11foot8. All rights reserved.
//

import UIKit
import Firebase

class LoginViewController: UIViewController {
    // MARK: - Properties
    let usersDB = UsersDatabase.getInstance()

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    // MARK: - Outlets
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!


    // MARK: - Actions
    @IBAction func cancelTouchUp(_ sender: Any) {
        performSegue(withIdentifier: "LoginUnwindSegue", sender: self)
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

        usersDB.loginUser(withEmail: email, password: password) { (uid, error) in
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
}
