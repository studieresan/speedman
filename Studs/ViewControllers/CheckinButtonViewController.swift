//
//  CheckinButtonViewController.swift
//  Studs
//
//  Created by Jonathan Berglind on 2018-02-19.
//  Copyright © 2018 Studieresan. All rights reserved.
//

import UIKit

class CheckinButtonViewController: UIViewController {

  // MARK: - Outlets
  @IBOutlet weak var titleLabel: UILabel!
  @IBOutlet weak var subtitleLabel: UILabel!

  // MARK: - Properties
  var event: Event!
  var checkin: EventCheckin?
  private let dateFormatter: DateFormatter = {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "HH:mm"
    return dateFormatter
  }()
  private let haptic = UISelectionFeedbackGenerator()

  private enum State {
    case open
    case disabled
    case checkedIn
  }

  // MARK: - Lifecycle
  override func viewDidLoad() {
    super.viewDidLoad()

    guard let user = UserManager.shared.user else { return }
    Firebase.streamCheckin(eventId: event.id, userId: user.id) { checkin in
      self.checkin = checkin
      self.updateUI()
    }
    updateUI()
  }

  // MARK: - Actions
  @IBAction func buttonTapped(_ sender: UITapGestureRecognizer) {
    guard getState() == State.open else { return }
    guard let user = UserManager.shared.user else { return }
    guard checkin == nil else { return }
    Firebase.addCheckin(userId: user.id, byUserId: user.id, eventId: event.id)
    haptic.selectionChanged()
  }

  // MARK: -
  private func updateUI() {
    switch getState() {
    case .open:
      titleLabel.text = "Check in"
      subtitleLabel.text = "Not checked in - Tap to check in"
      view.backgroundColor = #colorLiteral(red: 0.2451893389, green: 0.2986541092, blue: 0.3666122556, alpha: 1)
      titleLabel.alpha = 1.0
      view.alpha = 1.0
    case .checkedIn:
      let time = dateFormatter.string(from: checkin!.checkedInAt)
      titleLabel.text = "You are checked in!"
      subtitleLabel.text = "Checked in at \(time)"
      view.backgroundColor = #colorLiteral(red: 0.4503, green: 0.7803, blue: 0.0, alpha: 1)
      titleLabel.alpha = 1.0
      view.alpha = 1.0
    case .disabled:
      titleLabel.text = "Check-in closed"
      subtitleLabel.text = "Check-in opens when event starts"
      view.backgroundColor = #colorLiteral(red: 0.2451893389, green: 0.2986541092, blue: 0.3666122556, alpha: 1)
      titleLabel.alpha = 0.5
      view.alpha = 0.5
    }
  }

  private func getState() -> State {
    if checkin != nil {
      return .checkedIn
    } else if event.date?.compare(Date()) == .orderedDescending {
      return .disabled
    } else {
      return .open
    }
  }
}
