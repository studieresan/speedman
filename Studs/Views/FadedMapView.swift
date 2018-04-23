//
//  FadedMapView.swift
//  Studs
//
//  Created by Jonathan Berglind on 2018-04-23.
//  Copyright © 2018 Studieresan. All rights reserved.
//
//  A standard mapview that sets up and manages its own masking gradient layer

import UIKit
import MapKit

class FadedMapView: MKMapView {
  private lazy var gradientLayer: CAGradientLayer = {
    let gradient = CAGradientLayer()
    gradient.colors = [UIColor.white.cgColor, UIColor.clear.cgColor]
    // Fade out last 10%
    gradient.locations = [0.9, 1.0]
    gradient.frame = bounds
    self.layer.mask = gradient
    return gradient
  }()

  override func layoutSubviews() {
    // Update the gradient layer frame to the mapview bounds
    // Transaction is for disabling the animation of the change
    CATransaction.begin()
    CATransaction.setDisableActions(true)
    gradientLayer.frame = bounds
    CATransaction.commit()

    super.layoutSubviews()
  }
}
