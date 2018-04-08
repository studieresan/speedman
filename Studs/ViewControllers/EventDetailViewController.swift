//
//  EventDetailViewController.swift
//  Studs
//
//  Created by Jonathan Berglind on 2018-01-30.
//  Copyright © 2018 Studieresan. All rights reserved.
//

import UIKit
import MapKit
import SafariServices

class EventDetailViewController: UIViewController {

  // MARK: - Outlets
  @IBOutlet weak var mapView: MKMapView!
  @IBOutlet weak var companyLabel: UILabel!
  @IBOutlet weak var dateLabel: UILabel!
  @IBOutlet weak var addressLabel: UILabel!
  @IBOutlet weak var timeLabel: UILabel!
  @IBOutlet weak var beforeSurveyButton: RoundedShadowView!
  @IBOutlet weak var afterSurveyButton: RoundedShadowView!
  @IBOutlet weak var descriptionCard: RoundedShadowView!
  @IBOutlet weak var descriptionLabel: UILabel!

  // MARK: - Properties
  var event: Event!
  private let locationManager = CLLocationManager()

  // MARK: - Lifecycle
  override func viewDidLoad() {
    super.viewDidLoad()

    companyLabel.text = event.companyName
    if let date = event.date {
      dateLabel.text = DateFormatter.dateFormatter.string(from: date)
      timeLabel.text = DateFormatter.timeFormatter.string(from: date)
    } else {
      dateLabel.isHidden = true
      timeLabel.isHidden = true
    }
    addressLabel.text = event.location

    if let description = event.privateDescription, !description.isEmpty {
      descriptionLabel.text = event.privateDescription
    } else {
      descriptionCard.isHidden = true
    }

    configureSurveyButtons()
    configureMapView()

    // Try to use location
    if CLLocationManager.locationServicesEnabled() {
      locationManager.requestWhenInUseAuthorization()
      locationManager.distanceFilter = 10
    }

    // Hide button to check-in manager if insufficient permissions
    if let user = UserManager.shared.user,
      !user.permissions.contains(.checkins) {
      // TODO: Separate permission for checkins
      navigationItem.rightBarButtonItem = nil
    }
  }

  /// Hide the event surveys buttons conditionally.
  /// Hides the after survey before the event and hides the before survey
  /// after the event starts.
  private func configureSurveyButtons() {
    beforeSurveyButton.isHidden = event.beforeSurveys?.isEmpty ?? true
    afterSurveyButton.isHidden = event.afterSurveys?.isEmpty ?? true
    if let date = event.date {
      if date.compare(Date()) == .orderedDescending {
        afterSurveyButton.isHidden = true
      } else {
        beforeSurveyButton.isHidden = true
      }
    }
  }

  private func configureMapView() {
    // Lookup coordinates for address and place pin on map
    if let address = event.location {
      let geocoder = CLGeocoder()
      geocoder.geocodeAddressString(address) { placemarks, _ in
        guard let placemarks = placemarks else { return }
        guard let coordinate = placemarks[0].location?.coordinate else { return }
        let pin = MKPointAnnotation()
        pin.coordinate = coordinate
        pin.title = "\(self.event.companyName ?? ""): \(address)"
        self.mapView.addAnnotation(pin)
        self.mapView.showAnnotations([pin], animated: false)
        // Move up centering a bit since map is partially covered by card view
        self.mapView.setVisibleMapRect(
          self.mapView.visibleMapRect,
          edgePadding: UIEdgeInsets(top: 0, left: 0, bottom: 50, right: 0),
          animated: false
        )
      }
    } else {
      mapView.isHidden = true
    }
    applyMapFadeOut()
  }

  override func viewWillAppear(_ animated: Bool) {
    locationManager.startUpdatingLocation()
    super.viewWillAppear(animated)
  }

  override func viewWillDisappear(_ animated: Bool) {
    locationManager.stopUpdatingLocation()
    super.viewWillDisappear(animated)
  }

  deinit {
    applyMapViewMemoryLeakFix()
  }

  /// Mitigate MKMapView memory leaks
  /// http://www.openradar.me/33400943
  private func applyMapViewMemoryLeakFix() {
    switch mapView.mapType {
    case .standard, .mutedStandard:
      mapView.mapType = .satellite
    default:
      mapView.mapType = .standard
    }
    mapView.showsUserLocation = false
    mapView.delegate = nil
    mapView.removeFromSuperview()
    mapView = nil
  }

  /// Fades out the bottom of the map view by adding a gradient layer mask
  private func applyMapFadeOut() {
    let gradientLayer = CAGradientLayer()
    let mapBounds = mapView.bounds
    // Don't mask horizontally by making the mask as wide as screen max
    let screenMax = max(UIScreen.main.bounds.maxX, UIScreen.main.bounds.maxY)
    gradientLayer.frame = CGRect(x: mapBounds.origin.x, y: mapBounds.origin.y,
                                 width: screenMax, height: mapBounds.height)
    gradientLayer.colors = [UIColor.white.cgColor, UIColor.clear.cgColor]
    // Fade out last 10%
    gradientLayer.locations = [0.9, 1.0]
    mapView.layer.mask = gradientLayer
  }

  // MARK: - Actions
  @IBAction func beforeSurveyTapped(_ sender: UITapGestureRecognizer) {
    guard let url = event.beforeSurveys?.first else { return }
    openURL(url: url)
  }

  @IBAction func afterSurveyTapped(_ sender: UITapGestureRecognizer) {
    guard let url = event.afterSurveys?.first else { return }
    openURL(url: url)
  }

  /// Open the given url in a SFSafariViewController
  private func openURL(url: String) {
    guard let url = URL(string: url) else { return }
    let safariVC = SFSafariViewController(url: url)
    self.present(safariVC, animated: true)
  }

  // MARK: - Navigation
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    guard let identifier = segue.identifier else { return }
    switch identifier {
    case "checkInSegue":
      if let checkinVC = segue.destination as? CheckInTableViewController {
        checkinVC.event = self.event
      }
    case "checkinButtonSetupSegue":
      if let buttonVC = segue.destination as? CheckinButtonViewController {
        buttonVC.event = self.event
      }
    default:
      break
    }
  }
}
