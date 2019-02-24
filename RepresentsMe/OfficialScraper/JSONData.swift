//
//  JSONData.swift
//  RepresentsMe
//
//  Created by Michael Tirtowidjojo on 2/21/19.
//  Copyright © 2019 11foot8. All rights reserved.
//

/// Container to hold information when decoding JSON strings.
struct JSONData: Decodable {
    var divisions:[String: JSONDivision]
    var offices:[JSONOffice]
    var officials:[JSONOfficial]
}
