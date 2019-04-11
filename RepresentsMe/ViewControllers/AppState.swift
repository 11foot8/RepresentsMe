//
//  AppState.swift
//  RepresentsMe
//
//  Created by Michael Tirtowidjojo on 4/9/19.
//  Copyright © 2019 11foot8. All rights reserved.
//

import Foundation
import UIKit

/// The protocol to implement to be notified when the home Officials or
/// sandbox Officials change.
protocol AppStateListener {
    func appStateReceivedHomeOfficials(officials: [Official])
    func appStateReceivedSandboxOfficials(officials: [Official])
}

/// Manages the Officials for the app.
/// Keeps track of the list of Officials for the user's home address and the
/// list of Officials for the user's chosen sandbox address.
/// Handles notifying AppStateListeners when either list of Officials changes.
/// New home Officials and new sandbox Officials can be scraped by setting
/// the home Address and sandbox Address respectively.
class AppState {
    
    /// The Address for Officials in homeOfficials
    static var homeAddress:Address? {
        didSet {
            if let address = homeAddress {
                loadOfficials(address: address) {(officials) in
                    homeOfficials = officials
                    for listener in homeAddressListeners {
                        listener.appStateReceivedHomeOfficials(
                            officials: homeOfficials)
                    }
                }
            }
        }
    }
    
    /// The Officials for the user's home address
    static var homeOfficials:[Official] = []

    /// The Address for Officials in sandboxOfficials
    static var sandboxAddress:Address? {
        didSet {
            if let address = sandboxAddress {
                loadOfficials(address: address) {(officials) in
                    sandboxOfficials = officials
                    for listener in sandboxAddressListeners {
                        listener.appStateReceivedSandboxOfficials(
                            officials: sandboxOfficials)
                    }
                }
            }
        }
    }

    /// The Officials for the user's selected address
    static var sandboxOfficials:[Official] = []

    /// The listeners for home address changes
    private static var homeAddressListeners: [AppStateListener] = []
    
    /// The listeners for sandbox address changes
    private static var sandboxAddressListeners:[AppStateListener] = []

    /// Adds a listener for changes in the home address
    ///
    /// - Parameter listener:   the AppStateListener to add
    static func addHomeAddressListener(_ listener:AppStateListener) {
        homeAddressListeners.append(listener)
    }

    /// Removes a listener for changes in the home address
    ///
    /// - Parameter listener:   the AppStateListener to remove
    static func removeHomeAddressListener(_ listener: AppStateListener) {
        if let index = find(listener: listener, in: homeAddressListeners) {
            homeAddressListeners.remove(at: index)
        }
    }

    /// Adds a listener for changes in the sandbox address
    ///
    /// - Parameter listener:   the AppStateListener to add
    static func addSandboxAddressListener(_ listener: AppStateListener) {
        sandboxAddressListeners.append(listener)
    }
    
    /// Removes a listener for changes in the sandbox address
    ///
    /// - Parameter listener:   the AppStateListener to remove
    static func removeSandboxAddressListener(_ listener: AppStateListener) {
        if let index = find(listener: listener, in: sandboxAddressListeners) {
            sandboxAddressListeners.remove(at: index)
        }
    }

    /// Initializes the home Officials with the current user's home Address
    static func setup() {
        UsersDatabase.getCurrentUserAddress {(address, error) in
            if error != nil {
                // TODO: Handle error
            } else {
                if let address = address {
                    homeAddress = address
                }
            }
        }
    }

    /// Loads the Officials for the given Address
    ///
    /// - Parameter address:        the Address to load for
    /// - Parameter completion:     the completion handler
    private static func loadOfficials(
        address: Address,
        completion: @escaping ([Official]) -> ()) {
        
        OfficialScraper.getForAddress(
        address: address, apikey: civic_api_key) {(officials, error) in
            if error != nil {
                // TODO: Handle error
            } else {
                return completion(officials)
            }
        }
    }
    
    /// Finds the given listener in the given Array of listeners
    ///
    /// - Parameter listener:   the listener to search for
    /// - Parameter in:         the Array to search
    ///
    /// - Returns: the index if found or nil if not found
    private static func find(listener:AppStateListener,
                             in listeners:[AppStateListener]) -> Int? {
        return listeners.firstIndex {(appStateListener) in
            if let listener1 = listener as? UIViewController,
                let listener2 = appStateListener as? UIViewController {
                return listener1 === listener2
            }
            
            // should never occur
            return false
        }
    }
}
