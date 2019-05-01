//
//  LocationMapViewPopoverViewController.swift
//  RepresentsMe
//
//  Created by Jacob Hausmann on 5/1/19.
//  Copyright © 2019 11foot8. All rights reserved.
//

import UIKit
import MapKit

class LocationMapViewPopoverViewController: PopoverViewController {
    // MARK: - Properties
    var annotation:MKAnnotation?
    let regionInMeters:CLLocationDistance = 10000

    // MARK: - Outlets
    @IBOutlet var mapView: MKMapView!

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        if let _ = annotation {
            mapView.addAnnotation(annotation!)
            let region = MKCoordinateRegion(center: annotation!.coordinate, latitudinalMeters: regionInMeters, longitudinalMeters: regionInMeters)
            mapView.setRegion(region, animated: true)
        }
        self.view.layer.cornerRadius = 13.0
        self.view.clipsToBounds = true
        self.view.layer.borderWidth = 1.0
        self.view.layer.borderColor = UIColor.black.cgColor
    }

    // MARK: - Actions

    // MARK: - Methods
    func setPinInfo(location:CLLocationCoordinate2D, title:String, subtitle:String?) {
        if let _ = annotation, let _ = mapView {
            mapView.removeAnnotation(annotation!)
            annotation = nil
        }
        annotation = DroppedPin(title: title, locationName: subtitle ?? "", discipline: "", coordinate: location)
        if let _ = mapView {
            mapView.addAnnotation(annotation!)
        }
    }
}
