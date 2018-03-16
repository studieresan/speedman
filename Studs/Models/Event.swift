//
//  Event.swift
//  Studs
//
//  Created by Jonathan Berglind on 2018-01-18.
//  Copyright © 2018 Studieresan. All rights reserved.
//

import Foundation

struct Event: Decodable, Comparable {
  let id: String
  let companyName: String?
  let schedule: String?
  let location: String?
  let privateDescription: String?
  let beforeSurveys: [String]?
  let afterSurveys: [String]?
  let date: Date?

  enum CodingKeys: String, CodingKey {
    case id
    case companyName
    case schedule
    case location
    case privateDescription
    case beforeSurveys
    case afterSurveys
    case date
  }

  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)

    id = try container.decode(String.self, forKey: .id)
    companyName = try container.decode(String?.self, forKey: .companyName)
    schedule = try container.decode(String?.self, forKey: .schedule)
    location = try container.decode(String?.self, forKey: .location)
    privateDescription = try container.decode(String?.self, forKey: .privateDescription)
    beforeSurveys = try container.decode([String]?.self, forKey: .beforeSurveys)
    afterSurveys = try container.decode([String]?.self, forKey: .afterSurveys)

    let dateString = try container.decode(String?.self, forKey: .date)
    date = DateFormatter.iso8601Fractional.date(from: dateString ?? "")
  }

  static func < (lhs: Event, rhs: Event) -> Bool {
    let date1 = lhs.date ?? Date.distantPast
    let date2 = rhs.date ?? Date.distantPast
    return date1 < date2
  }

  static func == (lhs: Event, rhs: Event) -> Bool {
    return lhs.id == rhs.id
  }
}
