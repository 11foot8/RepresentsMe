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
        phones = official.phones
        urls = official.urls
        emails = official.emails
        var contactString = ""
        if phones.count > 0 {
            contactString.append("Phone number(s):\n")
            for phone in phones {
                contactString.append("\t\(phone)\n")
            }
            contactString.append("\n\n")
        }
        if emails.count > 0 {
            contactString.append("Email address(es):\n")
            for email in emails {
                contactString.append("\t\(email)\n")
            }
            contactString.append("\n\n")
        }
        if urls.count > 0 {
            contactString.append("Relevant Links:\n")
            for url in urls {
                if let safeUrl = url {
                    contactString.append("\t\(safeUrl)\n")
                }
            }
        }
        contactTextView.text = contactString
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }
}

