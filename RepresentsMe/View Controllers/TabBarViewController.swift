//
//  TabBarView.swift
//  RepresentsMe
//
//  Created by Michael Tirtowidjojo on 3/6/19.
//  Copyright © 2019 11foot8. All rights reserved.
//

import UIKit

class TabBarViewController: UITabBarController {
    
    static let icons:[String: (FontAwesome, FontAwesomeStyle)] = [
        "Officials": (.thList, .solid),
        "Settings": (.cog, .solid),
        "Map": (.mapMarkedAlt, .solid),
        "Events": (.calendarWeek, .solid)
    ]
    
    override func viewDidLoad() {
        if let tabItems = self.tabBar.items {
            for tabItem in tabItems {
                if let title = tabItem.title,
                   let icon = TabBarViewController.icons[title] {
                    
                    tabItem.image = UIImage.fontAwesomeIcon(
                        name: icon.0,
                        style: icon.1,
                        textColor: UIColor.blue,
                        size: CGSize(width: 30, height: 30))
                }
            }
        }
    }
}
