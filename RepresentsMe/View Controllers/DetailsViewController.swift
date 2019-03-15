//
//  DetailsViewController.swift
//  RepresentsMe
//
//  Created by Varun Adiga on 3/2/19.
//  Copyright © 2019 11foot8. All rights reserved.
//

import Foundation
import UIKit

class DetailsViewController: UIViewController {
    @IBOutlet weak var officialName: UILabel!
    @IBOutlet weak var officialSeat: UILabel!
    @IBOutlet weak var officialParty: UILabel!
    @IBOutlet weak var officialContact: UILabel!
    @IBOutlet weak var officialPicture: UIImageView!
    
    var passedOfficial:Official?
    
    override func viewWillAppear(_ animated: Bool) {
        officialName.text = passedOfficial?.name
        officialSeat.text = passedOfficial?.office
        officialParty.text = passedOfficial?.party
        if let passedPic = passedOfficial?.photo {
            officialPicture.image = passedPic
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}
