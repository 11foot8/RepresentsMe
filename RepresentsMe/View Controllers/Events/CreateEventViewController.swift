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
let DATE_POPOVER_SEGUE = "datePopoverSegue"

class CreateEventViewController: UIViewController, UIPopoverPresentationControllerDelegate, OfficialSelectionDelegate, DatePopoverViewControllerDelegate {

    @IBOutlet weak var eventImageView: UIImageView!
    @IBOutlet weak var eventNameTextField: UITextField!
    @IBOutlet weak var eventLocationTextField: UITextField!
    @IBOutlet weak var selectOfficialButton: UIButton!
    @IBOutlet weak var selectDateButton: UIButton!

    var selectedDate: Date?
    var selectedOfficial:Official?

    override func viewDidLoad() {
        super.viewDidLoad()

        eventImageView.layer.cornerRadius = 5.0
        eventImageView.image = DEFAULT_NOT_LOADED
    }

    /// OfficialSelectionDelegate
    func didSelectOfficial(official: Official) {
        selectedOfficial = official
        eventImageView.image = official.photo
    }

    /// DatePopoverViewControllerDelegate
    func didSelectDate(date: Date) {
        selectedDate = date

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM d, h:mm a"
        selectDateButton.setTitle(dateFormatter.string(from: date), for: .normal)
    }

    @IBAction func saveTapped(_ sender: Any) {
        if selectedOfficial == nil || selectedOfficial == nil {
            return
        }
        
        GeocoderWrapper.geocodeAddressString(eventLocationTextField.text!) { (placemark: CLPlacemark) in
            let coordinate = placemark.location!.coordinate
            let name = self.eventNameTextField.text!

            let event = Event(name: name, owner: "", location: coordinate, date: self.selectedDate!, official: self.selectedOfficial!)

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

    /// UIPopoverPresentationControllerDelegate
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == SELECT_OFFICIAL_SEGUE) {
            let destination = segue.destination as! HomeViewController
            destination.reachType = .event
            destination.delegate = self
        } else if (segue.identifier == DATE_POPOVER_SEGUE) {
            let datePopoverViewController = segue.destination as! DatePopoverViewController
            datePopoverViewController.modalPresentationStyle = UIModalPresentationStyle.overFullScreen
            datePopoverViewController.popoverPresentationController?.delegate = self
                datePopoverViewController.delegate = self
            datePopoverViewController.popoverPresentationController?.sourceRect = CGRect(x: view.center.x, y: view.center.y, width: 0, height: 0)
            datePopoverViewController.popoverPresentationController?.sourceView = view
            datePopoverViewController.popoverPresentationController?.permittedArrowDirections = UIPopoverArrowDirection(rawValue: 0)
        }
    }

}
