//
//  User.swift
//  Studs
//
//  Created by Jonathan Berglind on 2018-01-18.
//  Copyright © 2018 Studieresan. All rights reserved.
//

import Foundation

struct User: Decodable {
  let id: String
  let firstName: String?
  let lastName: String?
  let phone: String?

  enum CodingKeys: String, CodingKey {
    case id
    case profile
  }

  enum ProfileCodingKeys: String, CodingKey {
    case firstName
    case lastName
    case phone
  }

  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)

    id = try container.decode(String.self, forKey: .id)

    let profile = try container.nestedContainer(keyedBy: ProfileCodingKeys.self,
                                                forKey: .profile)
    firstName = try profile.decode(String?.self, forKey: .firstName)
    lastName = try profile.decode(String?.self, forKey: .lastName)
    phone = try profile.decode(String?.self, forKey: .phone)
  }
}
