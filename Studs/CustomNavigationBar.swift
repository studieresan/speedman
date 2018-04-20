//
//  CustomNavigationBar.swift
//  Studs
//
//  Created by Jonathan Berglind on 2018-04-19.
//  Copyright © 2018 Studieresan. All rights reserved.
//
//  A navigation bar with some predefined styles
//  The change of style is animated

import UIKit

class CustomNavigationBar: UINavigationBar {
  enum Style: String {
    case translucent
    case clear
    case faded
  }

  // MARK: - Properties
  var style = Style.translucent {
    didSet {
      guard style != oldValue else { return }
      // Animate the change
      // The animation layer gets consumed so we'll readd it each time
      let animation = CATransition()
      animation.duration = 0.2
      animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
      animation.type = kCATransitionFade
      self.layer.add(animation, forKey: nil)

      switch style {
      case .translucent:
        setBackgroundImage(nil, for: .default)
        shadowImage = nil
      case .clear:
        setBackgroundImage(UIImage(), for: .default)
        shadowImage = UIImage()
      case .faded:
        let img = UIImage.from(color: UIColor.white.withAlphaComponent(0.3))
        setBackgroundImage(img, for: .default)
        shadowImage = UIImage()
      }
    }
  }
}
