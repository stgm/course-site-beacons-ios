//
//  ViewController.swift
//  iBeacons-Test
//
//  Created by Marijn Jansen on 13/10/2017.
//  Copyright © 2017 Marijn Jansen. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var currentCourseButton: UIButton!
    @IBOutlet weak var hasTokenButton: UIButton!
    @IBOutlet weak var beaconStateLabel: UILabel!
    @IBOutlet weak var roleLabel: UILabel!

    let beaconManager = ESTBeaconManager()
    let siteConnection = CourseSiteConnection()

    let A1_16 = CLBeaconRegion(proximityUUID: UUID(uuidString: "B9407F30-F5F8-466E-AFF9-25556B57FE6D")!, major: 0xA116, identifier: "A1.16")
    let A1_22 = CLBeaconRegion(proximityUUID: UUID(uuidString: "B9407F30-F5F8-466E-AFF9-25556B57FE6D")!, major: 0xA122, identifier: "A1.30")
    let A1_30 = CLBeaconRegion(proximityUUID: UUID(uuidString: "B9407F30-F5F8-466E-AFF9-25556B57FE6D")!, major: 0xA130, identifier: "A1.30")

    let defaults = UserDefaults.standard

    // MARK: App Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.beaconManager.delegate = self
        self.beaconManager.requestAlwaysAuthorization()
        NotificationCenter.default.addObserver(self, selector: #selector(updateRole(_:)), name: Notification.Name("loadedRole"), object: nil)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.beaconManager.startRangingBeacons(in: self.A1_16)
        self.beaconManager.startRangingBeacons(in: self.A1_22)
        self.beaconManager.startRangingBeacons(in: self.A1_30)
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.beaconManager.stopRangingBeaconsInAllRegions()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    // MARK: Actions

    @IBAction func courseSiteButton(_ sender: UIButton) {
        getCourseSite()
    }

    @IBAction func getTokenButton(_ sender: Any) {
        do {
        let alert = UIAlertController(title: "Insert code", message: "Please insrt code from\n \(try siteConnection.getURL())", preferredStyle: .alert)
        alert.addTextField { (field) in
            field.placeholder = "code"
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) in
            alert.dismiss(animated: true)
        }))
        alert.addAction(UIAlertAction(title: "Submit", style: .default, handler: { (action) in
            if let code = alert.textFields![0].text {
                try? self.siteConnection.getToken(usingCode: code)
            }
        }))
            present(alert, animated: true)
        } catch CourseSiteError.siteNotSet {
            errorAlert(error: "Site not set.")
        } catch {
            print("bla")
        }
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

    fileprivate func getCourseSite() {
        let alert = UIAlertController(title: "Which site?", message: "Please enter the mprog website", preferredStyle: .alert )
        alert.addTextField(configurationHandler: { (field) in
            field.text = "apps"
        })
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) in
            alert.dismiss(animated: true)
        }))
        alert.addAction(UIAlertAction(title: "Submit", style: .default, handler: { (action) in
            if let site = alert.textFields![0].text {
                print(site)
                self.siteConnection.setSite(site: site)
            }
        }))
        present(alert, animated: true)
    }

    @objc func updateRole(_ notification: NSNotification) {
        roleLabel.text = "Role: \(siteConnection.role)"
    }
}

extension ViewController: ESTBeaconManagerDelegate {
    func beaconManager(_ manager: Any, didDetermineState state: CLRegionState, for region: CLBeaconRegion) {
        if state == CLRegionState.inside {
            print("State for \(region.identifier) is inside")
            beaconStateLabel.text = "State for \(region.identifier) is inside"
        } else if state == CLRegionState.outside {
            print("State for \(region.identifier) is outside")
            beaconStateLabel.text = "State for \(region.identifier) is outside"
        }
    }

//    func beaconManager(_ manager: Any, didRangeBeacons beacons: [CLBeacon], in region: CLBeaconRegion) {
//        print("didRangeBeacons: \(beacons), \(region)")
//    }
}
