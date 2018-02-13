//
//  UserManager.swift
//  Studs
//
//  Created by Jonathan Berglind on 2018-02-12.
//  Copyright © 2018 Studieresan. All rights reserved.
//
//  Singleton for keeping track of the currently logged in user.
//  TODO: Get rid of this singleton?

import Foundation
import Alamofire

class UserManager {
  static let shared = UserManager()

  var isLoggedIn: Bool {
    return user != nil
  }

  private(set) var user: User? {
    didSet {
      let defaults = UserDefaults.standard
      if let user = user {
        // Save user to defaults
        let archivedUser: Data? = try? PropertyListEncoder().encode(user)
        defaults.setValue(archivedUser, forKey: UserManager.defaultsKey)
      } else {
        // Drop user from defaults
        defaults.setValue(nil, forKey: UserManager.defaultsKey)
      }
      defaults.synchronize()
    }
  }

  private init() {
    // Try to get user from file system
    let defaults = UserDefaults.standard
    if let archivedUser = defaults.object(forKey: UserManager.defaultsKey) as? Data {
      user = try? PropertyListDecoder().decode(User.self, from: archivedUser)
    }

    // Try to get user from API
    renewUser()
  }

  /// Gets the currently logged in user from the API
  /// If the API returns an unauthorized error, the current user is dropped.
  func renewUser() {
    API.getUser { result in
      switch result {
      case .success(let user):
        self.user = user
      case .failure(let error):
        if let error = error as? AFError {
          // If error comes from unauthorized request we're not logged in
          // Then we'll drop the user
          if error.responseCode == 403 {
            // 403: Unauthorized
            self.user = nil
          }
        }
      }
    }
  }

  func dropUser() {
    user = nil
  }
}

extension UserManager {
  // The key used that we serialize our user to
  private static let defaultsKey = "user"
}
