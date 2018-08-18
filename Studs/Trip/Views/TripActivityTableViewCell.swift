//
//  TripActivityTableViewCell.swift
//  Studs
//
//  Created by Jonathan Berglind on 2018-06-03.
//  Copyright © 2018 Studieresan. All rights reserved.
//

import UIKit

class TripActivityTableViewCell: UITableViewCell {
  // MARK: - Outlets
  @IBOutlet weak private var cardView: CardViewWithColorStrip!

  @IBOutlet weak var titleLabel: UILabel!
  @IBOutlet weak var dateLabel: UILabel!
  @IBOutlet weak var locationLabel: UILabel!

  // MARK: - Properties
  var edgeColor: UIColor {
    get { return cardView.colorStripColor }
    set { cardView.colorStripColor = newValue }
  }

  // MARK: - Lifecycle
  override func layoutSubviews() {
    super.layoutSubviews()
    setupTheming() // Themable
  }
}

// MARK: - Themable
extension TripActivityTableViewCell: Themable {
  func applyTheme(_ theme: Theme) {
    cardView.backgroundColor = theme.backgroundColor
    titleLabel.textColor = theme.primaryTextColor
    dateLabel.textColor = theme.secondaryTextColor
    locationLabel.textColor = theme.secondaryTextColor
  }
}
