//
//  TripActivity.swift
//  Studs
//
//  Created by Jonathan Berglind on 2018-05-07.
//  Copyright © 2018 Studieresan. All rights reserved.
//

import Foundation
import CoreLocation

struct TripActivity {
  enum City: String {
    case newyork
    case neworleans
    case sanfrancisco
    case vancouver
  }

  enum Category: String {
    case drink
    case food
    case attraction
    case other
  }

  var id: String
  var city: City?
  var category: Category
  var title: String?
  var description: String
  var price: String?
  var location: Location
  var createdDate: Date
  var startDate: Date
  var endDate: Date
  var peopleCount: Int
  var isUserActivity: Bool
  var author: String?

  struct Location {
    var address: String
    var coordinate: CLLocationCoordinate2D
  }
}

extension TripActivity: Hashable {
  var hashValue: Int {
    return id.hashValue
  }

  static func == (lhs: TripActivity, rhs: TripActivity) -> Bool {
    return lhs.id == rhs.id
  }
}
