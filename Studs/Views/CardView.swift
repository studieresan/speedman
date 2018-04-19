//
//  CardView.swift
//  Studs
//
//  Created by Jonathan Berglind on 2018-01-29.
//  Copyright © 2018 Studieresan. All rights reserved.
//
//  A view that with rounded edges and shadows that looks like a card.
//  The default values can be overridden in the Interface Builder.

import UIKit

@IBDesignable
class CardView: UIView {

  override init(frame: CGRect) {
    super.init(frame: frame)
    setupDefaults()
  }

  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    setupDefaults()
  }

  private func setupDefaults() {
    layer.cornerRadius = 5.0
    layer.borderWidth = 0.0
    layer.borderColor = nil
    layer.shadowRadius = 1.5
    layer.shadowOpacity = 0.2
    layer.shadowOffset = CGSize(width: 0.0, height: 1.0)
    layer.shadowColor = UIColor.black.cgColor
    // Rasterize card view by default.
    // Turn off if animating contents of view.
    layer.shouldRasterize = true
    layer.rasterizationScale = UIScreen.main.scale
  }

  @IBInspectable
  var cornerRadius: CGFloat {
    get {
      return layer.cornerRadius
    }
    set {
      layer.cornerRadius = newValue
    }
  }

  @IBInspectable
  var borderWidth: CGFloat {
    get {
      return layer.borderWidth
    }
    set {
      layer.borderWidth = newValue
    }
  }

  @IBInspectable
  var borderColor: UIColor? {
    get {
      if let color = layer.borderColor {
        return UIColor(cgColor: color)
      }
      return nil
    }
    set {
      if let color = newValue {
        layer.borderColor = color.cgColor
      } else {
        layer.borderColor = nil
      }
    }
  }

  @IBInspectable
  var shadowRadius: CGFloat {
    get {
      return layer.shadowRadius
    }
    set {
      layer.shadowRadius = newValue
    }
  }

  @IBInspectable
  var shadowOpacity: Float {
    get {
      return layer.shadowOpacity
    }
    set {
      layer.shadowOpacity = newValue
    }
  }

  @IBInspectable
  var shadowOffset: CGSize {
    get {
      return layer.shadowOffset
    }
    set {
      layer.shadowOffset = newValue
    }
  }

  @IBInspectable
  var shadowColor: UIColor? {
    get {
      if let color = layer.shadowColor {
        return UIColor(cgColor: color)
      }
      return nil
    }
    set {
      if let color = newValue {
        layer.shadowColor = color.cgColor
      } else {
        layer.shadowColor = nil
      }
    }
  }
}
