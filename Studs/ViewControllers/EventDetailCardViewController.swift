//
//  EventDetailCardViewController.swift
//  Studs
//
//  Created by Jonathan Berglind on 2018-04-08.
//  Copyright © 2018 Studieresan. All rights reserved.
//

import UIKit

class EventDetailCardViewController: UIViewController {
  // MARK: - Outlets
  @IBOutlet weak var companyLabel: UILabel!
  @IBOutlet weak var dateLabel: UILabel!
  @IBOutlet weak var timeLabel: UILabel!
  @IBOutlet weak var addressLabel: UILabel!

  // MARK: - Properties
  var event: Event? {
    didSet {
      updateUI()
    }
  }
  var highlightColor: UIColor = #colorLiteral(red: 0.952861011, green: 0.9529945254, blue: 0.9528190494, alpha: 1)
  var defaultColor: UIColor!

  // MARK: - Lifecycle
  override func viewDidLoad() {
    super.viewDidLoad()
    updateUI()
    defaultColor = view.backgroundColor
  }

  private func updateUI() {
    guard let event = event, companyLabel != nil else { return }
    companyLabel.text = event.companyName
    if let date = event.date {
      dateLabel.text = DateFormatter.dateFormatter.string(from: date)
      timeLabel.text = DateFormatter.timeFormatter.string(from: date)
    } else {
      dateLabel.isHidden = true
      timeLabel.isHidden = true
    }
    addressLabel.text = event.location
  }

  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    view.backgroundColor = highlightColor
  }

  override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
    view.backgroundColor = defaultColor
  }

  override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
    view.backgroundColor = defaultColor
  }
}
