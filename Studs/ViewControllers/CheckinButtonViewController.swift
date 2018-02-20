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

  private let haptic = UISelectionFeedbackGenerator()
  private let locationManager = CLLocationManager()
  private let dateFormatter: DateFormatter = {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "HH:mm"
    return dateFormatter
  }()

  // Possible states the button can be in
  private enum State {
    case open
    case wrong_time
    case wrong_location
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
  func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    currentLocation = locationManager.location
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
    case .wrong_time:
      titleLabel.text = "Check-in closed"
      subtitleLabel.text = "Check-in opens when event starts"
      view.backgroundColor = #colorLiteral(red: 0.2451893389, green: 0.2986541092, blue: 0.3666122556, alpha: 1)
      titleLabel.alpha = 0.5
      view.alpha = 0.5
    case .wrong_location:
      titleLabel.text = "Check in"
      subtitleLabel.text = "Check-in is only available on location of event"
      view.backgroundColor = #colorLiteral(red: 0.2451893389, green: 0.2986541092, blue: 0.3666122556, alpha: 1)
      titleLabel.alpha = 0.5
      view.alpha = 0.5
    }
  }

  private func getState() -> State {
    if checkin != nil { return .checkedIn }
    if event.date?.compare(Date()) == .orderedDescending { return .wrong_time }
    if let eventLocation = eventLocation {
      if currentLocation == nil ||
        currentLocation!.distance(from: eventLocation) > 200 {
        return .wrong_location
      }
    }
    return .open
  }
}
