//
//  PopoverViewController.swift
//  RepresentsMe
//
//  Created by Michael Tirtowidjojo on 4/11/19.
//  Copyright © 2019 11foot8. All rights reserved.
//

import UIKit

/// Implements view controllers as a popover
class PopoverViewController: UIViewController {

    /// Sets up the view controller as a popover
    ///
    /// - Parameter parent:     the popover presentation delegate
    /// - Parameter view:       the source view
    func setup(parent:UIPopoverPresentationControllerDelegate,
               view:UIView) {
        self.modalPresentationStyle = .overFullScreen

        if let controller = self.popoverPresentationController {
            controller.delegate = parent
            controller.sourceRect = CGRect(x: view.center.x,
                                           y: view.center.y,
                                           width: 0,
                                           height: 0)
            controller.sourceView = view
            controller.permittedArrowDirections = UIPopoverArrowDirection(
                rawValue: 0)
        }
    }
}
