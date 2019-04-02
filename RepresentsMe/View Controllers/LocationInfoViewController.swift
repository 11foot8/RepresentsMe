//
//  LocationInfoViewController.swift
//  RepresentsMe
//
//  Created by Jacob Hausmann on 4/1/19.
//  Copyright © 2019 11foot8. All rights reserved.
//

import UIKit
class LocationInfoViewController: UIViewController {
    // MARK: - Properties
    var address:Address?
//    var delegate:LocationInfoDelegate?

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        outerView.layer.cornerRadius = 18
        outerView.clipsToBounds = true

        goButton.layer.cornerRadius = 10
        goButton.clipsToBounds = true
    }

    // MARK: - Outlets
    @IBOutlet weak var goButton: UIButton!
    @IBOutlet var outerView: UIView!

    // MARK: - Actions
    @IBAction func goButtonTouchUp(_ sender: Any) {
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
