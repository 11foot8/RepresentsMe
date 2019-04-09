//
//  Event.swift
//  RepresentsMe
//
//  Created by Michael Tirtowidjojo on 4/2/19.
//  Copyright © 2019 11foot8. All rights reserved.
//

import MapKit
import Firebase

/// Manages creating, updating, and deleting events through Firestore
class Event {
    
    /// The completion handlers for using Firestore
    typealias completionHandler = (Event, Error?) -> ()
    typealias allCompletionHandler = ([Event], Error?) -> ()
    
    // The Firestore database
    static let collection = "events"
    static let db = Firestore.firestore().collection(Event.collection)

    var documentID:String?                  // The document ID on Firestore
    var name:String                         // The name of the event
    var owner:String                        // The owner of the event
    var location:CLLocationCoordinate2D     // The location of the event
    var date:Date                           // The date of the event
    var official:Official?                  // The official related to event
    var attendees:[EventAttendee] = []      // The attendees for the event

    /// Gets the data formatted for Firestore
    var data:[String: Any] {
        return [
            "name": name,
            "owner": owner,
            "location": GeoPoint(latitude: location.latitude,
                                 longitude: location.longitude),
            "date": date,
            "officialName": official?.name ?? "",
            "divisionOCDID": official?.divisionOCDID ?? ""
        ]
    }
    
    /// Creates a new Event given its attributes
    ///
    /// - Parameter name:       the name of the event
    /// - Parameter owner:      the owner of the event
    /// - Parameter location:   the location of the event
    /// - Parameter date:       the date of the event
    /// - Parameter official:   the Official related to the event
    init(name:String,
         owner:String,
         location:CLLocationCoordinate2D,
         date:Date,
         official:Official) {
        self.name = name
        self.owner = owner
        self.location = location
        self.date = date
        self.official = official
    }
    
    /// Creates a new Event with the given query document snapshot
    ///
    /// - Parameter data:   the QueryDocumentSnapshot
    /// - Parameter group:  the dispatch group to notify when completed
    init(data:QueryDocumentSnapshot, group:DispatchGroup) {
        self.documentID = data.documentID
        
        // Set basic data
        let data = data.data()
        self.name = data["name"] as! String
        self.owner = data["owner"] as! String
        self.date = (data["date"] as! Timestamp).dateValue()
        
        // Build the location coordinate
        let geopoint = data["location"] as! GeoPoint
        self.location = CLLocationCoordinate2D(latitude: geopoint.latitude,
                                               longitude: geopoint.longitude)
        
        // Scrape the official
        self.getOfficial(name: data["officialName"] as! String,
                         division: data["divisionOCDID"] as! String,
                         group: group)
    }
    
    /// Saves this Event
    ///
    /// - Parameter completion:     the completion handler
    func save(completion: @escaping completionHandler) {
        if self.documentID != nil {
            // This Event has already been saved, update it
            self.update(completion: completion)
        } else {
            // This Event has not been saved, add it
            self.add(completion: completion)
        }
    }
    
    /// Updates this Event
    ///
    /// - Parameter completion:     the completion handler
    func update(completion: @escaping completionHandler) {
        if let documentID = self.documentID {
            let ref = Event.db.document(documentID)
            ref.updateData(self.data) {(error) in
                return completion(self, error)
            }
        }
    }
    
    /// Deletes this Event
    ///
    /// - Parameter completion:     the completion handler
    func delete(completion: @escaping completionHandler) {
        if let documentID = self.documentID {
            Event.db.document(documentID).delete {(error) in
                if error == nil {
                    // Succesfully deleted, delete all attendees
                    for attendee in self.attendees {
                        attendee.delete()
                    }
                }
                return completion(self, error)
            }
        }
    }
    
    /// Loads in the attendees for this Event
    ///
    /// - Parameter completion:     the completion handler
    func loadAttendees(completion: @escaping completionHandler) {
        if let documentID = self.documentID {
            let ref = EventAttendee.db.whereField("eventID",
                                                  isEqualTo: documentID)
            ref.getDocuments {(data, error) in
                if error == nil {
                    // Build and add each attendee
                    for data in data!.documents {
                        self.attendees.append(EventAttendee(data: data))
                    }
                }
                
                return completion(self, error)
            }
        }
    }
    
    /// Adds an attendee to this Event
    ///
    /// - Parameter userID:         the ID of the attendee
    /// - Parameter status:         the status of the attendee
    /// - Parameter completion:     the completion handler (default nil)
    func addAttendee(userID:String,
                     status:String,
                     completion:EventAttendee.completionHandler = nil) {
        if let documentID = self.documentID {
            EventAttendee.create(eventID: documentID,
                                 userID: userID,
                                 status: status) {(attendee, error) in
                // Add to the list of attendees and return the completion
                if error == nil {
                    self.attendees.append(attendee)
                }
                completion?(attendee, error)
            }
        }
    }
    
    /// Removes the given attendee from this Event
    ///
    /// - Parameter userID:         the ID of the attendee
    /// - Parameter completion:     the completion handler (default nil)
    func removeAttendee(userID:String,
                        completion:EventAttendee.completionHandler = nil) {
        for (index, attendee) in self.attendees.enumerated() {
            if attendee.userID == userID {
                // Found the attendee to delete
                attendee.delete {(attendee, error) in
                    // Delete from the list of attendees
                    self.attendees.remove(at: index)
                    completion?(attendee, error)
                }
            }
        }
    }
    
    /// Creates a new event in Firestore
    ///
    /// - Parameter completion:     the completion handler
    private func add(completion: @escaping completionHandler) {
        var ref:DocumentReference?
        ref = Event.db.addDocument(data: self.data) {(error) in
            if error == nil {
                self.documentID = ref!.documentID
            }
            return completion(self, error)
        }
    }
    
    /// Scrapes the official for this event
    ///
    /// - Parameter name:       the name of the official
    /// - Parameter division:   the division of the official
    /// - Parameter group:      the dispatch group to leave when completed
    private func getOfficial(name:String,
                             division:String,
                             group:DispatchGroup) {
        OfficialScraper.getOfficial(
            with: name,
            from: division,
            apikey: civic_api_key) {(official, error) in
                
            // Set the Official and notify the group that scraping completed
            self.official = official
            group.leave()
        }
    }

    /// Creates a new Event
    ///
    /// - Parameter name:           the name of the event
    /// - Parameter owner:          the owner of the event
    /// - Parameter location:       the location of the event
    /// - Parameter date:           the date of the event
    /// - Parameter official:       the official related to the event
    /// - Parameter completion:     the completion handler
    static func create(name:String,
                       owner:String,
                       location:CLLocationCoordinate2D,
                       date:Date,
                       official:Official,
                       completion: @escaping completionHandler) {
        let event = Event(name: name, owner: owner, location: location,
                          date: date, official: official)
        event.save(completion: completion)
    }
    
    /// Gets all Events with the given owner
    ///
    /// - Parameter owner:          the owner to filter by
    /// - Parameter completion:     the completion handler
    static func allWith(owner:String,
                        completion: @escaping allCompletionHandler) {
        let ref = Event.db.whereField("owner", isEqualTo: owner)
        ref.getDocuments {(data, error) in
            let group = DispatchGroup()
            var events:[Event] = []
            if error == nil {
                // Build each event
                for data in data!.documents {
                    group.enter()
                    events.append(Event(data: data, group: group))
                }
            }
            
            // Wait until all Officials are pulled before returning
            group.notify(queue: .main) {
                return completion(events, error)
            }
        }
    }
}
