//
//  AppState.swift
//  RepresentsMe
//
//  Created by Michael Tirtowidjojo on 4/9/19.
//  Copyright © 2019 11foot8. All rights reserved.
//

import Foundation
import UIKit

protocol AppStateListener {
    func appStateReceivedHomeOfficials(officials: [Official])
    func appStateReceivedSandboxOfficials(officials: [Official])
}

enum AddressType {
    case home
    case sandbox
}

class AppState {
    static var homeAddress:Address? {
        didSet {
            if let address = homeAddress {
                loadOfficials(address: address, type: .home)
            }
        }
    }    /// The Officials for the user's home address
    static var homeOfficials:[Official] = []

    /// The currently selected sandbox Address
    static var sandboxAddress:Address? {
        didSet {
            if let address = sandboxAddress {
                loadOfficials(address: address, type: .sandbox)
            }
        }
    }

    /// The Officials for the user's selected address
    static var sandboxOfficials:[Official] = []

    private static var homeAddressListeners: [AppStateListener] = []

    static func addHomeAddressListener(listener: AppStateListener) {
        homeAddressListeners.append(listener)
    }

    static func removeHomeAddressListener(listener: AppStateListener) {
        homeAddressListeners.removeAll { (appStateListener: AppStateListener) -> Bool in
            if let listener1 = listener as? UIViewController,
                let listener2 = appStateListener as? UIViewController {
                return listener1 === listener2
            }
            // should never occur
            return false
        }
    }

    private static var sandboxAddressListeners: [AppStateListener] = []

    static func addSandboxAddressListener(listener: AppStateListener) {
        sandboxAddressListeners.append(listener)
    }
    
    static func removeSandboxAddressListener(listener: AppStateListener) {
        sandboxAddressListeners.removeAll { (appStateListener: AppStateListener) -> Bool in
            if let listener1 = listener as? UIViewController,
                let listener2 = appStateListener as? UIViewController {
                return listener1 === listener2
            }
            // should never occur
            return false
        }
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

    static func loadOfficials(address: Address, type: AddressType) {
        OfficialScraper.getForAddress(address: address, apikey: civic_api_key, completion: { (officials: [Official]?, error: ParserError?) in
            if error != nil {
                // TODO: Handle error
            }

            if let officials = officials {
                switch type {
                case .home:
                    homeOfficials = officials
                    for listener in homeAddressListeners {
                        listener.appStateReceivedHomeOfficials(officials: homeOfficials)
                    }
                    break
                case .sandbox:
                    sandboxOfficials = officials
                    for listener in sandboxAddressListeners {
                        listener.appStateReceivedSandboxOfficials(officials: sandboxOfficials)
                    }
                    break
                }
            }
        })
    }
}
