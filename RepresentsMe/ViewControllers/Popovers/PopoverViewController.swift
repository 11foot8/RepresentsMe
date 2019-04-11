//
//  PopoverViewController.swift
//  RepresentsMe
//
//  Created by Michael Tirtowidjojo on 4/11/19.
//  Copyright © 2019 11foot8. All rights reserved.
//

import UIKit

/// Implements view controllers as a popover
class PopoverViewController: UIViewController,
                             UIPopoverPresentationControllerDelegate {

    /// Sets up the view controller as a popover
    ///
    /// - Parameter in:     the source view
    func setup(in view:UIView) {
        self.modalPresentationStyle = .overFullScreen

        if let controller = self.popoverPresentationController {
            controller.delegate = self
            controller.sourceRect = CGRect(x: view.center.x,
                                           y: view.center.y,
                                           width: 0,
                                           height: 0)
            controller.sourceView = view
            controller.permittedArrowDirections = UIPopoverArrowDirection(
                rawValue: 0)
        }
    }
    
    /// Use no adaptive presentation style
    func adaptivePresentationStyle(
        for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
}
