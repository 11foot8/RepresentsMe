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
    
    @IBOutlet weak var facebookButton: UIButton!
    @IBOutlet weak var twitterButton: UIButton!
    @IBOutlet weak var youtubeButton: UIButton!

    var passedOfficial:Official?
    var officialAddress:Address?
    var officialPhones:[String] = []
    var officialUrls:[URL?] = []
    var officialEmails:[String] = []
    
    override func viewWillAppear(_ animated: Bool) {
        nameLabel.text = passedOfficial?.name
        seatLabel.text = passedOfficial?.office
        partyLabel.text = passedOfficial?.party.name
        if let portrait = passedOfficial?.photo {
            portraitImageView.image = portrait
        }
        
        if (passedOfficial?.addresses.count)! < 1 {
            return
        }
        officialAddress = passedOfficial?.addresses[0]

        setMapView()
        
        officialPhones = passedOfficial!.phones
        officialUrls = passedOfficial!.urls
        officialEmails = passedOfficial!.emails

        if passedOfficial?.facebookURL == nil {
            facebookButton.setTitleColor(.gray, for: .normal)
            facebookButton.isUserInteractionEnabled = false
        }

        if passedOfficial?.twitterURL == nil {
            twitterButton.setTitleColor(.gray, for: .normal)
            twitterButton.isUserInteractionEnabled = false
        }

        if passedOfficial?.youtubeURL == nil  {
            youtubeButton.setTitleColor(.gray, for: .normal)
            youtubeButton.isUserInteractionEnabled = false
        }

        // TODO: gray out email, phone, and link buttons like social media buttons
    }
    
    // Set the center of the MKMapView to the address of the selected official
    func setMapView() {
        let address = officialAddress!.description
        
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
            
            self.officeLocationMapView.setRegion(region, animated: true)
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
                UIApplication.shared.open(url)
            }
        }
    }
    
    // Takes user to a safari webpage related to the selected official
    @IBAction func websiteButtonPressed(_ sender: Any) {
        if officialUrls.count > 0 {
            UIApplication.shared.open(officialUrls[0]!)
        }
    }
    
    @IBAction func facebookButtonPressed(_ sender: Any) {
        UIApplication.shared.open(passedOfficial!.facebookURL!)
    }
    
    @IBAction func twitterButtonPressed(_ sender: Any) {
        UIApplication.shared.open(passedOfficial!.twitterURL!)
    }
    
    @IBAction func youtubeButtonPressed(_ sender: Any) {
        UIApplication.shared.open(passedOfficial!.youtubeURL!)
    }
    
    let contactSegueIdentifier = "contactSegueIdentifier"
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == contactSegueIdentifier,
            let destination = segue.destination as? ContactViewController {
            destination.official = passedOfficial
        }
    }
}
