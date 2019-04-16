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
class Event: Comparable {
    
    /// The completion handlers for using Firestore
    typealias completionHandler = (Event?, Error?) -> ()
    typealias allCompletionHandler = ([Event], Error?) -> ()
    
    // The Firestore database
    static let collection = "events"
    static let db = Firestore.firestore().collection(Event.collection)

    var documentID:String?                  // The document ID on Firestore
    var name:String                         // The name of the event
    var owner:String                        // The owner of the event
    var description:String                  // The description of the event
    var location:CLLocationCoordinate2D     // The location of the event
    var date:Date                           // The date of the event
    var official:Official?                  // The official related to event
    var address:Address                     // The Address for the event
    var attendees:[EventAttendee] = []      // The attendees for the event

    /// Gets the data formatted for Firestore
    var data:[String: Any] {
        return [
            "name": name,
            "owner": owner,
            "description": description,
            "location": GeoPoint(latitude: location.latitude,
                                 longitude: location.longitude),
            "date": date,
            "officialName": official?.name ?? "",
            "divisionOCDID": official?.divisionOCDID ?? "",
            "address": [
                "line1": address.streetAddress,
                "city": address.city,
                "state": address.state,
                "zip": address.zipcode
            ]
        ]
    }
    
    /// Gets the date formatted to "MMMM d, h:mm a"
    var formattedDate:String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM d, h:mm a"
        return formatter.string(from: date)
    }

    /// Creates a new Event given its attributes
    ///
    /// - Parameter name:           the name of the event
    /// - Parameter owner:          the owner of the event
    /// - Parameter description:    the description of the event
    /// - Parameter location:       the location of the event
    /// - Parameter date:           the date of the event
    /// - Parameter official:       the Official related to the event
    /// - Parameter address:        the Address for the event
    init(name:String,
         owner:String,
         description:String,
         location:CLLocationCoordinate2D,
         date:Date,
         official:Official,
         address:Address) {
        self.name = name
        self.owner = owner
        self.description = description
        self.location = location
        self.date = date
        self.official = official
        self.address = address
    }

    /// Creates a new Event with the given document snapshot
    ///
    /// - Parameter data:   the DocumentSnapshot
    private init(data:DocumentSnapshot) {
        self.documentID = data.documentID
        
        // Set basic data
        let data = data.data()!
        self.name = data["name"] as! String
        self.owner = data["owner"] as! String
        self.description = data["description"] as! String
        self.date = (data["date"] as! Timestamp).dateValue()
        self.address = Address(with: data["address"] as! [String: String])

        // Build the location coordinate
        let geopoint = data["location"] as! GeoPoint
        self.location = CLLocationCoordinate2D(latitude: geopoint.latitude,
                                               longitude: geopoint.longitude)
    }
    
    /// Creates a new Event with the given Official
    ///
    /// - Parameter data:       the DocumentSnapshot
    /// - Parameter official:   the Official
    private convenience init(data:DocumentSnapshot, official:Official) {
        self.init(data: data)
        self.official = official
    }
    
    /// Creates a new Event scraping the Official
    ///
    /// - Parameter data:   the DocumentSnapshot
    /// - Parameter group:  the group to notify when done
    private convenience init(data:DocumentSnapshot, group:DispatchGroup) {
        self.init(data: data)
        
        // Get the official
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
                    // Delete from AppState
                    if let index = AppState.homeEvents.index(of: self) {
                        AppState.homeEvents.remove(at: index)
                    }
                    
                    // Delete all attendees
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
                    // Clear the attendees
                    self.attendees.removeAll()
                    
                    // Build and add each attendee
                    for data in data!.documents {
                        self.attendees.append(EventAttendee(data: data,
                                                            event: self))
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
                     status:RSVPType,
                     completion:EventAttendee.completionHandler = nil) {
        if self.documentID != nil {
            EventAttendee.create(event: self,
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
    
    /// Checks if this Event matches the given query
    ///
    /// - Parameter query:  the query to check against
    ///
    /// - Returns: true if matches the query, false otherwise
    func matches(_ query:String) -> Bool {
        if query == "" {
            return true
        }
        
        let query = query.lowercased()
        guard let official = self.official else {
            return self.name.lowercased().contains(query)
        }
        
        return self.name.lowercased().contains(query) ||
            official.division.lowercased().contains(query) ||
            official.office.lowercased().contains(query) ||
            official.name.lowercased().contains(query)
    }
    
    /// Creates a new event in Firestore
    ///
    /// - Parameter completion:     the completion handler
    private func add(completion: @escaping completionHandler) {
        var ref:DocumentReference?
        ref = Event.db.addDocument(data: self.data) {(error) in
            if error == nil {
                self.documentID = ref!.documentID
                AppState.homeEvents.append(self)
                AppState.homeEvents.sort()
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
        group.enter()
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
                       description:String,
                       location:CLLocationCoordinate2D,
                       date:Date,
                       official:Official,
                       completion: @escaping completionHandler) {
        GeocoderWrapper.reverseGeocodeCoordinates(location) {(address) in
            let event = Event(name: name,
                              owner: owner,
                              description: description,
                              location: location,
                              date: date,
                              official: official,
                              address: address)
            event.save(completion: completion)
        }
    }
    
    /// Gets all Events with the given query
    ///
    /// - Parameter query:          the Query
    /// - Parameter completion:     the completion handler
    static func allWith(query:Query,
                        completion: @escaping allCompletionHandler) {
        query.getDocuments {(data, error) in
            let group = DispatchGroup()
            var events:[Event] = []
            if error == nil {
                // Build each event
                for data in data!.documents {
                    events.append(Event(data: data, group: group))
                }
            }
            
            // Wait until all Officials are pulled before returning
            group.notify(queue: .main) {
                return completion(events, error)
            }
        }
    }

    /// Gets all Events with the given owner
    ///
    /// - Parameter owner:          the owner to filter by
    /// - Parameter completion:     the completion handler
    static func allWith(owner:String,
                        completion: @escaping allCompletionHandler) {
        let query = Event.db.whereField("owner", isEqualTo: owner)
        Event.allWith(query: query, completion: completion)
    }
    
    /// Gets all Events for the given official
    ///
    /// - Parameter official:       the Official
    /// - Parameter completion:     the completion handler
    static func allWith(official:Official,
                        completion: @escaping allCompletionHandler) {
        let query = Event.db
            .whereField("divisionOCDID", isEqualTo: official.divisionOCDID)
            .whereField("officialName", isEqualTo: official.name)
        query.getDocuments {(data, error) in
            var events:[Event] = []
            if error == nil {
                // Build each event
                for data in data!.documents {
                    events.append(Event(data: data, official: official))
                }
            }
            
            return completion(events, error)
        }
    }

    /// Finds an event by its ID
    ///
    /// - Parameter eventID:        the document ID of the event
    /// - Parameter completion:     the completion handler
    static func find_by(eventID:String,
                        completion: @escaping completionHandler) {
        let ref = Event.db.document(eventID)
        ref.getDocument {(data, error) in
            if error == nil {
                // Build the event
                let group = DispatchGroup()
                let event = Event(data: data!, group: group)

                // Wait until the Official is pulled before returning
                group.notify(queue: .main) {
                    return completion(event, error)
                }
            } else {
                // The document does not exist
                return completion(nil, nil)
            }
        }
    }
    
    /// Compares two Events
    ///
    /// - Parameter lhs:    the first Event
    /// - Parameter rhs:    the second Event
    ///
    /// - Returns: true if lhs < rhs, false otherwise
    static func <(lhs:Event, rhs:Event) -> Bool {
        if lhs.official == nil && rhs.official == nil {
            // Neither Event has an official, compare based on name
            return lhs.name < rhs.name
        }
        
        if rhs.official == nil {
            // rhs does not have an official, lhs should come before it
            return true
        }
        
        if lhs.official == nil {
            // lhs does not have an official, rhs should come before it
            return false
        }
        
        if lhs.official != rhs.official {
            // The events are for two different officials, sort based on the
            // official's index
            return lhs.official!.index > rhs.official!.index
        }

        if lhs.date != rhs.date {
            // The events are for the same official on two different days,
            // the earlier event should come first
            return lhs.date < rhs.date
        }
        
        // The events are for the same official on the same day, sort based
        // on the event name
        return lhs.name < rhs.name
    }

    /// Compares two Events for equality
    ///
    /// - Parameter lhs:    the first Event
    /// - Parameter rhs:    the second Event
    ///
    /// - Returns: true if lhs == rhs, false otherwise
    static func ==(lhs:Event, rhs:Event) -> Bool {
        return lhs.name == rhs.name &&
            lhs.owner == rhs.owner &&
            lhs.location.latitude == rhs.location.latitude &&
            lhs.location.longitude == rhs.location.longitude &&
            lhs.date == rhs.date &&
            lhs.official == rhs.official
    }
}
