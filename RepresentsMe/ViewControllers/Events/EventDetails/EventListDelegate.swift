//
//  CreateEventDelegate.swift
//  RepresentsMe
//
//  Created by Michael Tirtowidjojo on 4/10/19.
//  Copyright © 2019 11foot8. All rights reserved.
//

/// The protocol for a class to implement to enable handling when Events are
/// created, updated, and deleted
protocol EventListDelegate {
    func eventCreatedDelegate(event:Event)
    func eventUpdatedDelegate(event:Event)
    func eventDeletedDelegate(event:Event)
}
