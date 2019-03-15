//
//  PoliticalParty.swift
//  RepresentsMe
//
//  Created by Michael Tirtowidjojo on 3/14/19.
//  Copyright © 2019 11foot8. All rights reserved.
//

import UIKit

/// Represents the political party of an Official.
class PoliticalParty: Equatable {

    // Colors to use for default images
    static let LIGHT_BLUE = UIColor(red: 64 / 255,
                                    green: 86 / 255,
                                    blue: 244 / 255,
                                    alpha: 1)
    static let LIGHT_RED = UIColor(red: 206 / 255,
                                   green: 45 / 255,
                                   blue: 79 / 255,
                                   alpha: 1)
    
    // Singleton instances of the different parties for Officials to share
    static let republican = PoliticalParty(
        name: "Republican",
        color: PoliticalParty.LIGHT_RED,
        aliases: ["Republican", "Republican Party"])
    static let democratic = PoliticalParty(
        name: "Democrat",
        color: PoliticalParty.LIGHT_BLUE,
        aliases: ["Democrat", "Democratic", "Democratic Party"])
    static let nonpartisan = PoliticalParty(
        name: "Nonpartisan",
        color: .black,
        aliases: ["Nonpartisan", "none"])
    static let unknown = PoliticalParty(name: "Unknown", color: .black)
    
    var name:String         // The name to display
    var color:UIColor       // The color for the party
    var image:UIImage       // The default image to use
    var aliases:[String]    // Aliases for the party
    
    /// Creates a new Political Party loading in the default image for the
    /// party.
    ///
    /// - Parameter name:       the name to display for the party
    /// - Parameter color:      the color for the default image
    /// - Parameter aliases:    the aliases for the party
    private init(name:String, color:UIColor, aliases:[String] = []) {
        self.name = name
        self.color = color
        self.image = UIImage.fontAwesomeIcon(name: .userCircle,
                                             style: .solid,
                                             textColor: color,
                                             size: PORTRAIT_SIZE)
        self.aliases = aliases.map {$0.lowercased()}
    }
    
    /// Determines the PoliticalParty given an alias for the party.
    ///
    /// - Parameter for:    the alias for the party
    ///
    /// - Returns: the PoliticalParty matching the given alias
    static func determine(for alias:String) -> PoliticalParty {
        let alias = alias.lowercased()
        if PoliticalParty.republican.aliases.contains(alias) {
            return PoliticalParty.republican
        }
        
        if PoliticalParty.democratic.aliases.contains(alias) {
            return PoliticalParty.democratic
        }
        
        if PoliticalParty.nonpartisan.aliases.contains(alias) {
            return PoliticalParty.nonpartisan
        }
        
        return PoliticalParty.unknown
    }
    
    /// Compares two political parties for equality
    ///
    /// - Parameter lhs:    the first PoliticalParty
    /// - Parameter rhs:    the second PoliticalParty
    ///
    /// - Returns: true if lhs and rhs are the same object, false otherwise
    static func == (lhs:PoliticalParty, rhs:PoliticalParty) -> Bool {
        return lhs === rhs
    }
}
