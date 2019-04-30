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

    /// Presents an alert to the user with completion handler
    ///
    /// - Parameter title:      the title of the alert.
    /// - Parameter message:    the message for the alert (default nil).
    /// - Parameter completion: code to execute when alert action is completed
    func alert(title:String, message: String? = nil, completion: @escaping () -> Void) {
        // Build the alert
        let alert = UIAlertController(
            title: title,
            message: message,
            preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
            completion()
        }))

        // Present the alert
        self.present(alert, animated: true, completion: completion)
    }
    
    /// Presents an alert specific to when an event is exported. Takes user to the
    /// calendar app if they so desire
    ///
    /// - Parameter date:      the date at which the exported event is taking place.
    func exportEventAlert(date: Date) {
        let interval = date.timeIntervalSinceReferenceDate
        let alert = UIAlertController(
            title: "Success",
            message: "The event has been exported to your calendar. Would you like to open up the calendar app?",
            preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: {(alert: UIAlertAction!) in
            UIApplication.shared.open(NSURL(string: "calshow:\(interval)")! as URL)
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        // Present the alert
        self.present(alert, animated: true)
    }
}
