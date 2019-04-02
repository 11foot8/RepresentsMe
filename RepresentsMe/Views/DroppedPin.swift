//
//  DroppedPin.swift
//  RepresentsMe
//
//  Created by Jacob Hausmann on 4/1/19.
//  Copyright © 2019 11foot8. All rights reserved.
//

import UIKit
import MapKit

class DroppedPin: NSObject, MKAnnotation {
    let title: String?
    let locationName: String
    let discipline: String
    let coordinate: CLLocationCoordinate2D

    init(title: String, locationName: String, discipline: String, coordinate: CLLocationCoordinate2D) {
        self.title = title
        self.locationName = locationName
        self.discipline = discipline
        self.coordinate = coordinate

        super.init()
    }

    var subtitle: String? {
        return locationName
    }
}
