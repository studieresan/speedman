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

  // MARK: - Outlets
  @IBOutlet weak var bgView: RoundedShadowView?
  @IBOutlet weak var nameLabel: UILabel!
  @IBOutlet weak var dateLabel: UILabel!
  @IBOutlet weak var locationLabel: UILabel!

  // MARK: - Properties
  @IBInspectable
  var highlightColor: UIColor = #colorLiteral(red: 0.952861011, green: 0.9529945254, blue: 0.9528190494, alpha: 1)
  var defaultColor: UIColor!

  // MARK: - Lifecycle
  override func awakeFromNib() {
    super.awakeFromNib()
    // Initialization code
    defaultColor = bgView?.backgroundColor!
  }

  // MARK: - UITableViewCell
  override func setHighlighted(_ highlighted: Bool, animated: Bool) {
    super.setHighlighted(highlighted, animated: animated)
    bgView?.backgroundColor = highlighted ? highlightColor : defaultColor
  }

  override func setSelected(_ selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)
    bgView?.backgroundColor = selected ? highlightColor : defaultColor
  }
}
