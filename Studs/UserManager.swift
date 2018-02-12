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

class UserManager {
  static let shared = UserManager()

  var isLoggedIn: Bool {
    return user != nil
  }

  var user: User? {
    didSet {
      if let user = user {
        let userDefaults = UserDefaults.standard
        let archivedUser: Data? = try? PropertyListEncoder().encode(user)
        userDefaults.setValue(archivedUser, forKey: UserManager.defaultsKey)
        userDefaults.synchronize()
      }
    }
  }

  private init() {
    // Try to get user from file system
    let userDefaults = UserDefaults.standard
    if let archivedUser = userDefaults.object(forKey: UserManager.defaultsKey) as? Data {
      user = try? PropertyListDecoder().decode(User.self, from: archivedUser)
    }

    // Try to get user from API
    renewUser()
  }

  /// Gets the currently logged in user from the API
  func renewUser() {
    API.getUser { result in
      switch result {
      case .success(let user):
        self.user = user
      default:
        break
      }
    }
  }


  func logout() {
    user = nil
    let userDefaults = UserDefaults.standard
    userDefaults.setValue(nil, forKey: UserManager.defaultsKey)
    userDefaults.synchronize()
  }
}

extension UserManager {
  // The key used that we serialize our user to
  private static let defaultsKey = "user"
}
