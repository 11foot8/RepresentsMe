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
    
    var passedName = String()
    var passedSeat = String()
    var passedParty = String()
    var passedEmails = [String]()
    var passedPhoneNums = [String]()
    var passedPicture = UIImage()
    
    override func viewWillAppear(_ animated: Bool) {
        officialName.text = passedName
        officialSeat.text = passedSeat
        officialParty.text = passedParty
        officialPicture.image = passedPicture
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}
