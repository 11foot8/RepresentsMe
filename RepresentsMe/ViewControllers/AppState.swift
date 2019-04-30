//
//  AppState.swift
//  RepresentsMe
//
//  Created by Michael Tirtowidjojo on 4/9/19.
//  Copyright © 2019 11foot8. All rights reserved.
//

import Foundation
import UIKit
import Firebase

/// The protocol to implement to be notified when the home Officials or
/// sandbox Officials change.
protocol OfficialsListener {
    func appStateReceivedHomeOfficials(officials: [Official])
    func appStateReceivedSandboxOfficials(officials: [Official])
}

/// The protocol to implement to be notified when home, an Official, or
/// a User's Events change
protocol EventsListener {
    func appStateReceivedHomeEvents(events:[Event])
    func appStateReceivedOfficialEvents(events:[Event])
    func appStateReceivedUserEvents(events:[Event])
}

/// Manages the Officials for the app.
/// Keeps track of the list of Officials for the user's home address and the
/// list of Officials for the user's chosen sandbox address.
/// Handles notifying AppStateListeners when either list of Officials changes.
/// New home Officials and new sandbox Officials can be scraped by setting
/// the home Address and sandbox Address respectively.
class AppState {

    /// Cache of downloaded images, associated either with their URL or UID
    static var imageCache = NSCache<NSString, UIImage>()
    
    /// The Address for Officials in homeOfficials
    static var homeAddress:Address? {
        didSet {
            if let address = homeAddress {
                loadOfficials(address: address) {(officials) in
                    // Set the Officials and notify listeners
                    homeOfficials = officials
                    for listener in homeAddressListeners {
                        listener.appStateReceivedHomeOfficials(
                            officials: homeOfficials)
                    }
                    
                    // Load the Events
                    loadHomeEvents {(events) in
                        // Set the Events and notify listeners
                        homeEvents = events
                        for listener in homeEventsListeners {
                            listener.appStateReceivedHomeEvents(
                                events: homeEvents)
                        }
                    }
                }
            }
        }
    }

    /// The User's Profile Picture
    static var profilePicture:UIImage = DEFAULT_NOT_LOADED
    
    /// The Officials for the user's home address
    static var homeOfficials:[Official] = []
    
    /// The Events for the user's home address
    static var homeEvents:[Event] = []

    /// The Events for an Official
    static var officialEvents:[Event] = []

    /// The Official for Events in officialEvents
    static var official:Official? {
        didSet {
            if official != nil {
                loadOfficialEvents { (events) in
                    officialEvents = events
                    for listener in officialEventsListeners {
                        listener.appStateReceivedOfficialEvents(
                            events: officialEvents)
                    }
                }
            }
        }
    }

    /// The Events for a User
    static var userEvents:[Event] = []

    /// The Official for Events in officialEvents
    static var userId:String? {
        didSet {
            if userId != nil {
                loadUserEvents { (events) in
                    userEvents = events
                    for listener in userEventsListeners {
                        listener.appStateReceivedUserEvents(
                            events: officialEvents)
                    }
                }
            }
        }
    }


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
    private static var homeAddressListeners: [OfficialsListener] = []
    
    /// The listeners for home Event changes
    private static var homeEventsListeners: [EventsListener] = []

    /// The listeners for Officials' Event changes
    private static var officialEventsListeners: [EventsListener] = []

    /// The listeners for a User's Event changes
    private static var userEventsListeners: [EventsListener] = []
    
    /// The listeners for sandbox address changes
    private static var sandboxAddressListeners:[OfficialsListener] = []

    /// Adds a listener for changes in the home address
    ///
    /// - Parameter listener:   the OfficialsListener to add
    static func addHomeAddressListener(_ listener:OfficialsListener) {
        homeAddressListeners.append(listener)
    }

    /// Removes a listener for changes in the home address
    ///
    /// - Parameter listener:   the OfficialsListener to remove
    static func removeHomeAddressListener(_ listener: OfficialsListener) {
        if let index = find(listener: listener, in: homeAddressListeners) {
            homeAddressListeners.remove(at: index)
        }
    }

    /// Adds a listener for changes in the sandbox address
    ///
    /// - Parameter listener:   the OfficialsListener to add
    static func addSandboxAddressListener(_ listener: OfficialsListener) {
        sandboxAddressListeners.append(listener)
    }
    
    /// Removes a listener for changes in the sandbox address
    ///
    /// - Parameter listener:   the OfficialsListener to remove
    static func removeSandboxAddressListener(_ listener: OfficialsListener) {
        if let index = find(listener: listener, in: sandboxAddressListeners) {
            sandboxAddressListeners.remove(at: index)
        }

        if sandboxAddressListeners.count == 0 {
            sandboxOfficials.removeAll()
        }
    }
    
    /// Adds a listener for changes in home Events
    ///
    /// - Parameter listener:   the EventsListener to add
    static func addHomeEventsListener(_ listener: EventsListener) {
        homeEventsListeners.append(listener)
    }

    /// Removes a listener for changes in the home Events
    ///
    /// - Parameter listener:   the EventsListener to remove
    static func removeHomeEventsListener(_ listener: EventsListener) {
        if let index = find(listener: listener, in: homeEventsListeners) {
            homeEventsListeners.remove(at: index)
        }
    }

    /// Adds a listener for changes in an Official's Events
    ///
    /// - Parameter listener:   the EventsListener to add
    static func addOfficialEventsListener(_ listener: EventsListener) {
        officialEventsListeners.append(listener)
    }

    /// Removes a listener for changes in an Official's Events
    ///
    /// - Parameter listener:   the EventsListener to remove
    static func removeOfficialEventsListener(_ listener: EventsListener) {
        if let index = find(listener: listener, in: officialEventsListeners) {
            officialEventsListeners.remove(at: index)
        }

        if officialEventsListeners.count == 0 {
            officialEvents.removeAll()
        }
    }

    /// Adds a listener for changes in a User's Events
    ///
    /// - Parameter listener:   the EventsListener to add
    static func addUserEventsListener(_ listener: EventsListener) {
        userEventsListeners.append(listener)
    }

    /// Removes a listener for changes in an User's Events
    ///
    /// - Parameter listener:   the EventsListener to remove
    static func removeUserEventsListener(_ listener: EventsListener) {
        if let index = find(listener: listener, in: userEventsListeners) {
            userEventsListeners.remove(at: index)
        }

        if userEventsListeners.count == 0 {
            userEvents.removeAll()
        }
    }

    static func addEvent(_ event: Event) {
        AppState.homeEvents.append(event)
        AppState.homeEvents.sort()

        if (event.official == AppState.official) {
            AppState.officialEvents.append(event)
            AppState.officialEvents.sort()
        }

        if (event.owner == AppState.userId) {
            AppState.userEvents.append(event)
            AppState.userEvents.sort()
        }
    }

    /// Initializes the home Officials with the current user's home Address
    /// and the profile picture to the user's profile picture
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
        UsersDatabase.getCurrentUserProfilePicture { (image, error) in
            if error != nil {
                // TODO: Handle Error
                print(error.debugDescription)
            } else {
                if let image = image {
                    profilePicture = image
                }
            }
        }
    }

    /// Clears app state data (for use when user logs out)
    static func clear() {
        homeAddress = nil
        profilePicture = DEFAULT_NOT_LOADED
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
    
    /// Loads in the Events for the home Officials
    ///
    /// - Parameter completion:     the completion handler
    private static func loadHomeEvents(completion: @escaping ([Event]) -> ()) {
        let group = DispatchGroup()
        var result:[Event] = []
        
        // Get Events for each Official
        for official in AppState.homeOfficials {
            group.enter()
            Event.allWith(official: official) {(events, error) in
                // Append the Events and leave
                result += events
                group.leave()
            }
        }
        
        // Wait until all Events are pulled before returning
        group.notify(queue: .main) {
            return completion(result.sorted())
        }
    }

    /// Loads in the Events for an Official
    ///
    /// - Parameter completion:     the completion handler
    private static func loadOfficialEvents(completion: @escaping ([Event]) -> ()) {
        let group = DispatchGroup()
        var result:[Event] = []

        // Get Events for each Official
        group.enter()
        Event.allWith(official: self.official!) {(events, error) in
            // Append the Events and leave
            result += events
            group.leave()
        }

        // Wait until all Events are pulled before returning
        group.notify(queue: .main) {
            return completion(result.sorted())
        }
    }

    /// Loads in the Events for a User
    ///
    /// - Parameter completion:     the completion handler
    private static func loadUserEvents(completion: @escaping ([Event]) -> ()) {
        let group = DispatchGroup()
        var result:[Event] = []

        // Get Events for each Official
        group.enter()
        Event.allWith(owner: userId!) { (events, error) in
            // Append the Events and leave
            result += events
            group.leave()
        }

        // Wait until all Events are pulled before returning
        group.notify(queue: .main) {
            return completion(result.sorted())
        }
    }
    
    /// Finds the given listener in the given Array of listeners
    ///
    /// - Parameter listener:   the listener to search for
    /// - Parameter in:         the Array to search
    ///
    /// - Returns: the index if found or nil if not found
    private static func find(listener:OfficialsListener,
                             in listeners:[OfficialsListener]) -> Int? {
        return listeners.firstIndex {(appStateListener) in
            if let listener1 = listener as? UIViewController,
                let listener2 = appStateListener as? UIViewController {
                return listener1 === listener2
            }
            
            // should never occur
            return false
        }
    }
    
    /// Finds the given listener in the given Array of listeners
    ///
    /// - Parameter listener:   the listener to search for
    /// - Parameter in:         the Array to search
    ///
    /// - Returns: the index if found or nil if not found
    private static func find(listener:EventsListener,
                             in listeners:[EventsListener]) -> Int? {
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
