//
//  Event.swift
//  RepresentsMe
//
//  Created by Michael Tirtowidjojo on 4/2/19.
//  Copyright © 2019 11foot8. All rights reserved.
//

import MapKit
import Firebase

class Event {
    
    /// The completion handler for using Firestore
    typealias completionHandler = (Event, Error?) -> ()
    
    // The Firestore database
    static let db = Firestore.firestore()
    static let collection = "events"

    var documentID:String?
    var name:String
    var owner:String
    var location:CLLocationCoordinate2D
    var date:Date
    
    /// Gets the data formatted for Firestore
    var data:[String: Any] {
        return [
            "name": name,
            "owner": owner,
            "location": GeoPoint(latitude: location.latitude,
                                 longitude: location.longitude),
            "date": date
        ]
    }
    
    /// Creates a new Event given its attributes
    ///
    /// - Parameter name:       the name of the event
    /// - Parameter owner:      the owner of the event
    /// - Parameter location:   the location of the event
    /// - Parameter date:       the date of the event
    init(name:String,
         owner:String,
         location:CLLocationCoordinate2D,
         date:Date) {
        self.name = name
        self.owner = owner
        self.location = location
        self.date = date
    }
    
    /// Saves this Event
    ///
    /// - Parameter completion:     the completion handler
    func save(completion: @escaping completionHandler) {
        if self.documentID != nil {
            // This Event has already been saved, update it
            self.update(completion: completion)
        }
        
        // This Event has not been saved, add it
        self.add(completion: completion)
    }
    
    /// Updates this Event
    ///
    /// - Parameter completion:     the completion handler
    func update(completion: @escaping completionHandler) {
        if let documentID = self.documentID {
            let ref = Event.db.collection(Event.collection).document(documentID)
            ref.updateData(self.data) {(error) in
                return completion(self, error)
            }
        }
    }
    
    /// Creates a new event in Firestore
    ///
    /// - Parameter completion:     the completion handler
    private func add(completion: @escaping completionHandler) {
        var ref:DocumentReference?
        ref = Event.db.collection(Event.collection).addDocument(
            data: self.data) {(error) in
            if error == nil {
                self.documentID = ref!.documentID
            }
            return completion(self, error)
        }
    }

    /// Creates a new Event
    ///
    /// - Parameter name:       the name of the event
    /// - Parameter owner:      the owner of the event
    /// - Parameter location:   the location of the event
    /// - Parameter date:       the date of the event
    /// - Parameter completion:     the completion handler
    static func create(name:String,
                       owner:String,
                       location:CLLocationCoordinate2D,
                       date:Date,
                       completion: @escaping completionHandler) {
        let event = Event(name: name, owner: owner, location: location,
                          date: date)
        event.save(completion: completion)
    }
}
