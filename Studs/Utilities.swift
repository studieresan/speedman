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

extension Date {
  func getDayOfMonth() -> Int {
    return Calendar.current.component(.day, from: self)
  }

  func getShortMonthName() -> String {
    let monthNames = Calendar.current.shortMonthSymbols
    let day = Calendar.current.component(.month, from: self)
    return monthNames[day - 1]
  }
}
