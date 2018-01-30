//
//  EventTableViewCell.swift
//  Studs
//
//  Created by Jonathan Berglind on 2018-01-28.
//  Copyright © 2018 Studieresan. All rights reserved.
//

import UIKit

@IBDesignable
class EventTableViewCell: UITableViewCell {

  // MARK: Outlets
  @IBOutlet weak var nameLabel: UILabel!
  @IBOutlet weak var dateLabel: UILabel!
  @IBOutlet weak var locationLabel: UILabel!

  override func awakeFromNib() {
    super.awakeFromNib()
    // Initialization code
  }

  override func setSelected(_ selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)

    // Configure the view for the selected state
  }

}
