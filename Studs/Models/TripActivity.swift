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

  let id: String
  let city: City
  let category: Category
  let title: String
  let description: String
  let price: String
  let location: Location
  let createdDate: Date
  let startDate: Date
  let endDate: Date

  struct Location {
    let address: String
    let coordinate: CLLocationCoordinate2D
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
