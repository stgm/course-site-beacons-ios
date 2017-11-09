//
//  CourseSiteConnection.swift
//  iBeacons-Test
//
//  Created by Marijn Jansen on 17/10/2017.
//  Copyright © 2017 Marijn Jansen. All rights reserved.
//

import Foundation

class CourseSiteConnection {
    static let shared = CourseSiteConnection()

    var site: String?
    var token: String?
    var role: SiteRole = .notSet
    let defaults: UserDefaults = UserDefaults.standard

    private init() {
        self.site = defaults.string(forKey: "site")
        self.token = defaults.string(forKey: "token")
        if let _ = site, let _ = token {
            print("\(site!), \(token!)")
            loadRole()
        }
    }

    func getURL() throws -> String {
        if let site = self.site {
            return "https://\(site).mprog.nl/"
        } else {
            throw CourseSiteError.siteNotSet
        }
    }

    func getToken(usingCode code: String) throws {
        let url = URL(string: "\(try getURL())tracking/register?code=\(code)")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"

        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let data = data {
                let json = try? JSONSerialization.jsonObject(with: data)
                let betterJson = json as? [String: Any]

                if let token = betterJson!["token"] as? String {
                    self.defaults.set(token, forKey: "token")
                    self.token = token
                }
            }
            if let error = error {
                print("Error: \(error)")
            }
        }
        task.resume()
    }

    func setSite(site: String) {
        defaults.set(site, forKey: "site")
        self.site = site
    }

    func sendPing(loca: String) {
        do {
            let url = URL(string:"\(try self.getURL())tracking/tokenized/ping?token=\(token!)&loca=\(loca)")!
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            let task = URLSession.shared.dataTask(with: request, completionHandler: { (data, response, error) in
                if let data = data {
                    print(data)
                }
            })
            task.resume()

        } catch CourseSiteError.siteNotSet {

        } catch {

        }
    }

    func sendGone() {
        do {
            let url = URL(string:"\(try self.getURL())tracking/tokenized/gone?token=\(token!)")!
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            let task = URLSession.shared.dataTask(with: request, completionHandler: { (data, response, error) in
                if let data = data {
                    print(data)
                }
            })
            task.resume()

        } catch CourseSiteError.siteNotSet {

        } catch {

        }
    }

    fileprivate func loadRole() {
        do {
            if let _ = self.site, let token = self.token {
                let url = URL(string: "\(try self.getURL())tracking/tokenized/identify?token=\(token)")!
                var request = URLRequest(url: url)
                request.httpMethod = "POST"

                let task = URLSession.shared.dataTask(with: request, completionHandler: { (data, respnse, error) in
                    if let data = data {
                        let rawJSON = try? JSONSerialization.jsonObject(with: data)
                        let json = rawJSON as? [String: Any]
                        if let role = json!["role"] as? String {

                            switch role {
                            case "assistant":
                                print("Assistant")
                                self.role = .assistant
                            case "student":
                                print("Student")
                                self.role = .student
                            default:
                                self.role = .notSet
                            }
                        }
                    }
                    NotificationCenter.default.post(name: NSNotification.Name("loadedRole"), object: nil)
                })
                task.resume()
            }
        } catch CourseSiteError.siteNotSet {

        } catch {

        }
    }
}

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
