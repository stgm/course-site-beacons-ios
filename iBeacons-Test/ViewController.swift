//
//  ViewController.swift
//  iBeacons-Test
//
//  Created by Marijn Jansen on 13/10/2017.
//  Copyright © 2017 Marijn Jansen. All rights reserved.
//

import UIKit

class ViewController: UIViewController, CourceSiteDelegate {
    func didLoad(role: SiteRole) {
        DispatchQueue.main.async {
            self.roleLabel.text = "Role: \(role)"
        }
    }

    func loadedToken() {
        DispatchQueue.main.async {
            if let siteURL = self.connection.siteURL {
                self.currentCourseButton.setTitle(siteURL, for: .normal)
            } else {
                self.currentCourseButton.setTitle("Tap here to setup site", for: .normal)
            }

            if self.connection.token != nil {
                self.hasTokenButton.setTitle("Token has been set", for: .normal)
            } else {
                self.hasTokenButton.setTitle("Token has not been set", for: .normal)
            }
        }
    }


    // MARK: UI Things
    @IBOutlet weak var currentCourseButton: UIButton!
    @IBOutlet weak var hasTokenButton: UIButton!
    @IBOutlet weak var beaconStateLabel: UILabel!
    @IBOutlet weak var roleLabel: UILabel!
    
    let beaconManager = ESTBeaconManager()
    let connection = CourseSiteController.shared

    // Beacon Regions
    let A1_16 = CLBeaconRegion(proximityUUID: UUID(uuidString: "B9407F30-F5F8-466E-AFF9-25556B57FE6D")!, major: 0xA116, identifier: "A1.16")
    let A1_22 = CLBeaconRegion(proximityUUID: UUID(uuidString: "B9407F30-F5F8-466E-AFF9-25556B57FE6D")!, major: 0xA122, identifier: "A1.30")
    let A1_30 = CLBeaconRegion(proximityUUID: UUID(uuidString: "B9407F30-F5F8-466E-AFF9-25556B57FE6D")!, major: 0xA130, identifier: "A1.30")

    // MARK: App Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        beaconManager.delegate = self
        beaconManager.requestAlwaysAuthorization()
//        NotificationCenter.default.addObserver(self, selector: #selector(updateRoleInMain(_:)), name: Notification.Name("loadedRole"), object: nil)
//        NotificationCenter.default.addObserver(self, selector: #selector(refreshUI(_:)), name: Notification.Name("refreshUI"), object: nil)

        refreshUI(nil)
    }

    @objc private func refreshUI(_ notification: NSNotification?) {
        DispatchQueue.main.async {
            if let siteURL = self.connection.siteURL {
                self.currentCourseButton.setTitle(siteURL, for: .normal)
            } else {
                self.currentCourseButton.setTitle("Tap here to setup site", for: .normal)
            }

            if self.connection.token != nil {
                self.hasTokenButton.setTitle("Token has been set", for: .normal)
            } else {
                self.hasTokenButton.setTitle("Token has not been set", for: .normal)
            }
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        beaconManager.startRangingBeacons(in: self.A1_16)
        beaconManager.startRangingBeacons(in: self.A1_22)
        beaconManager.startRangingBeacons(in: self.A1_30)
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        beaconManager.stopRangingBeaconsInAllRegions()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    // MARK: Actions

    /// Changes CourseSite
    @IBAction func courseSiteButton(_ sender: UIButton) {
        getCourseSite()
    }

    @IBAction func getTokenButton(_ sender: Any) {
        guard let siteURL = connection.siteURL else { return }

        let alert = UIAlertController(title: "Insert code", message: "Please insert code from\n \(siteURL)profile/pair", preferredStyle: .alert)
        alert.addTextField { (field) in
            field.placeholder = "code"
            field.keyboardType = .numberPad
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) in
            alert.dismiss(animated: true)
        }))
        alert.addAction(UIAlertAction(title: "Submit", style: .default, handler: { (action) in
            if let code = alert.textFields![0].text {
                self.connection.getToken(usingCode: code)
            }
        }))
        present(alert, animated: true)
    }
    
    // MARK: Functions

    func errorAlert(error: String) {
        let alert = UIAlertController(title: "Error", message: error, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: { (action) in
            alert.dismiss(animated: true)
        }))
        present(alert, animated: true)
    }

    // MARK: Course-site Interaction


    /// Presents the user with an alert so it can enter a website.
    fileprivate func getCourseSite() {
        let alert = UIAlertController(title: "Which site?", message: "Please enter the mprog website prefix", preferredStyle: .alert )
        alert.addTextField(configurationHandler: { (field) in
            field.placeholder = "apps"
            field.autocorrectionType = .no
            field.autocapitalizationType = .none
        })
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) in
            alert.dismiss(animated: true)
        }))
        alert.addAction(UIAlertAction(title: "Submit", style: .default, handler: { (action) in
            if let site = alert.textFields![0].text {
                print(site)
                self.connection.siteURL = site
            }
        }))
        present(alert, animated: true)
    }

    /// Updates role in screen
    @objc func updateRoleInMain(_ notification: NSNotification) {
        DispatchQueue.main.async {
            self.roleLabel.text = "Role: \(self.connection.role)"
        }
    }
}

extension ViewController: ESTBeaconManagerDelegate {
    func beaconManager(_ manager: Any, didDetermineState state: CLRegionState, for region: CLBeaconRegion) {
        let stringState = state == CLRegionState.inside ? "inside" : "outside"

        print("State for \(region.identifier) is \(stringState)")
        beaconStateLabel.text = "State for \(region.identifier) is \(stringState)"
    }
    func beaconManager(_ manager: Any, didRangeBeacons beacons: [CLBeacon], in region: CLBeaconRegion) {
        for beacon in beacons {
              print(beacon)
        }
    }
}

