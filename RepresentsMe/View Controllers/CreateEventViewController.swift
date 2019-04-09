//
//  CreateEventViewController.swift
//  RepresentsMe
//
//  Created by Benny Singer on 4/8/19.
//  Copyright © 2019 11foot8. All rights reserved.
//

import UIKit
import MapKit

class CreateEventViewController: UIViewController {

    @IBOutlet weak var eventImageView: UIImageView!

    @IBOutlet weak var eventNameTextField: UITextField!

    @IBOutlet weak var eventLocationTextField: UITextField!

    @IBOutlet weak var eventDateTextField: UITextField!

    @IBOutlet weak var eventDescriptionTextView: UITextView!


    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    @IBAction func saveTapped(_ sender: Any) {
        GeocoderWrapper.geocodeAddressString(eventLocationTextField.text!) { (placemark: CLPlacemark) in
            let coordinate = placemark.location!.coordinate
            let name = self.eventNameTextField.text!

            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MM/dd/yyyy"
            let date = dateFormatter.date(from: self.eventDateTextField.text!)

            let event = Event(name: name, owner: "SELF", location: coordinate, date: date!, official: Official())

            print(event.data)

//            event.save(completion: { (event: Event, error: Error?) in
//
//            })
        }

        dismiss(animated: true, completion: nil)
    }

    @IBAction func cancelTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }

}
