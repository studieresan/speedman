//
//  CheckinButtonViewController.swift
//  Studs
//
//  Created by Jonathan Berglind on 2018-02-19.
//  Copyright © 2018 Studieresan. All rights reserved.
//

import UIKit
import CoreLocation

class CheckinButtonViewController: UIViewController, CLLocationManagerDelegate {

  // MARK: - Outlets
  @IBOutlet weak var titleLabel: UILabel!
  @IBOutlet weak var subtitleLabel: UILabel!

  // MARK: - Properties
  var event: Event!
  var checkin: EventCheckin?
  private var eventLocation: CLLocation? = CLLocation()
  private var currentLocation: CLLocation?
  private var checkinStart: Date? {
    // Allow checking in 30 minutes early
    return event.date?.addingTimeInterval(-(60 * 30))
  }
  private var state: State {
    if checkin != nil { return .checkedIn }
    if let checkinStart = checkinStart, checkinStart > Date() { return .wrongTime }
    if let eventLocation = eventLocation {
      if currentLocation == nil ||
        currentLocation!.distance(from: eventLocation) > 100 {
        return .wrongLocation
      }
    }
    return .open
  }

  private let haptic = UISelectionFeedbackGenerator()
  private let locationManager = CLLocationManager()

  // Possible states the button can be in
  private enum State {
    case open
    case wrongTime
    case wrongLocation
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

    // Lookup CLLocation for event
    if let address = event.location {
      let geocoder = CLGeocoder()
      geocoder.geocodeAddressString(address) { placemarks, _ in
        self.eventLocation = placemarks?[0].location
        self.updateUI()
      }
    }

    // Reqest access to location services
    if CLLocationManager.locationServicesEnabled() {
      locationManager.requestWhenInUseAuthorization()
      locationManager.distanceFilter = 10
      locationManager.delegate = self
    }
    updateUI()
  }

  override func viewWillAppear(_ animated: Bool) {
    locationManager.startUpdatingLocation()
  }

  override func viewWillDisappear(_ animated: Bool) {
    locationManager.stopUpdatingLocation()
  }

  // MARK: - CLLocationManagerDelegate
  func locationManager(_ manager: CLLocationManager,
                       didUpdateLocations locations: [CLLocation]) {
    currentLocation = locationManager.location
    updateUI()
  }

  // MARK: - Actions
  @IBAction func buttonTapped(_ sender: UITapGestureRecognizer) {
    guard state == State.open else { return }
    guard let user = UserManager.shared.user else { return }
    guard checkin == nil else { return }
    Firebase.addCheckin(userId: user.id, byUserId: user.id, eventId: event.id)
    haptic.selectionChanged()
  }

  // MARK: -
  private func updateUI() {
    switch state {
    case .open:
      titleLabel.text = "Check in"
      subtitleLabel.text = "Not checked in - Tap to check in"
      view.backgroundColor = #colorLiteral(red: 0.2451893389, green: 0.2986541092, blue: 0.3666122556, alpha: 1)
      titleLabel.alpha = 1.0
      view.alpha = 1.0
    case .checkedIn:
      let time = DateFormatter.timeFormatter.string(from: checkin!.checkedInAt)
      titleLabel.text = "You are checked in!"
      subtitleLabel.text = "Checked in at \(time)"
      view.backgroundColor = #colorLiteral(red: 0.4503, green: 0.7803, blue: 0.0, alpha: 1)
      titleLabel.alpha = 1.0
      view.alpha = 1.0
    case .wrongTime:
      titleLabel.text = "Check-in closed"
      if let date = checkinStart, Calendar.current.isDateInToday(date) {
        let time = DateFormatter.timeFormatter.string(from: date)
        subtitleLabel.text = "Check-in opens at \(time)"
      } else {
        subtitleLabel.text = "Check-in opens on day of event"
      }
      view.backgroundColor = #colorLiteral(red: 0.2451893389, green: 0.2986541092, blue: 0.3666122556, alpha: 1)
      titleLabel.alpha = 0.5
      view.alpha = 0.5
    case .wrongLocation:
      titleLabel.text = "Check in"
      subtitleLabel.text = "Checking in is only possible on location of event"
      view.backgroundColor = #colorLiteral(red: 0.2451893389, green: 0.2986541092, blue: 0.3666122556, alpha: 1)
      titleLabel.alpha = 0.5
      view.alpha = 0.5
    }
  }
}
