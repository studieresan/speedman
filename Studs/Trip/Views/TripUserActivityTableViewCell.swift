//
//  TripUserActivityTableViewCell.swift
//  Studs
//
//  Created by Jonathan Berglind on 2018-06-10.
//  Copyright © 2018 Studieresan. All rights reserved.
//

import UIKit

class TripUserActivityTableViewCell: UITableViewCell {
  // MARK: - Outlets
  @IBOutlet weak var cardView: CardView!
  @IBOutlet weak var editButton: UIButton!
  @IBOutlet weak var titleLabel: UILabel!
  @IBOutlet weak var categoryButton: UIButton!
  @IBOutlet weak var dateLabel: UILabel!
  @IBOutlet weak var locationLabel: UILabel!
  @IBOutlet weak var peopleButton: UIButton!
  @IBOutlet weak var peopleCountLabel: UILabel!
  @IBOutlet weak var registerButton: UIButton!

  @IBOutlet weak var separator: UIView!

  // MARK: - Properties
  var registerButtonTappedAction: (() -> Void)?
  var editButtonTappedAction: (() -> Void)?

  // MARK: - Lifecycle
  override func layoutSubviews() {
    super.layoutSubviews()
    setupTheming() // Themable
  }

  // MARK: - UITableViewCell
  override func setSelected(_ selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)
    // Configure the view for the selected state
  }

  // MARK: - Actions
  @IBAction func registerButtonTapped(_ sender: Any) {
    registerButtonTappedAction?()
  }

  @IBAction func editButtonTapped(_ sender: Any) {
    editButtonTappedAction?()
  }
}

// MARK: - Themable
extension TripUserActivityTableViewCell: Themable {
  func applyTheme(_ theme: Theme) {
    cardView.backgroundColor = theme.backgroundColor
    titleLabel.textColor = theme.primaryTextColor
    dateLabel.textColor = theme.secondaryTextColor
    locationLabel.textColor = theme.secondaryTextColor
    peopleCountLabel.textColor = theme.secondaryTextColor
    peopleButton.tintColor = theme.secondaryTextColor
    editButton.tintColor = theme.tintColor
    registerButton.tintColor = theme.tintColor
    separator.backgroundColor = theme.separatorColor
  }
}
