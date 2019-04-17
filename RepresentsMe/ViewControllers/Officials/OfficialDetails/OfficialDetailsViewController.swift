//
//  OfficialDetailsViewController.swift
//  RepresentsMe
//
//  Created by Varun Adiga on 3/2/19.
//  Copyright © 2019 11foot8. All rights reserved.
//

import UIKit
import MapKit
import MessageUI

// OfficialDetailsViewController -> OfficialContactViewController
let OFFICIAL_CONTACT_SEGUE_IDENTIFIER = "contactSegueIdentifier"

/// The view controller to show the details for an Official
class OfficialDetailsViewController: UIViewController {
    
    var official:Official?
    
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

    /// Set the scroll view content size
    override func viewDidLoad() {
        super.viewDidLoad()
        scrollViewOutlet.contentSize = CGSize(
            width: self.view.frame.size.width,
            height: self.view.frame.size.height + 100)
    }
    
    /// Sets up the view for the Official
    override func viewWillAppear(_ animated: Bool) {
        self.setLabels()
        self.setPortrait()
        self.setMapView()
        self.disableUnavailableButtons()
    }

    /// Starts a call with the official based on the phone number provided in
    /// the database
    @IBAction func callButtonPressed(_ sender: Any) {
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "Call", style: .default, handler: { (action: UIAlertAction) in
            if let phoneNumber = URL(string: "tel://\(self.official!.phones[0])") {
                UIApplication.shared.open(phoneNumber)
            }
        }))
        actionSheet.addAction(UIAlertAction(title: "Text", style: .default, handler: { (action: UIAlertAction) in
            let composeVC = MFMessageComposeViewController()

            // Configure the fields of the interface.
            composeVC.recipients = self.official?.phones

            // Present the view controller modally.
            self.present(composeVC, animated: true, completion: nil)
        }))
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action: UIAlertAction) in
            actionSheet.dismiss(animated: true, completion: nil)
        }))

        self.present(actionSheet, animated: true, completion: nil)
    }

    /// Opens up email app when email button is pressed.
    /// Does not work on simulator
    @IBAction func emailButtonPressed(_ sender: Any) {
        if let email = URL(string: "mailto:\(official!.emails[0])") {
            UIApplication.shared.open(email)
        }
    }

    /// Takes user to a safari webpage related to the selected official
    @IBAction func websiteButtonPressed(_ sender: Any) {
        if let url = official!.urls[0] {
            UIApplication.shared.open(url)
        }
    }

    /// Takes the user to a safari webpage for the official's facebook
    @IBAction func facebookButtonPressed(_ sender: Any) {
        UIApplication.shared.open(official!.facebookURL!)
    }

    /// Takes the user to a safari webpage for the official's twitter
    @IBAction func twitterButtonPressed(_ sender: Any) {
        UIApplication.shared.open(official!.twitterURL!)
    }

    /// Takes the user to a safari webpage for the official's youtube
    @IBAction func youtubeButtonPressed(_ sender: Any) {
        UIApplication.shared.open(official!.youtubeURL!)
    }

    /// Prepare to segue to the contacts view for the Official
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == OFFICIAL_CONTACT_SEGUE_IDENTIFIER,
            let destination = segue.destination as? OfficialContactViewController {
            destination.official = official
        }
    }
    
    /// Sets the labels for the Official
    private func setLabels() {
        if let official = self.official {
            nameLabel.text = official.name
            seatLabel.text = official.office
            partyLabel.text = official.party.name
        }
    }
    
    /// Sets the portrait for the Official
    private func setPortrait() {
        if let official = self.official, let portrait = official.photo {
            portraitImageView.image = portrait
        }
    }
    
    /// Centers the map view on the Official's Address
    private func setMapView() {
        if let official = self.official,
            let address = official.addresses.first {
            
            // Geocode the address and center the map on it
            CLGeocoder().geocodeAddressString(
                address.description) {(placemarks, error) in
                    
                if error == nil,
                    let placemarks = placemarks,
                    let location = placemarks.first?.location {
                    
                    // Center the map on the placemark
                    let span = MKCoordinateSpan(latitudeDelta: 0.1,
                                                longitudeDelta: 0.1)
                    let region = MKCoordinateRegion(
                        center: location.coordinate, span: span)
                    self.officeLocationMapView.setRegion(region,
                                                         animated: true)
                }
            }
        }
    }
    
    /// Disables any buttons that are unavailable for the Official
    private func disableUnavailableButtons() {
        if let official = self.official {
            self.disableIfUnavailable(obj: official.facebookURL,
                                      button: self.facebookButton)
            self.disableIfUnavailable(obj: official.twitterURL,
                                      button: self.twitterButton)
            self.disableIfUnavailable(obj: official.youtubeURL,
                                      button: self.youtubeButton)
            self.disableIfUnavailable(items: official.phones,
                                      button: self.phoneButton)
            self.disableIfUnavailable(items: official.emails,
                                      button: self.emailButton)
            self.disableIfUnavailable(items: official.urls,
                                      button: self.linkButton)
        }
    }
    
    /// Disables the given button if the object is nil
    ///
    /// - Parameter obj:        the object to check
    /// - Parameter button:     the button to disable
    private func disableIfUnavailable(obj:Any?, button:UIButton) {
        if obj == nil {
            self.disable(button: button)
        }
    }
    
    /// Disables the given button if the Array given is empty
    ///
    /// - Parameter items:      the Array to check
    /// - Parameter button:     the button to disable
    private func disableIfUnavailable(items:[Any?], button:UIButton) {
        if items.isEmpty {
            self.disable(button: button)
        }
    }
    
    /// Disables the given button
    ///
    /// - Parameter button:     the UIButton to disable
    private func disable(button:UIButton) {
        button.setTitleColor(.gray, for: .normal)
        button.isUserInteractionEnabled = false
    }
}
