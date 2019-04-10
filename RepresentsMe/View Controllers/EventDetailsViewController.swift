//
//  EventDetailsViewController.swift
//  RepresentsMe
//
//  Created by Varun Adiga on 4/9/19.
//  Copyright © 2019 11foot8. All rights reserved.
//

import Foundation
import UIKit
import MapKit

class EventDetailsViewController: UIViewController {
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var portraitImageView: UIImageView!
    @IBOutlet weak var eventNameLabel: UILabel!
    @IBOutlet weak var eventDateLabel: UILabel!
    @IBOutlet weak var eventLocationLabel: UILabel!

    var event:Event?

    override func viewWillAppear(_ animated: Bool) {
        if event == nil {
            return
        }

        if let eventPhoto = event!.official?.photo {
            portraitImageView.image = eventPhoto
        }

        eventNameLabel.text = event!.name

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM d, h:mm a"
        eventDateLabel.text = dateFormatter.string(from: event!.date)

        self.eventLocationLabel.text = ""
        GeocoderWrapper.reverseGeocodeCoordinates(event!.location) { (address: Address) in
            self.eventLocationLabel.text = address.description
        }

        let pLat = event!.location.latitude
        let pLong = event!.location.longitude
        let center = CLLocationCoordinate2D(latitude: pLat, longitude: pLong)

        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1))

        self.mapView.setRegion(region, animated: true)
    }
}
