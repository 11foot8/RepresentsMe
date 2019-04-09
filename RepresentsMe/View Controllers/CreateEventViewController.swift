//
//  CreateEventViewController.swift
//  RepresentsMe
//
//  Created by Benny Singer on 4/8/19.
//  Copyright © 2019 11foot8. All rights reserved.
//

import UIKit
import MapKit

let SELECT_OFFICIAL_SEGUE = "selectOfficialSegue"

class CreateEventViewController: UIViewController, OfficialSelectionDelegate {

    @IBOutlet weak var eventImageView: UIImageView!
    @IBOutlet weak var eventNameTextField: UITextField!
    @IBOutlet weak var eventLocationTextField: UITextField!
    @IBOutlet weak var eventDateTextField: UITextField!
    @IBOutlet weak var selectOfficialButton: UIButton!

    var selectedOfficial:Official?

    override func viewDidLoad() {
        super.viewDidLoad()

        eventImageView.layer.cornerRadius = 5.0
        eventImageView.image = DEFAULT_NOT_LOADED
    }

    func didSelectOfficial(official: Official) {
        selectedOfficial = official
        eventImageView.image = official.photo
    }

    @IBAction func saveTapped(_ sender: Any) {
        if selectedOfficial == nil {
            return
        }
        
        GeocoderWrapper.geocodeAddressString(eventLocationTextField.text!) { (placemark: CLPlacemark) in
            let coordinate = placemark.location!.coordinate
            let name = self.eventNameTextField.text!

            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MM/dd/yyyy"
            let date = dateFormatter.date(from: self.eventDateTextField.text!)

            let event = Event(name: name, owner: "SELF", location: coordinate, date: date!, official: self.selectedOfficial!)

            print(event.data)
        }

        dismiss(animated: true, completion: nil)
    }

    @IBAction func cancelTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }

    @IBAction func unwindToCreateEventViewController(segue: UIStoryboardSegue) {
        selectOfficialButton.isHidden = true
        selectOfficialButton.isUserInteractionEnabled = false
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == SELECT_OFFICIAL_SEGUE) {
            let destination = segue.destination as! HomeViewController
            destination.reachType = .event
            destination.delegate = self
        }
    }
}
