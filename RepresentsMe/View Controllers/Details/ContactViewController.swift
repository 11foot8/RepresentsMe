//
//  ContactViewController.swift
//  RepresentsMe
//
//  Created by Benny Singer on 4/3/19.
//  Copyright © 2019 11foot8. All rights reserved.
//

import UIKit

class ContactViewController: UIViewController {
    @IBOutlet weak var contactTextView: UITextView!
    @IBOutlet weak var titleLabel: UILabel!

    var official:Official?
    var phones:[String] = []
    var urls:[URL?] = []
    var emails:[String] = []

    // Dynamically generate contact information based on what information is provided by the database
    override func viewWillAppear(_ animated: Bool) {
        guard let official = official else {
            contactTextView.text = "Sorry, this representative does not have any contact information available."
            return
        }
        titleLabel.text = "Contact \(official.name)"

        let contactString = buildContactString(title: "Phone number(s)", contacts: official.phones) +
            buildContactString(title: "Email address(es)", contacts: official.emails) +
            buildContactString(title: "Relevant Links", contacts: official.urls.map({ $0!.absoluteString }))

        contactTextView.text = contactString
    }

    func buildContactString(title: String, contacts:[String]) -> String {
        var contactString = ""
        if contacts.count > 0 {
            contactString.append("\(title):\n")
            for contact in contacts {
                contactString.append("\t\(contact)\n")
            }
            contactString.append("\n\n")
        }
        return contactString
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }
}

