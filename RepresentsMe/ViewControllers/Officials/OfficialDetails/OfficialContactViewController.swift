//
//  OfficialContactViewController.swift
//  RepresentsMe
//
//  Created by Benny Singer on 4/3/19.
//  Copyright © 2019 11foot8. All rights reserved.
//

import UIKit

/// The view controller to show additional contacts for an Official
class OfficialContactViewController: UIViewController {

    var official:Official?
    
    @IBOutlet weak var contactTextView: UITextView!
    @IBOutlet weak var titleLabel: UILabel!

    /// Dynamically generate contact information based on what information is
    /// provided by the database
    override func viewWillAppear(_ animated: Bool) {
        if let official = self.official {
            titleLabel.text = "Contact \(official.name)"
            
            // Build the text
            contactTextView.text =
                buildContactString(
                    title: "Phone number(s)",
                    contacts: official.phones) +
                buildContactString(
                    title: "Email address(es)",
                    contacts: official.emails) +
                buildContactString(
                    title: "Relevant Links",
                    contacts: official.urls.map({ $0!.absoluteString }))
        } else {
            contactTextView.text = "Sorry, this representative does not " +
                                   "have any contact information available."
        }
    }

    /// Builds the contact string for the given contacts
    ///
    /// - Parameter title:      the name of the contacts
    /// - Parameter contacts:   the contacts
    ///
    /// - Returns: the contacts string
    func buildContactString(title: String, contacts:[String]) -> String {
        var contactString = ""
        if !contacts.isEmpty {
            contactString.append("\(title):\n")
            for contact in contacts {
                contactString.append("\t\(contact)\n")
            }
            contactString.append("\n\n")
        }
        
        return contactString
    }
}

