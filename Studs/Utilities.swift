//
//  Utilities.swift
//  Studs
//
//  Created by Jonathan Berglind on 2018-03-05.
//  Copyright © 2018 Studieresan. All rights reserved.
//

import Foundation

extension DateFormatter {
  static let iso8601Fractional: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZZZZZ"
    return formatter
  }()
}

class RelativeDateFormatter: DateFormatter {
  override func string(from date: Date) -> String {
    self.dateFormat = "HH:mm"
    let calendar = Calendar.current
    if calendar.isDateInToday(date) {
      return "Today, \(super.string(from: date))"
    } else if calendar.isDateInTomorrow(date) {
      return "Tomorrow, \(super.string(from: date))"
    } else if calendar.isDateInYesterday(date) {
      return "Yesterday, \(super.string(from: date))"
    } else if calendar.isDate(date, equalTo: Date(), toGranularity: .weekOfYear) {
      // Long weekday names if same week
      self.dateFormat = "EEEE, HH:mm"
      return super.string(from: date)
    } else {
      // Short weekday names + date else
      self.dateFormat = "E dd/MM, HH:mm"
      return super.string(from: date)
    }
  }
}
