//
//  ExternalLinksSettingsViewController.swift
//  RepresentsMe
//
//  Created by Jacob Hausmann on 5/1/19.
//  Copyright © 2019 11foot8. All rights reserved.
//

import UIKit

class ExternalLinksSettingsViewController: UIViewController {
    // MARK: - Properties
    let externalLinksEnabledMessage:String = "Tapping external links will launch the links in the Safari app."
    let externalLinksDisabledMessage:String = "Tapping an external link will open the webpage within the RepresentsMe app."

    let calendarEnabledMessage:String = "When exporting an event, the Calendar app will be opened to that event."
    let calendarDisabledMessage:String = "When exporting an event, you will be asked if you would like to open the Calendar app to that event or not."

    var hud:LoadingHUD?

    // MARK: - Outlets
    @IBOutlet var externalLinksSwitch: UISwitch!
    @IBOutlet var calendarSwitch: UISwitch!
    @IBOutlet var externalLinksSubtitle: UILabel!
    @IBOutlet var calendarSubtitle: UILabel!

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        externalLinksSwitch.isOn = AppState.openExternalLinksInSafari
        calendarSwitch.isOn = AppState.openCalendarOnEventExport
        updateExternalLinksInfo()
        updateCalendarExportInfo()
        // Do any additional setup after loading the view.
    }

    // MARK: - Actions
    @IBAction func externalLinksSwitchValueChanged(_ sender: Any) {
        updateExternalLinksPreferences(value: externalLinksSwitch.isOn)
    }

    @IBAction func calendarSwitchValueChanged(_ sender: Any) {
        updateCalendarExportPreferences(value: calendarSwitch.isOn)
    }

    @IBAction func restoreDefaultsTouchUp(_ sender: Any) {
        restoreDefaultPreferences()
    }

    // MARK: - Methods
    func updateExternalLinksInfo() {
        if externalLinksSwitch.isOn {
            externalLinksSubtitle.text = externalLinksEnabledMessage
        } else {
            externalLinksSubtitle.text = externalLinksDisabledMessage
        }
    }

    func updateCalendarExportInfo() {
        if calendarSwitch.isOn {
            calendarSubtitle.text = calendarEnabledMessage
        } else {
            calendarSubtitle.text = calendarDisabledMessage
        }
    }

    func updateExternalLinksPreferences(value: Bool) {
        startLoadingAnimation()
        UsersDatabase.shared.setCurrentUserExternalLinkPreference(
            openExternalLinkInSafari: value)
        { (error) in
            DispatchQueue.main.async {
                if error != nil {
                    // TODO: Handle error
                    self.endLoadingAnimation()
                    self.alert(title: "An Error Occured")
                } else {
                    AppState.openExternalLinksInSafari = value
                    self.endLoadingAnimation()
                    self.updateExternalLinksInfo()
                }
            }
        }
    }

    func updateCalendarExportPreferences(value: Bool) {
        startLoadingAnimation()
        UsersDatabase.shared.setCurrentUserCalendarExportPreference(
            openCalendarOnEventExport: value)
        { (error) in
            DispatchQueue.main.async {
                if error != nil {
                    // TODO: Handle error
                    self.endLoadingAnimation()
                    self.alert(title: "An Error Occured")
                } else {
                    AppState.openCalendarOnEventExport = value
                    self.endLoadingAnimation()
                    self.updateCalendarExportInfo()
                }
            }
        }
    }

    func restoreDefaultPreferences() {
        startLoadingAnimation()
        UsersDatabase.shared.setCurrentUserExternalLinkPreference(
            openExternalLinkInSafari: false)
        { (error) in
            DispatchQueue.main.async {
                if error != nil {
                    // TODO: Handle error
                    self.endLoadingAnimation()
                    self.alert(title: "An Error Occured")
                } else {
                    AppState.openExternalLinksInSafari = false
                    self.externalLinksSwitch.isOn = false
                    self.updateExternalLinksInfo()
                    UsersDatabase.shared.setCurrentUserCalendarExportPreference(
                        openCalendarOnEventExport: false)
                    { (error) in
                        DispatchQueue.main.async {
                            if error != nil {
                                // TODO: Handle error
                                self.endLoadingAnimation()
                                self.alert(title: "An Error Occured")
                            } else {
                                AppState.openCalendarOnEventExport = false
                                self.endLoadingAnimation()
                                self.calendarSwitch.isOn = false
                                self.updateCalendarExportInfo()
                            }
                        }
                    }
                }
            }
        }
    }

    func startLoadingAnimation() {
        self.navigationItem.hidesBackButton = true
        hud = LoadingHUD(self.view)
    }

    func endLoadingAnimation() {
        guard let _ = hud else { return }
        hud!.end()
        self.navigationItem.hidesBackButton = false
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
