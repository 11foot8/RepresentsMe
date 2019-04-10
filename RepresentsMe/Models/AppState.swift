//
//  AppState.swift
//  RepresentsMe
//
//  Created by Michael Tirtowidjojo on 4/9/19.
//  Copyright © 2019 11foot8. All rights reserved.
//

import Foundation

class AppState {
    
    /// The Officials for the user's home address
    static var homeOfficials:[Official] = []
    
    /// The Officials for the user's selected address
    static var sandboxOfficials:[Official] = []
    
    /// The currently selected sandbox Address
    static var sandboxAddress:Address?
}
