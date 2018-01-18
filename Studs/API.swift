//
//  API.swift
//  Studs
//
//  Created by Jonathan Berglind on 2018-01-18.
//  Copyright © 2018 Studieresan. All rights reserved.
//

import Foundation
import Alamofire

struct API {
  static let baseURL = "https://studs18-overlord.herokuapp.com"
  static let loginURL = baseURL + "/login"

  /// Tries to log in the user using email and password.
  /// Success boolean is available in completion handler.
  static func login(email: String, password: String,
                    completion: @escaping (Bool) -> Void) {
    let parameters = [
      "email": email,
      "password": password,
      ]
    Alamofire.request(loginURL, method: .post, parameters: parameters,
                      encoding: JSONEncoding.default).response { response in
                        if let status = response.response?.statusCode {
                          completion(status == 200)
                        } else {
                          completion(false)
                        }
    }
  }

  /// Logs out by dropping all cookies associated with the base URL.
  static func logout(completion: (() -> Void)? = nil) {
    let cstorage = HTTPCookieStorage.shared
    if let cookies = cstorage.cookies(for: URL(string: self.baseURL)!) {
      for cookie in cookies {
        cstorage.deleteCookie(cookie)
      }
    }
    completion?()
  }
}

