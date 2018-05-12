//
//  State.swift
//  Studs
//
//  Created by Jonathan Berglind on 2018-05-10.
//  Copyright © 2018 Studieresan. All rights reserved.
//

import Foundation

struct State {
  var activities: [TripActivity]
  var selectedActivity: TripActivity?
  var drawerPosition: DrawerPosition

  static let defaultState = State(activities: [TripActivity](),
                                  selectedActivity: nil,
                                  drawerPosition: .partiallyRevealed)
}

enum DrawerPosition: String {
  case collapsed
  case partiallyRevealed
  case open
}
