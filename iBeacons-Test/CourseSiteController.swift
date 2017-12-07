//
//  CourseSiteConnection.swift
//  iBeacons-Test
//
//  Created by Marijn Jansen on 17/10/2017.
//  Copyright © 2017 Marijn Jansen. All rights reserved.
//

import Foundation

class CourseSiteController {
    static let shared = CourseSiteController()
    private var delegate: CourceSiteDelegate?

    var role: SiteRole = .notSet
    let defaults: UserDefaults = UserDefaults.standard
    let notificationCenter = NotificationCenter.default
    private(set) var site: String?
    private(set) var token: String?

    var siteURL: String? {
        get {
            if let site = site {
                return "https://\(site).mprog.nl/"
            } else {
                return nil
            }
        } set {
            self.site = newValue!

            if defaults.string(forKey: "site") != site {
                defaults.set(site, forKey: "site")
            }
            notificationCenter.post(name: Notification.Name("refreshUI"), object: nil)
        }
    }

    private init() {
        loadFormUserDefaults()

        loadRole()
    }

    private func loadFormUserDefaults() {
        if let site = defaults.string(forKey: "site") {
            self.siteURL = site
        }

        if let token = defaults.string(forKey: "token") {
            self.token = token
        }
    }

    /// Requests a token from the webiste if a site is set
    func getToken(usingCode code: String) {
        guard let siteURL = siteURL else { return }
        let url = URL(string: "\(siteURL)tracking/register?code=\(code)")!

        var request = URLRequest(url: url)
        request.httpMethod = "POST"

        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let data = data {
                let json = try? JSONSerialization.jsonObject(with: data)
                let betterJson = json as? [String: Any]

                if let token = betterJson!["token"] as? String {
                    self.defaults.set(token, forKey: "token")
                    self.token = token
                    if let delegate = self.delegate {
                        delegate.loadedToken()
                    }
//                    self.notificationCenter.post(name: Notification.Name("refreshUI"), object: nil)
                }
            }
            if let error = error {
                print(error)
            }
        }
        task.resume()
    }

    /// Sends a ping to the website with the given location
    func sendPing(loca: String) {
        guard let siteURL = siteURL, let token = token else { return }

        let url = URL(string:"\(siteURL)tracking/tokenized/ping?token=\(token)&loca=\(loca)")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        let task = URLSession.shared.dataTask(with: request)
        task.resume()
    }

    /// Sends a gone message to the webiste
    func sendGone() {
        guard let siteURL = siteURL, let token = token else { return }

        let url = URL(string:"\(siteURL)tracking/tokenized/gone?token=\(token)")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        let task = URLSession.shared.dataTask(with: request)
        task.resume()
    }

    /// Loads the user's role from the website
    private func loadRole() {
        guard let siteURL = siteURL, let token = token else { return }

        let url = URL(string: "\(siteURL)tracking/tokenized/identify?token=\(token)")!
            var request = URLRequest(url: url)
            request.httpMethod = "POST"

            let task = URLSession.shared.dataTask(with: request, completionHandler: { (data, respnse, error) in
                if let data = data {
                    let rawJSON = try? JSONSerialization.jsonObject(with: data)
                    let json = rawJSON as? [String: Any]
                    if let role = json!["role"] as? String {

                        switch role {
                        case "assistant":
                            self.role = .assistant
                        case "student":
                            self.role = .student
                        default:
                            self.role = .notSet
                        }
                    }
                }
//                self.notificationCenter.post(name: NSNotification.Name("loadedRole"), object: nil)
                if let delegate = self.delegate {
                    delegate.didLoad(role: self.role
                }
            })
        task.resume()
    }
}

protocol CourceSiteDelegate {
    func didLoad(role: SiteRole)
    func loadedToken()
}

/// Types of error this class can throw
enum CourseSiteError: Error {
    case invalidCode
    case siteNotSet
    case tokenNotSet
}

enum SiteRole {
    case notSet
    case none
    case student
    case assistant
}
