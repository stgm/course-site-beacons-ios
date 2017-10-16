//
//  ViewController.swift
//  iBeacons-Test
//
//  Created by Marijn Jansen on 13/10/2017.
//  Copyright © 2017 Marijn Jansen. All rights reserved.
//

import UIKit

class ViewController: UIViewController, ESTBeaconManagerDelegate {

    let beaconManager = ESTBeaconManager()
    let region = CLBeaconRegion(proximityUUID: UUID(uuidString: "B9407F30-F5F8-466E-AFF9-25556B57FE6D")!, major: 0xA116, identifier: "A1.16")

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.beaconManager.delegate = self
        self.beaconManager.requestAlwaysAuthorization()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.beaconManager.startRangingBeacons(in: self.region)
    }

    override func viewDidDisappear(_ animated: Bool) {
        self.beaconManager.stopRangingBeacons(in: self.region)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func show(_ sender: UIButton) {
        self.beaconManager.requestState(for: region)
    }
    func beaconManager(_ manager: Any, didDetermineState state: CLRegionState, for region: CLBeaconRegion) {
        if state == CLRegionState.inside {
            print("State for \(region.identifier) is inside")
        } else if state == CLRegionState.outside {
            print("State for \(region.identifier) is outside")
        }

    }

}

