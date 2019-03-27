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
    
    var passedOfficial:Official?
    var officialAddress:Address?
    
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
    }
    
    // Set the center of the MKMapView to the address of the selected official
    func setMapView() {
        let address = "\(officialAddress!.streetName), \(officialAddress!.city), \(officialAddress!.state) \(officialAddress!.zipcode)"
        
        print(address)
        
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
