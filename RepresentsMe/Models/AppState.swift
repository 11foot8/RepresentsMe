//
//  AppState.swift
//  RepresentsMe
//
//  Created by Michael Tirtowidjojo on 4/9/19.
//  Copyright © 2019 11foot8. All rights reserved.
//

import Foundation

protocol AppStateListener {
    func appStateReceivedHomeOfficials(officials: [Official])
}

class AppState {
    /// The Officials for the user's home address
    static var homeOfficials:[Official] = []

    /// The Officials for the user's selected address
    static var sandboxOfficials:[Official] = []

    /// The currently selected sandbox Address
    static var sandboxAddress:Address?

    static var homeAddress:Address? {
        didSet {
            if let address = homeAddress {
                loadOfficials(address: address)
            }
        }
    }

    private static var listeners: [AppStateListener] = []

    static func addListener(listener: AppStateListener) {
        listeners.append(listener)
    }

    static func setup() {
        UsersDatabase.getCurrentUserAddress { (address: Address?, error: Error?) in
            if error != nil {
                // TODO: Handle error
                return
            }

            if let address = address {
                homeAddress = address
            }
        }
    }

    static func loadOfficials(address: Address) {
        OfficialScraper.getForAddress(address: address, apikey: civic_api_key, completion: { (officials: [Official]?, error: ParserError?) in
            if error != nil {
                // TODO: Handle error
            }

            if let officials = officials {
                homeOfficials = officials
                for listener in listeners {
                    listener.appStateReceivedHomeOfficials(officials: self.homeOfficials)
                }

            }
        })
    }
}
