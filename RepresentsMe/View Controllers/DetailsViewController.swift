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
    @IBOutlet weak var officialName: UILabel!
    @IBOutlet weak var officialSeat: UILabel!
    @IBOutlet weak var officialParty: UILabel!
    @IBOutlet weak var officialPicture: UIImageView!
    @IBOutlet weak var officialLocation: MKMapView!
    @IBOutlet weak var scrollViewOutlet: UIScrollView!
    
    @IBOutlet weak var facebookButton: UIButton!
    @IBOutlet weak var twitterButton: UIButton!
    @IBOutlet weak var youtubeButton: UIButton!

    var passedOfficial:Official?
    var officialAddress:Address?
    var officialPhones:[String] = []
    var officialUrls:[URL?] = []
    var officialEmails:[String] = []
    var officialFB = ""
    var officialTwitter = ""
    var officialYT = ""
    
    override func viewWillAppear(_ animated: Bool) {
        officialName.text = passedOfficial?.name
        officialSeat.text = passedOfficial?.office
        officialParty.text = passedOfficial?.party.name
        if let passedPic = passedOfficial?.photo {
            officialPicture.image = passedPic
        }
        
        if (passedOfficial?.addresses.count)! < 1 {
            return
        }
        let address = passedOfficial?.addresses[0]
        
        officialAddress = Address(streetNumber: "",
                                  streetName: address!["line1"]!,
                                  city: address!["city"]!,
                                  state: address!["state"]!,
                                  zipcode: address!["zip"]!)
        setMapView()
        
        officialPhones = passedOfficial!.phones
        officialUrls = passedOfficial!.urls
        officialEmails = passedOfficial!.emails
        
        if let passedOfficial = passedOfficial {
            for dict in passedOfficial.socialMedia {
                if (officialFB == "" && dict["type"] == "Facebook") {
                    officialFB = dict["id"]!
                } else if (officialTwitter == "" && dict["type"] == "Twitter") {
                    officialTwitter = dict["id"]!
                } else if (officialYT == "" && dict["type"] == "YouTube") {
                    officialYT = dict["id"]!
                }
            }
        }

        if officialFB == "" {
            facebookButton.setTitleColor(.gray, for: .normal)
                facebookButton.isUserInteractionEnabled = false
        }

        if officialTwitter == "" {
            twitterButton.setTitleColor(.gray, for: .normal)
            twitterButton.isUserInteractionEnabled = false
        }

        if officialYT == "" {
            youtubeButton.setTitleColor(.gray, for: .normal)
            youtubeButton.isUserInteractionEnabled = false
        }
    }
    
    // Set the center of the MKMapView to the address of the selected official
    func setMapView() {
        let address = "\(officialAddress!.streetName), \(officialAddress!.city), \(officialAddress!.state) \(officialAddress!.zipcode)"
        
        let geoCoder = CLGeocoder()
        geoCoder.geocodeAddressString(address) { (placemarks, error) in
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
            
            self.officialLocation.setRegion(region, animated: true)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        scrollViewOutlet.contentSize = CGSize(width: self.view.frame.size.width, height: self.view.frame.size.height+100)
    }
    
    // Starts a call with the official based on the phone number provided in the
    // database
    @IBAction func callButtonPressed(_ sender: Any) {
        if officialPhones.count > 0 {
            guard let number = URL(string: "tel://" + officialPhones[0].filter("01234567890.".contains)) else { return }
            UIApplication.shared.open(number)
        }
    }
    
    // Opens up email app when email button is pressed. Does not work on simulator
    @IBAction func emailButtonPressed(_ sender: Any) {
        if officialEmails.count > 0 {
            if let url = URL(string: "mailto:\(officialEmails[0])") {
                if #available(iOS 10.0, *) {
                    UIApplication.shared.open(url)
                } else {
                    UIApplication.shared.openURL(url)
                }
            }
        }
    }
    
    // Takes user to a safari webpage related to the selected official
    @IBAction func websiteButtonPressed(_ sender: Any) {
        if officialUrls.count > 0 {
            UIApplication.shared.open(officialUrls[0]!, options: [:], completionHandler: nil)
        }
    }
    
    @IBAction func facebookButtonPressed(_ sender: Any) {
        if officialFB != "",
            let url = URL(string: "http://www.facebook.com/\(officialFB)") {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
    
    @IBAction func twitterButtonPressed(_ sender: Any) {
        if officialTwitter != "",
            let url = URL(string: "http://www.twitter.com/\(officialTwitter)") {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
    
    @IBAction func youtubeButtonPressed(_ sender: Any) {
        if officialYT != "",
            let url = URL(string: "http://www.youtube.com/\(officialYT)") {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
    
    let contactSegueIdentifier = "contactSegueIdentifier"
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == contactSegueIdentifier,
            let destination = segue.destination as? ContactViewController {
            destination.passedOfficial = passedOfficial
        }
    }
}

class ContactViewController: UIViewController {
    @IBOutlet weak var contactTextView: UITextView!
    @IBOutlet weak var titleLabel: UILabel!
    
    var passedOfficial:Official?
    var phones:[String] = []
    var urls:[URL?] = []
    var emails:[String] = []
    
    // Dynamically generate contact information based on what information is provided by the database
    override func viewWillAppear(_ animated: Bool) {
        guard let official = passedOfficial  else {
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
