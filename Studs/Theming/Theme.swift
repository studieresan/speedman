//
//  Theme.swift
//  Studs
//
//  Created by Jonathan Berglind on 2018-06-28.
//  Copyright © 2018 Studieresan. All rights reserved.
//

import Foundation
import UIKit

struct Theme {
  var name: String
  var statusBarStyle: UIStatusBarStyle
  var barStyle: UIBarStyle
  var tintColor: UIColor
  var backgroundColor: UIColor
  var primaryTextColor: UIColor
  var secondaryTextColor: UIColor
  var separatorColor: UIColor
  var visualEffect: UIVisualEffect
}

extension Theme {
  static let light = Theme(
    name: "light",
    statusBarStyle: .default,
    barStyle: .default,
    tintColor: UIColor(named: "StudsBlue") ?? .black,
    backgroundColor: .white,
    primaryTextColor: .black,
    secondaryTextColor: UIColor(white: 0.5, alpha: 1),
    separatorColor: UIColor(white: 0.9, alpha: 1),
    visualEffect: UIBlurEffect(style: .extraLight)
  )

  static let dark = Theme(
    name: "dark",
    statusBarStyle: .lightContent,
    barStyle: .blackTranslucent,
    tintColor: UIColor(named: "StudsBeige") ?? .white,
    backgroundColor: UIColor(white: 0.2, alpha: 1),
    primaryTextColor: .white,
    secondaryTextColor: .lightText,
    separatorColor: UIColor(white: 0.3, alpha: 1),
    visualEffect: UIBlurEffect(style: .dark)
  )
}
