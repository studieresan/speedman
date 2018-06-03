//
//  TripActivityTableViewCell.swift
//  Studs
//
//  Created by Jonathan Berglind on 2018-06-03.
//  Copyright © 2018 Studieresan. All rights reserved.
//

import UIKit

class TripActivityTableViewCell: UITableViewCell {

  @IBOutlet weak private var cardView: CardViewWithColorStrip!

  @IBOutlet weak var titleLabel: UILabel!
  @IBOutlet weak var dateLabel: UILabel!
  @IBOutlet weak var locationLabel: UILabel!
  var edgeColor: UIColor {
    get {
      return cardView.colorStripColor
    }
    set {
      cardView.colorStripColor = newValue
    }
  }

}
