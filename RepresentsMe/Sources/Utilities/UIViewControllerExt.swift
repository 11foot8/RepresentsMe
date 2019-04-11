//
//  UIViewControllerExt.swift
//  RepresentsMe
//
//  Created by Michael Tirtowidjojo on 4/11/19.
//  Copyright © 2019 11foot8. All rights reserved.
//

import UIKit

extension UIViewController {

    /// Presents an alert to the user
    ///
    /// - Parameter title:      the title of the alert.
    /// - Parameter message:    the message for the alert (default nil).
    func alert(title:String, message:String? = nil) {
        // Build the alert
        let alert = UIAlertController(
            title: title,
            message: message,
            preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        
        // Present the alert
        self.present(alert, animated: true, completion: nil)
    }
}
