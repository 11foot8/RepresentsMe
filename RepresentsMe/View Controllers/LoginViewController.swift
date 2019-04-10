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

        UsersDatabase.shared.loginUser(withEmail: email, password: password) { (uid, error) in
            if let _ = error {
                // TODO: Handle error
                print(error.debugDescription)
            } else {
                self.view.endEditing(true)
                let storyBoard = UIStoryboard(name:"Main", bundle:nil)
                let tabBarViewController = storyBoard.instantiateViewController(withIdentifier: "mainTabBarViewController")
                guard let appDel = UIApplication.shared.delegate as? AppDelegate else { return }
                appDel.window?.rootViewController = tabBarViewController
            }
        }
        
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
}
