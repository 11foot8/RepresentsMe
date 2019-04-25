//
//  LocationInfo.swift
//  RepresentsMe
//
//  Created by Jacob Hausmann on 4/1/19.
//  Copyright © 2019 11foot8. All rights reserved.
//

import UIKit
import MapKit
import NVActivityIndicatorView

protocol LocationInfoDelegate {
    func goButtonPressed(address:Address)
}


class LocationInfo: UIView {

    // MARK: - Properties
    var delegate:LocationInfoDelegate?
    var address:Address?
    var workItem:DispatchWorkItem? = nil

    // MARK: - Outlets
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var goButton: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var address1Label: UILabel!
    @IBOutlet weak var address2Label: UILabel!
    @IBOutlet weak var activityIndicator: NVActivityIndicatorView!

    // MARK: - Actions
    @IBAction func goButtonTouchUp(_ sender: Any) {
        guard delegate != nil else { return }
        delegate?.goButtonPressed(address: address!)
    }


    // MARK: - Lifecycle
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initSubviews()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        initSubviews()
    }

    func initSubviews() {
        let nib = UINib(nibName: "LocationInfo", bundle: nil)
        nib.instantiate(withOwner: self, options: nil)
        self.layer.cornerRadius = 18
        self.clipsToBounds = true
        self.layer.borderWidth = 1.0
        self.layer.borderColor = UIColor.lightGray.cgColor
        contentView.frame = bounds
        addSubview(contentView)

        contentView.layer.cornerRadius = 18
        contentView.clipsToBounds = true

        goButton.layer.cornerRadius = 10
        goButton.clipsToBounds = true

        activityIndicator.isHidden = true
    }


    /// Reverse geocodes the given location.
    /// Upon successful reverse geocode, sets locationInfoView correctly
    func updateWithCoordinates(coords:CLLocationCoordinate2D, title:String) {
        startLoadingAnimation()
        titleLabel.text = title
        GeocoderWrapper.reverseGeocodeCoordinates(coords, completionHandler: reverseGeocodeCompletionHandler)
    }

    func updateWith(address:Address, title: String) {
        self.address = address
        self.address1Label.text = address.addressLine1()
        self.address2Label.text = address.addressLine2()
        titleLabel.text = title
        self.goButton.isEnabled = true
    }

    func reverseGeocodeCompletionHandler(address:Address) {
        self.address = address
        // In UI thread, set title of address button and enable go button
        self.address1Label.text = address.addressLine1()
        self.address2Label.text = address.addressLine2()
        self.goButton.isEnabled = true
        stopLoadingAnimation()
    }

    func startLoadingAnimation() {
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
        goButton.isEnabled = false
        goButton.isHidden = true
        titleLabel.isHidden = true
        address1Label.isHidden = true
        address2Label.isHidden = true
    }

    func stopLoadingAnimation() {
        activityIndicator.isHidden = true
        activityIndicator.stopAnimating()
        goButton.isEnabled = true
        goButton.isHidden = false
        titleLabel.isHidden = false
        address1Label.isHidden = false
        address2Label.isHidden = false

    }
}

class LocationInfoItem {
    public enum LocationInfoError:Error, LocalizedError {
        case addressGeocodeError
        public var errorDescription: String? {
            switch self {
            case .addressGeocodeError:
                return NSLocalizedString("Error Geocoding Address", comment: "")
            }
        }

    }
    private(set) var coordinates:CLLocationCoordinate2D?
    private(set) var searchRequest:MKLocalSearch.Request?
    private(set) var address:Address?
    private(set) var title:String?

    init(title:String?, coordinates: CLLocationCoordinate2D) {
        self.title = title
        self.coordinates = coordinates
    }

    init(title:String?, searchRequest:MKLocalSearch.Request) {
        self.title = title
        self.searchRequest = searchRequest
    }

    init(title:String?, address:Address) {
        self.title = title
        self.address = address
    }

    func getLocationInfo(completion:@escaping (String?, CLLocationCoordinate2D? ,Address?, Error?) -> Void) {
        // If coordiantes provided, reverse geocode
        if let coordinates = coordinates {
            GeocoderWrapper.reverseGeocodeCoordinates(coordinates) { (address) in
                completion(nil,coordinates, address, nil)
                return
            }
            return
        }

        // If address provided, geocode
        if let address = address {
            GeocoderWrapper.geocodeAddressString(address.description) { (placemark) in
                if let coordinates = placemark.location?.coordinate {
                    completion(nil,coordinates,address, nil)
                } else {
                    completion(nil,nil,nil,LocationInfoError.addressGeocodeError)
                }
            }
            return
        }

        // If searchRequest provided, MKLocalSearch
        if let searchRequest = searchRequest {
            let search = MKLocalSearch(request: searchRequest)
            search.start { (response, error) in
                if let _ = error {
                    // TODO: Handle error
                } else {
                    if let mapItem = response?.mapItems[0] {
                        let title:String = self.title ?? mapItem.name!
                        let coords = mapItem.placemark.location!.coordinate
                        let address = Address(with: mapItem.placemark)
                        completion(title, coords,address,nil)
                    } else {
                        completion(nil,nil,nil,LocationInfoError.addressGeocodeError)
                    }
                }
            }
            return
        }
    }
}
