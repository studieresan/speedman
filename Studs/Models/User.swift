//
//  User.swift
//  Studs
//
//  Created by Jonathan Berglind on 2018-01-18.
//  Copyright © 2018 Studieresan. All rights reserved.
//

import Foundation

struct User: Codable {
  let id: String
  let firstName: String?
  let lastName: String?
  let phone: String?
  let permissions: [Permission]

  enum Permission: String, Codable {
    case events = "events_permission"
  }

  var fullName: String {
    return "\(firstName ?? "") \(lastName ?? "")"
  }

  enum CodingKeys: String, CodingKey {
    case id
    case permissions
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
    permissions = try container.decode([Permission].self, forKey: .permissions)

    let profile = try container.nestedContainer(keyedBy: ProfileCodingKeys.self,
                                                forKey: .profile)
    firstName = try profile.decode(String?.self, forKey: .firstName)
    lastName = try profile.decode(String?.self, forKey: .lastName)
    phone = try profile.decode(String?.self, forKey: .phone)
  }

  func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(id, forKey: .id)
    try container.encode(permissions, forKey: .permissions)

    var profile = container.nestedContainer(keyedBy: ProfileCodingKeys.self,
                                            forKey: .profile)
    try profile.encode(firstName, forKey: .firstName)
    try profile.encode(lastName, forKey: .lastName)
    try profile.encode(phone, forKey: .phone)
  }
}
