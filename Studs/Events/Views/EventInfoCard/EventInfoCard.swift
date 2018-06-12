//
//  EventInfoCard.swift
//  Studs
//
//  Created by Jonathan Berglind on 2018-04-19.
//  Copyright © 2018 Studieresan. All rights reserved.
//

import UIKit

@IBDesignable
class EventInfoCard: CardView {
  // MARK: - Outlets
  @IBOutlet var contentView: CardView!
  @IBOutlet weak var companyLabel: UILabel!
  @IBOutlet weak var addressLabel: UILabel!
  @IBOutlet weak var dateLabel: UILabel!
  @IBOutlet weak var timeLabel: UILabel!

  // MARK: - Properties
  override var backgroundColor: UIColor? {
    didSet {
      contentView?.backgroundColor = backgroundColor
    }
  }
  var highlightColor: UIColor = #colorLiteral(red: 0.952861011, green: 0.9529945254, blue: 0.9528190494, alpha: 1)
  var defaultColor: UIColor!

  // MARK: - Initialization
  override init(frame: CGRect) {
    super.init(frame: frame)
    setup()
  }

  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    setup()
  }

  func setup() {
    contentView = loadViewFromNib()
    isMultipleTouchEnabled = false
    contentView.backgroundColor = backgroundColor
    defaultColor = backgroundColor
    contentView.frame = bounds
    contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    addSubview(contentView)
  }

  func loadViewFromNib() -> CardView? {
    let bundle = Bundle(for: type(of: self))
    let nib = UINib(nibName: String(describing: type(of: self)), bundle: bundle)
    return nib.instantiate(withOwner: self, options: nil).first as? CardView
  }

  // MARK: - UIResponder
  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    backgroundColor = highlightColor
  }

  override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
    backgroundColor = defaultColor
  }

  override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
    backgroundColor = defaultColor
  }
}

extension EventInfoCard {
  // Allow setting up outlets using an Event
  func setup(for event: Event) {
    companyLabel.text = event.companyName
    addressLabel.text = event.location
    dateLabel.text = DateFormatter.dateFormatter.string(from: event.date ?? Date())
    timeLabel.text = DateFormatter.timeFormatter.string(from: event.date ?? Date())
  }
}
