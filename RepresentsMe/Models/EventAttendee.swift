//
//  EventAttendee.swift
//  RepresentsMe
//
//  Created by Michael Tirtowidjojo on 4/3/19.
//  Copyright © 2019 11foot8. All rights reserved.
//

import Firebase

/// The types of RSVP status
enum RSVPType: String {
    case going = "going"         // Status for a user planning on attending an event
    case maybe = "maybe"         // Status for a user who may attend an event
    case notGoing = "not_going"  // Status for a user who will not attend an event
}

/// Manages creating, updating, and deleting event attendees through Firestore
class EventAttendee {
    
    /// The completion handler for using Firestore
    typealias completionHandler = ((EventAttendee, Error?) -> ())?
    typealias allCompletionHandler = ([EventAttendee], Error?) -> ()
    
    // The Firestore database
    static let collection = "event_attendees"
    static let db = Firestore.firestore().collection(EventAttendee.collection)
    
    var documentID:String?  // The document ID on Firestore
    var userID:String       // The ID of the attendee
    var status:RSVPType     // The status of the attendee
    var event:Event?        // The event
    
    /// Gets the data formatted for Firestore
    var data:[String: Any] {
        return [
            "userID": self.userID,
            "eventID": self.event?.documentID ?? "",
            "status": self.status.rawValue
        ]
    }
    
    /// Gets if the attendee is going to the Event
    var isGoing:Bool {
        return status == .going
    }
    
    /// Gets if the attendee is maybe going to the Event
    var isMaybeGoing:Bool {
        return status == .maybe
    }
    
    /// Gets if the attendee is not going to the Event
    var isNotGoing:Bool {
        return status == .notGoing
    }
    
    /// Creates a new attendee for an event
    ///
    /// - Parameter event:      the Event
    /// - Parameter userID:     the ID of the attendee
    /// - Parameter status:     the attendee's status
    init(event:Event, userID:String, status:RSVPType) {
        self.event = event
        self.userID = userID
        self.status = status
    }

    /// Creates a new attendee from the given document snapshot
    ///
    /// - Parameter data:   the DocumentSnapshot
    private init(data:DocumentSnapshot) {
        self.documentID = data.documentID
        
        // Set the basic data
        let data = data.data()!
        self.userID = data["userID"] as! String
        self.status = RSVPType(rawValue: data["status"] as! String)!
    }
    
    /// Creates a new attendee for the given Event
    ///
    /// - Parameter data:   the DocumentSnapshot
    /// - Parameter event:  the Event
    convenience init(data:DocumentSnapshot, event:Event) {
        self.init(data: data)
        self.event = event
    }
    
    /// Creates a new attendee scraping the Event
    ///
    /// - Parameter data:   the DocumentSnapshot
    /// - Parameter group:  the group to notify when done
    convenience init(data:DocumentSnapshot, group:DispatchGroup) {
        self.init(data: data)
        
        // Scrape the Event
        self.getEvent(eventID: data["eventID"] as! String, group: group)
    }

    /// Saves this EventAttendee
    ///
    /// - Parameter completion:     the completion handler (default nil)
    func save(completion:completionHandler = nil) {
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
    /// - Parameter completion:     the completion handler (default nil)
    func update(completion: completionHandler = nil) {
        if let documentID = self.documentID {
            let ref = EventAttendee.db.document(documentID)
            ref.updateData(self.data) {(error) in
                completion?(self, error)
            }
        }
    }
    
    /// Sets the attendee to going
    ///
    /// - Parameter completion:     the completion handler (default nil)
    func setIsGoing(completion:completionHandler = nil) {
        self.setStatus(to: .going, completion: completion)
    }
    
    /// Sets the attendee to maybe going
    ///
    /// - Parameter completion:     the completion handler (default nil)
    func setIsMaybeGoing(completion:completionHandler = nil) {
        self.setStatus(to: .maybe, completion: completion)
    }

    /// Sets the attendee to not going
    ///
    /// - Parameter completion:     the completion handler (default nil)
    func setIsNotGoing(completion:completionHandler = nil) {
        self.setStatus(to: .notGoing, completion: completion)
    }
    
    /// Updates the status of the attendee.
    /// If the status changed, updates the Firestore record, otherwise returns
    /// immediately
    ///
    /// - Parameter to:             the status to set to
    /// - Parameter completion:     the completion handler (default nil)
    func setStatus(to status:RSVPType, completion:completionHandler = nil) {
        if status != self.status {
            self.status = status
            self.update(completion: completion)
        } else {
            completion?(self, nil)
        }
    }

    /// Deletes this EventAttendee
    ///
    /// - Parameter completion:     the completion handler (default nil)
    func delete(completion:completionHandler = nil) {
        if let documentID = self.documentID {
            EventAttendee.db.document(documentID).delete {(error) in
                completion?(self, error)
            }
        }
    }
    
    /// Creates a new event attendee in Firestore
    ///
    /// - Parameter completion:     the completion handler (default nil)
    private func add(completion:completionHandler = nil) {
        var ref:DocumentReference?
        ref = EventAttendee.db.addDocument(data: self.data) {(error) in
            if error == nil {
                self.documentID = ref!.documentID
            }
            completion?(self, error)
        }
    }
    
    /// Loads the Event for this attendee
    ///
    /// - Parameter eventID:    the event document ID
    /// - Parameter group:      the dispatch group to notify
    private func getEvent(eventID:String, group:DispatchGroup) {
        group.enter()
        Event.find_by(eventID: eventID) {(event, error) in
            self.event = event
            group.leave()
        }
    }
    
    /// Creates a new EventAttendee
    ///
    /// - Parameter event:          the Event
    /// - Parameter userID:         the ID of the attendee
    /// - Parameter status:         the attendee's status
    /// - Parameter completion:     the completion handler (default nil)
    static func create(event:Event,
                       userID:String,
                       status:RSVPType,
                       completion:completionHandler = nil) {
        let attendee = EventAttendee(event: event,
                                     userID: userID,
                                     status: status)
        attendee.save(completion: completion)
    }
    
    /// Gets all EventAttendees with the given userID
    ///
    /// - Parameter userID:         the user to filter by
    /// - Parameter completion:     the completion handler
    static func allWith(userID:String,
                        completion: @escaping allCompletionHandler) {
        let ref = EventAttendee.db.whereField("userID", isEqualTo: userID)
        ref.getDocuments {(data, error) in
            let group = DispatchGroup()
            var attendees:[EventAttendee] = []
            if error == nil {
                // Build each event
                for data in data!.documents {
                    attendees.append(EventAttendee(data: data, group: group))
                }
            }
            
            // Wait until all Events are pulled before returning
            group.notify(queue: .main) {
                return completion(attendees, error)
            }
        }
    }
}
