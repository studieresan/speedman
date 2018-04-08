//
//  Utilities.swift
//  Studs
//
//  Created by Jonathan Berglind on 2018-03-05.
//  Copyright © 2018 Studieresan. All rights reserved.
//

import Foundation
import UIKit

extension DateFormatter {
  static let iso8601Fractional: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZZZZZ"
    return formatter
  }()
  static let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "d/M"
    return formatter
  }()
  static let timeFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "HH:mm"
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

extension UITableView {
  /// Manually trigger a pull to refresh.
  /// Remember to call `endRefreshing()` of the UIRefreshControl to stop the animation.
  func triggerRefresh() {
    guard let refreshControl = self.refreshControl else { return }
    // Change content offset to actually show spinner
    self.setContentOffset(
      CGPoint(
        x: 0,
        y: self.contentOffset.y - refreshControl.frame.size.height
      ),
      animated: true)
    refreshControl.beginRefreshing()
    refreshControl.sendActions(for: .valueChanged)
  }
}
