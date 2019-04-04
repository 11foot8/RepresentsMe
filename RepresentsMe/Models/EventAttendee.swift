//
//  EventAttendee.swift
//  RepresentsMe
//
//  Created by Michael Tirtowidjojo on 4/3/19.
//  Copyright © 2019 11foot8. All rights reserved.
//

import Firebase

class EventAttendee {
    
    typealias completionHandler = (EventAttendee, Error?) -> ()
    
    // The Firestore database
    static let collection = "event_attendees"
    static let db = Firestore.firestore().collection(EventAttendee.collection)
    
    var documentID:String?  // The document ID on Firestore
    var name:String         // The name of the attendee
    var eventID:String      // The Event this attendee is for
    var status:String       // The status of the attendee
    
    /// Gets the data formatted for Firestore
    var data:[String: Any] {
        return [
            "name": self.name,
            "eventID": self.eventID,
            "status": self.status
        ]
    }
    
    /// Creates a new attendee for an event
    ///
    /// - Parameter eventID:    the Firestore document ID for the Event
    /// - Parameter name:       the name of the attendee
    /// - Parameter status:     the attendee's status
    init(eventID:String, name:String, status:String) {
        self.eventID = eventID
        self.name = name
        self.status = status
    }
    
    /// Creates a new attendee from the given query document snapshot
    ///
    /// - Parameter data:   the QueryDocumentSnapshot
    init(data:QueryDocumentSnapshot) {
        self.documentID = data.documentID
        
        // Set the basic data
        let data = data.data()
        self.name = data["name"] as! String
        self.eventID = data["eventID"] as! String
        self.status = data["status"] as! String
    }
    
    /// Saves this EventAttendee
    ///
    /// - Parameter completion:     the completion handler
    func save(completion: @escaping completionHandler) {
        if self.documentID != nil {
            // This EventAttendee has already been saved, update it
            self.update(completion: completion)
        } else {
            // This EventAttendee has not been saved, add it
            self.add(completion: completion)
        }
    }
    
    /// Updates this EventAttendee
    ///
    /// - Parameter completion:     the completion handler
    func update(completion: @escaping completionHandler) {
        if let documentID = self.documentID {
            let ref = EventAttendee.db.document(documentID)
            ref.updateData(self.data) {(error) in
                return completion(self, error)
            }
        }
    }
    
    /// Deletes this EventAttendee
    ///
    /// - Parameter completion:     the completion handler
    func delete(completion: @escaping completionHandler) {
        if let documentID = self.documentID {
            EventAttendee.db.document(documentID).delete {(error) in
                return completion(self, error)
            }
        }
    }
    
    /// Creates a new event attendee in Firestore
    ///
    /// - Parameter completion:     the completion handler
    private func add(completion: @escaping completionHandler) {
        var ref:DocumentReference?
        ref = EventAttendee.db.addDocument(data: self.data) {(error) in
            if error == nil {
                self.documentID = ref!.documentID
            }
            return completion(self, error)
        }
    }
    
    /// Creates a new EventAttendee
    ///
    /// - Parameter eventID:        the Firestore document ID for the Event
    /// - Parameter name:           the name of the attendee
    /// - Parameter status:         the attendee's status
    /// - Parameter completion:     the completion handler
    static func create(eventID:String,
                       name:String,
                       status:String,
                       completion: @escaping completionHandler) {
        let attendee = EventAttendee(eventID: eventID, name: name,
                                     status: status)
        attendee.save(completion: completion)
    }
}
