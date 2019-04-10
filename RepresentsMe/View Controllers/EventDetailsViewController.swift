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


}
