//
//  Utilities.swift
//  Studs
//
//  Created by Jonathan Berglind on 2018-03-05.
//  Copyright © 2018 Studieresan. All rights reserved.
//

import Foundation
import UIKit

extension String: Error {}

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
  static let dateAndTimeFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "d/M HH:mm"
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

extension UIImage {
  /// Create a UIImage from a color
  static func from(color: UIColor) -> UIImage {
    let rect = CGRect(x: 0, y: 0, width: 1, height: 1)
    UIGraphicsBeginImageContext(rect.size)
    let context = UIGraphicsGetCurrentContext()
    context!.setFillColor(color.cgColor)
    context!.fill(rect)
    let img = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    return img!
  }
}

/// A UINavigationController that asks currently displaying VC for how to style the
/// statusbar
class UINavigationControllerWithAdaptiveStatusBar: UINavigationController {
  override var childViewControllerForStatusBarStyle: UIViewController? {
    return topViewController
  }

  override var childViewControllerForStatusBarHidden: UIViewController? {
    return topViewController
  }
}

extension UIViewController {
  var isVerticallyCompact: Bool {
    return self.traitCollection.verticalSizeClass == .compact
  }
}

/// Simple struct that represents a subscription to something and
/// a way to unsubscribe.
struct Subscription<T> {
  let unsubscribe: () -> Void
}

extension UIImage {
  func addingImagePadding(x: CGFloat, y: CGFloat) -> UIImage? {
    let width: CGFloat = size.width + x
    let height: CGFloat = size.height + y
    UIGraphicsBeginImageContextWithOptions(CGSize(width: width, height: height), false, 0)
    let origin: CGPoint =
      CGPoint(x: (width - size.width) / 2, y: (height - size.height) / 2)
    draw(at: origin)
    let imageWithPadding = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    return imageWithPadding?.withRenderingMode(renderingMode)
  }
}

extension UIColor {
  func toHexString() -> String {
    var red: CGFloat = 0
    var green: CGFloat = 0
    var blue: CGFloat = 0
    var alpha: CGFloat = 0
    getRed(&red, green: &green, blue: &blue, alpha: &alpha)
    let rgb: Int = (Int)(red*255)<<16 | (Int)(green*255)<<8 | (Int)(blue*255)<<0
    return String(format: "#%06x", rgb)
  }
}

extension NSAttributedString {
  internal convenience init?(html: String, font: UIFont, color: UIColor) {
    let additionalStyles =
    """
    <style>
      body {
        font-family: '\(font.fontName)';
        font-size:\(font.pointSize)px;
        color: \(color.toHexString());
      }
    </style>
    """
    let styledHtml = "\(html) \(additionalStyles)"
    guard let data =
      styledHtml.data(using: String.Encoding.utf16, allowLossyConversion: false) else {
      return nil
    }
    guard let attributedString =
      try? NSAttributedString(
        data: data,
        options: [
          .documentType: NSAttributedString.DocumentType.html,
          .characterEncoding: String.Encoding.utf8.rawValue,
        ],
        documentAttributes: nil
      ) else { return nil }
    self.init(attributedString: attributedString)
  }
}
