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

    override func viewDidLoad() {
        super.viewDidLoad()
        scrollViewOutlet.contentSize = CGSize(width: self.view.frame.size.width, height:  self.view.frame.size.height+100)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        nameLabel.text = official?.name
        seatLabel.text = official?.office
        partyLabel.text = official?.party.name
        if let portrait = official?.photo {
            portraitImageView.image = portrait
        }
        
        if official?.addresses != nil && official!.addresses.count >= 1 {
            setMapView()
        }

        if official?.facebookURL == nil {
            disableButton(button: facebookButton)
        }

        if official?.twitterURL == nil {
            disableButton(button: twitterButton)
        }

        if official?.youtubeURL == nil  {
            disableButton(button: youtubeButton)
        }

        if official?.phones.count == nil || official!.phones.count == 0 {
            disableButton(button: phoneButton)
        }

        if official?.urls == nil || official?.urls.count == 0 {
            disableButton(button: linkButton)
        }

        if official?.emails == nil || official!.emails.count == 0 {
            disableButton(button: emailButton)
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

    func disableButton(button: UIButton) {
        button.setTitleColor(.gray, for: .normal)
        button.isUserInteractionEnabled = false
    }
    
    // Starts a call with the official based on the phone number provided in the
    // database
    @IBAction func callButtonPressed(_ sender: Any) {
        let sanitizedPhoneNumber = official!.phones[0]
            .components(separatedBy: CharacterSet.decimalDigits.inverted)
            .joined(separator: "")
        if let phoneNumber = URL(string: "tel://\(sanitizedPhoneNumber)") {
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
