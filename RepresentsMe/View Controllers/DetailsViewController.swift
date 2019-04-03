//
//  DetailsViewController.swift
//  RepresentsMe
//
//  Created by Varun Adiga on 3/2/19.
//  Copyright © 2019 11foot8. All rights reserved.
//

import Foundation
import UIKit
import MapKit

class DetailsViewController: UIViewController {
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var seatLabel: UILabel!
    @IBOutlet weak var partyLabel: UILabel!
    @IBOutlet weak var portraitImageView: UIImageView!
    @IBOutlet weak var officeLocationMapView: MKMapView!
    @IBOutlet weak var scrollViewOutlet: UIScrollView!
    
    @IBOutlet weak var phoneButton: UIButton!
    @IBOutlet weak var linkButton: UIButton!
    @IBOutlet weak var emailButton: UIButton!

    @IBOutlet weak var facebookButton: UIButton!
    @IBOutlet weak var twitterButton: UIButton!
    @IBOutlet weak var youtubeButton: UIButton!

    var official:Official?
    
    override func viewWillAppear(_ animated: Bool) {
        nameLabel.text = official?.name
        seatLabel.text = official?.office
        partyLabel.text = official?.party.name
        if let portrait = official?.photo {
            portraitImageView.image = portrait
        }
        
        if (official?.addresses.count)! < 1 {
            return
        }

        setMapView()

        if official?.facebookURL == nil {
            facebookButton.setTitleColor(.gray, for: .normal)
            facebookButton.isUserInteractionEnabled = false
        }

        if official?.twitterURL == nil {
            twitterButton.setTitleColor(.gray, for: .normal)
            twitterButton.isUserInteractionEnabled = false
        }

        if official?.youtubeURL == nil  {
            youtubeButton.setTitleColor(.gray, for: .normal)
            youtubeButton.isUserInteractionEnabled = false
        }

        if official?.phones == nil || official!.phones.count == 0 {
            phoneButton.setTitleColor(.gray, for: .normal)
            phoneButton.isUserInteractionEnabled = false
        }

        if official?.urls == nil || official?.urls.count == 0 {
            linkButton.setTitleColor(.gray, for: .normal)
            linkButton.isUserInteractionEnabled = false
        }

        if official?.emails == nil || official!.emails.count == 0 {
            emailButton.setTitleColor(.gray, for: .normal)
            emailButton.isUserInteractionEnabled = false
        }
    }
    
    // Set the center of the MKMapView to the address of the selected official
    func setMapView() {
        guard let addresses = official?.addresses, addresses.count > 0
            else {
                return
        }

        let address = official!.addresses[0]
        
        let geoCoder = CLGeocoder()
        geoCoder.geocodeAddressString(address.description) { (placemarks, error) in
            guard
                let placemarks = placemarks,
                let location = placemarks.first?.location
                else {
                    return
            }
            let pLat = location.coordinate.latitude
            let pLong = location.coordinate.longitude
            let center = CLLocationCoordinate2D(latitude: pLat, longitude: pLong)
            
            let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1))
            
            self.officeLocationMapView.setRegion(region, animated: true)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        scrollViewOutlet.contentSize = CGSize(width: self.view.frame.size.width, height:  self.view.frame.size.height+100)
    }
    
    // Starts a call with the official based on the phone number provided in the
    // database
    @IBAction func callButtonPressed(_ sender: Any) {
        if let phoneNumber = URL(string: "tel://\(official!.phones[0])") {
            UIApplication.shared.open(phoneNumber)
        }
    }
    
    // Opens up email app when email button is pressed. Does not work on simulator
    @IBAction func emailButtonPressed(_ sender: Any) {
        if let email = URL(string: "mailto:\(official!.emails[0])") {
            UIApplication.shared.open(email)
        }
    }
    
    // Takes user to a safari webpage related to the selected official
    @IBAction func websiteButtonPressed(_ sender: Any) {
        if let url = official!.urls[0] {
            UIApplication.shared.open(url)
        }
    }
    
    @IBAction func facebookButtonPressed(_ sender: Any) {
        UIApplication.shared.open(official!.facebookURL!)
    }
    
    @IBAction func twitterButtonPressed(_ sender: Any) {
        UIApplication.shared.open(official!.twitterURL!)
    }
    
    @IBAction func youtubeButtonPressed(_ sender: Any) {
        UIApplication.shared.open(official!.youtubeURL!)
    }
    
    let contactSegueIdentifier = "contactSegueIdentifier"
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == contactSegueIdentifier,
            let destination = segue.destination as? ContactViewController {
            destination.official = official
        }
    }
}

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
