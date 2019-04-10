//
//  LoadingHUD.swift
//  RepresentsMe
//
//  Created by Jacob Hausmann on 4/9/19.
//  Copyright © 2019 11foot8. All rights reserved.
//

import Foundation
import MBProgressHUD
import UIKit

class LoadingHUD {
    var hud:MBProgressHUD

    init(_ view:UIView) {
        hud = MBProgressHUD.showAdded(to: view, animated: true)
        hud.mode = MBProgressHUDMode.indeterminate
        hud.label.text = "Loading"
    }

    func end() {
        hud.hide(animated: true)
    }
}
