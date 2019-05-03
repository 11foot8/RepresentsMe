//
//  AttendeeCell.swift
//  RepresentsMe
//
//  Created by Benny Singer on 5/1/19.
//  Copyright © 2019 11foot8. All rights reserved.
//

import UIKit

class AttendeeCell: UICollectionViewCell {
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var rsvpLabel: UILabel!

    var attendee:EventAttendee? {
        didSet {
            profileImageView.image = nil

            if let attendee = attendee {
                switch attendee.status {
                case .going:
                    rsvpLabel.text = "check-circle"
                    rsvpLabel.textColor = GOING_GREEN
                    break
                case .maybe:
                    rsvpLabel.text = "question-circle"
                    rsvpLabel.textColor = MAYBE_ORANGE
                    break
                case .notGoing:
                    rsvpLabel.text = "times-circle"
                    rsvpLabel.textColor = NOT_GOING_RED
                    break
                }

                UsersDatabase.getUserProfilePicture(uid: attendee.userID) { (uid, image, error) in
                    if attendee.userID == uid {
                        self.profileImageView.image = image
                    }
                }
            }
        }
    }


}
