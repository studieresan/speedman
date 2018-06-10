//
//  CardViewWithColorStrip.swift
//  Studs
//
//  Created by Jonathan Berglind on 2018-06-03.
//  Copyright © 2018 Studieresan. All rights reserved.
//

import UIKit

@IBDesignable
class CardViewWithColorStrip: CardView {
  private let colorStripView = UIView()

  @IBInspectable
  var colorStripColor: UIColor {
    get {
      return colorStripView.backgroundColor ?? .clear
    }
    set {
      colorStripView.backgroundColor = newValue
    }
  }

  override init(frame: CGRect) {
    super.init(frame: frame)
    setup()
  }

  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    setup()
  }

  private func setup() {
    // Round left corners with same radius as card view
    colorStripView.clipsToBounds = true
    colorStripView.layer.cornerRadius = layer.cornerRadius
    colorStripView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMinXMinYCorner]

    // Constrain
    colorStripView.translatesAutoresizingMaskIntoConstraints = false
    addSubview(colorStripView)
    addConstraints([
      leftAnchor.constraint(equalTo: colorStripView.leftAnchor),
      topAnchor.constraint(equalTo: colorStripView.topAnchor),
      bottomAnchor.constraint(equalTo: colorStripView.bottomAnchor),
      colorStripView.widthAnchor.constraint(equalToConstant: 8.0),
    ])
  }

}
